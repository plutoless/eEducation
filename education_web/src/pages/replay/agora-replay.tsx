import React, {useEffect, useMemo, useCallback, useRef} from 'react';
import {replayStore, useObserver, IPlayerState} from './model';
import { useParams, useLocation } from 'react-router-dom';
import { useInterval } from 'react-use';
import { Progress } from '@/components/progress/progress';
import Slider from '@material-ui/core/Slider';
import { WhiteboardAPI } from '@/utils/api';
import { whiteboard } from '@/stores/whiteboard';
import { RTMReplayer, RtmPlayerState } from '@/components/whiteboard/agora/rtm-player';
import moment from 'moment';
import {AgoraPlayer, TimelineScheduler} from '@/utils/agora-web-player/agora-player';
import { t } from '@/i18n';
import { globalStore } from '@/stores/global';
import { PlayerPhase } from 'white-web-sdk';
// import {isElectron} from '@/utils/platform';

const ReplayContext = React.createContext({} as IPlayerState);

//@ts-ignore
window.replayStore = replayStore

const delay = 5000

const useReplayContext = () => React.useContext(ReplayContext);

const ReplayContainer: React.FC<{}> = () => {
  const replayState = useObserver<IPlayerState>(replayStore);

  const location = useLocation()
  const {recordId} = useParams()
  const searchParams = new URLSearchParams(location.search);
  const roomId: string = searchParams.get('roomId') as string;
  const userToken: string = searchParams.get('token') as string;

  const value = replayState;

  const result = value.courseRecordData;

  useInterval(() => {
    replayStore.getCourseRecordBy(recordId as string, roomId as string, userToken)
  }, delay)

  return (
    <ReplayContext.Provider value={value}>
      {result?.status !== 2 ?
        <Progress title={t(`replay.${result?.statusText ? result?.statusText : 'loading'}`)} /> : 
      <TimelineReplay
        whiteboardUUID={result?.boardId as string}
        startTime={result?.startTime as number}
        endTime={result?.endTime as number}
        mediaUrl={result?.url as string}
      />}
    </ReplayContext.Provider>
  )
}

export default ReplayContainer;

export const TimelineReplay: React.FC<any> = ({
  startTime,
  endTime,
  mediaUrl,
  channelName,
  senderId,
  whiteboardUUID
}) => {
  const state = useReplayContext()

  useEffect(() => {
    const startTimestamp: number = +(startTime as string)
    const endTimestamp: number = +(endTime as string)
    const duration = Math.abs(endTimestamp - startTimestamp)

    const initPlayer = async () => {
      const videoPlayer = new AgoraPlayer(mediaUrl, {
        onPhaseChanged: state => {
          console.log("[agore-replay phase] video phase ", state)
          if (state === 'ready') {
            replayStore.updatePlayState('ready')
          }

          if (state !== 'playing') {
            // replayStore.state?.timelineScheduler.stop();
            console.log("[agore-replay phase] timeline stop in video phase ")
          }
        }
      })
  
      //@ts-ignore
      window.videoPlayer = videoPlayer
      replayStore.addVideoPlayer(videoPlayer)
  
      const timeline = new TimelineScheduler(30, (args: any) => {
        if (replayStore.state && replayStore.state.phase && replayStore.state.phase === 'playing') {
          replayStore.setCurrentTime(args.duration)
          replayStore.updateProgress(args.progress)
        }
      }, startTimestamp, endTimestamp)
  
      timeline.on('seek-changed', (duration: number) => {
        if (replayStore.state && replayStore.state.videoPlayer && replayStore.state.player) {
          if (duration / 1000 < replayStore.state.videoPlayer.player.duration()) {
            replayStore.state.videoPlayer.seekTo(duration / 1000)
            replayStore.state.player.seekToScheduleTime(duration)
          }
        }
      })
  
      timeline.on("state-changed", async (state: any) => {
        console.log("state-changed", "state", state, replayStore.state)
        if (replayStore.state && replayStore.state.videoPlayer && replayStore.state.player) {
          if (state === 'started') {
            replayStore.state.videoPlayer.play()
            replayStore.state.player.play()
            replayStore.updatePlayState('playing')
          } else if (state === 'ended') {
            replayStore.state.videoPlayer.pause()
            replayStore.state.player.pause()
            replayStore.updatePlayState('ended')
          } else {
            replayStore.state.videoPlayer.pause()
            replayStore.state.player.pause()
            console.log("[agore-replay phase] timeline " ,state, 'replayStore.is not empty?: ', replayStore.state !== null)
            replayStore.updatePlayState('paused')
          }
        }
      })
      replayStore.addTimeline(timeline)


      if (whiteboardUUID) {
        let {roomToken} = await replayStore.joinRoom(whiteboardUUID)
        let player = await WhiteboardAPI.replayRoom(whiteboard.client, {
          beginTimestamp: startTimestamp,
          duration: duration,
          room: whiteboardUUID,
          roomToken,
        },  {
          onCatchErrorWhenRender: error => {
            error && console.warn(error);
            globalStore.showToast({
              message: t('toast.replay_failed'),
              type: 'notice'
            });
          },
          onCatchErrorWhenAppendFrame: error => {
            error && console.warn(error);
            globalStore.showToast({
              message: t('toast.replay_failed'),
              type: 'notice'
            });
          },
          onPhaseChanged: phase => {
            console.log("[agore-replay phase] whiteboard ", phase)

            let whiteboardPlayStatus = 'ready';

            if (phase === PlayerPhase.Playing) {
              whiteboardPlayStatus = 'playing'
            } else if (phase === PlayerPhase.Pause ||
              phase === PlayerPhase.Ended ||
              phase === PlayerPhase.WaitingFirstFrame) {
              whiteboardPlayStatus = 'paused'
              replayStore.state?.timelineScheduler.stop()
            } else {
              whiteboardPlayStatus = 'waiting'
              console.log("[agore-replay phase] whiteboard phase transmit", phase, whiteboardPlayStatus)
            }
            console.log("[agore-replay phase] whiteboard phase transmit 2", phase, whiteboardPlayStatus)
            replayStore.updatePlayState(whiteboardPlayStatus)
          },
          onStoppedWithError: (error) => {
            error && console.warn(error);
            globalStore.showToast({
              message: t('toast.replay_failed'),
              type: 'notice'
            });
          }
        })
        replayStore.addWhiteboardPlayer(player)
        console.log("[agore-replay phase] join whiteboard")
      }
    }

    initPlayer()
  }, [])

  const playerElementRef = useRef<any>(null)
  const whiteboardElementRef = useRef<any>(null)


  const onWindowResize = () => {
    if (state.player) {
      state.player.refreshViewSize()
    }
  }

  useEffect(() => {
    if (playerElementRef.current) {
      if (state.videoPlayer) {
        state.videoPlayer.initVideo(playerElementRef.current.id)
        return () => {
          state.videoPlayer.destroy()
        }
      }
    }
  }, [state.videoPlayer, playerElementRef])

  useEffect(() => {
    if (whiteboardElementRef.current) {
      if (state.player) {
        console.log("bind", state.player)
        state.player.bindHtmlElement(whiteboardElementRef.current as HTMLDivElement);
        window.addEventListener('resize', onWindowResize);
        return () => {
          window.removeEventListener('resize', onWindowResize);
        }
      }
    }
  }, [state.player, whiteboardElementRef])

  const handlePlayerClick = () => {
    if (!replayStore.state || !state.videoPlayer || !state.timelineScheduler) return;

    if (replayStore.state.phase === 'paused' || replayStore.state.phase === 'ready') {
      state.timelineScheduler.start()
      return
    }

    if (replayStore.state.phase === 'started' || replayStore.state.phase === 'playing') {
      state.timelineScheduler.stop()
      return
    }

    if (replayStore.state.phase === 'ended') {
      state.timelineScheduler.seekTo(0)
      state.timelineScheduler.start()
      return
    }
  }

  const handleChange = (event: any, newValue: any) => {
    replayStore.setCurrentTime(newValue);
    replayStore.updateProgress(newValue);
  }

  const duration = useMemo(() => {
    if (!startTime || !endTime) return 0;
    const _duration = Math.abs(+startTime - +endTime);
    return _duration;
  }, [startTime, endTime]);

  const totalTime = useMemo(() => {
    return moment(duration).format("mm:ss")
  }, [duration]);

  const time = useMemo(() => {
    return moment(state.currentTime).format("mm:ss");
  }, [state.currentTime]);

  const playState = state.phase;

  const PlayerCover = useCallback(() => {

    document.title = playState

    if (!state.videoPlayer || !state.player || playState === 'waiting' || playState === 'loading') {
      return (<Progress title={t("replay.loading")} />)
    }

    if (playState === 'playing') return null;

    return (
      <div className="player-cover">
        {playState !== 'playing' ? 
          <div className="play-btn" onClick={handlePlayerClick}></div> : null}
      </div>
    )
  }, [state.videoPlayer, state.player, state.phase]);

  const onMouseDown = () => {
    if (state.timelineScheduler) {
      console.log("seek to replay. down")
      state.timelineScheduler.stop()
      replayStore.updatePlayState('paused')
    }
  }

  const onMouseUp = () => {
    if (state.timelineScheduler) {
      console.log("seek to replay. up")
      state.timelineScheduler.seekTo(state.currentTime)
      state.timelineScheduler.start()
    }
  }

  return (
    <div className={`replay`}>
      <div className={`player-container`} >
        <PlayerCover />
        <div className="player">
          <div className="agora-logo"></div>
          <div ref={whiteboardElementRef} id="whiteboard" className="whiteboard"></div>
          <div className="video-menu">
            <div className="control-btn">
              <div className={`btn ${playState === 'playing' ? 'paused' : 'play'}`} onClick={handlePlayerClick}></div>
            </div>
            <div className="progress">
              <Slider
                className='custom-video-progress'
                value={state.currentTime}
                onMouseDown={onMouseDown}
                onMouseUp={onMouseUp}
                onChange={handleChange}
                min={0}
                max={duration}
                aria-labelledby="continuous-slider"
              />
              <div className="time">
                <div className="current_duration">{time}</div>
                  /
                <div className="video_duration">{totalTime}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div className="video-container">
        <div className="video-player">
          <div ref={playerElementRef} id="player" style={{width: "100%", height: "100%", objectFit: "cover"}}></div>
        </div>
        <div className="chat-holder chat-board chat-messages-container">
          <RTMReplayer
            senderId={senderId}
            channelName={channelName}
            startTime={startTime}
            endTime={endTime}
            currentSeekTime={state.currentTime}
            onPhaseChanged={(e: RtmPlayerState) => {
              if (e !== RtmPlayerState.load) {
                state.timelineScheduler?.stop();
              }
            }}
          ></RTMReplayer>
        </div>
      </div>
    </div>
  )
}