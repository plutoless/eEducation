import React, { useEffect, useMemo, useRef, useCallback, useState } from 'react';
import '../replay.scss';
import Slider from '@material-ui/core/Slider';
import { Player, PlayerPhase } from 'white-web-sdk';
import { useParams, useLocation } from 'react-router';
import moment from 'moment';
import { Progress } from '@/components/progress/progress';
import { globalStore } from '@/stores/global';
import { replayStore, useObserver, IPlayerState } from './model';
import { WhiteboardAPI } from '@/utils/api';
import { whiteboard } from '@/stores/whiteboard';
import "video.js/dist/video-js.css";
import { RTMReplayer, RtmPlayerState } from '@/components/whiteboard/agora/rtm-player';
import { useInterval } from 'react-use';
import { isElectron } from '@/utils/platform';
import { t } from '@/i18n';

const delay = 5000


const ReplayContext = React.createContext({} as IPlayerState);

const useReplayContext = () => React.useContext(ReplayContext);

const ReplayContainer: React.FC<{}> = () => {
  const replayState = useObserver<IPlayerState>(replayStore)

  const {recordId} = useParams();
  const location = useLocation();
  const searchParams = new URLSearchParams(location.search);
  const roomId: string = searchParams.get('roomId') as string;
  const userToken: string = searchParams.get('token') as string;
  const senderId: string = searchParams.get('senderId') as string;
  const channelName: string = searchParams.get('channelName') as string;

  useInterval(() => {
    replayStore.getCourseRecordBy(recordId as string, roomId as string, userToken)
  }, delay)

  const value = replayState;

  const result = value.courseRecordData;

  return (
    <ReplayContext.Provider value={value}>
      {result?.status !== 2 ?
        <Progress title={t(`replay.${result?.statusText ? result?.statusText : 'loading'}`)} /> : 
        <NetlessAgoraReplay
          roomId={roomId}
          senderId={senderId}
          channelName={channelName}
          whiteboardUUID={result?.boardId as string}
          startTime={result?.startTime as number}
          endTime={result?.endTime as number}
          mediaUrl={result?.url as string} />
      }
    </ReplayContext.Provider>
  )
}

export default ReplayContainer;

export type NetlessAgoraReplayProps = {
  whiteboardUUID: string
  startTime: number
  endTime: number
  mediaUrl: string
  senderId: string
  channelName: string
  roomId: string
}

export const NetlessAgoraReplay: React.FC<NetlessAgoraReplayProps> = ({
  whiteboardUUID: uuid,
  startTime,
  endTime,
  mediaUrl,
  senderId,
  channelName,
  roomId
}) => {
  const state = useReplayContext();

  const player = useMemo(() => {
    if (!replayStore.state || !replayStore.state.player) return null;
    return replayStore.state.player as Player;
  }, [replayStore.state]);

  const handlePlayerClick = () => {
    if (!replayStore.state || !player) return;

    if (player.phase === PlayerPhase.Playing) {
      player.pause();
      return;
    }
    if (player.phase === PlayerPhase.WaitingFirstFrame || player.phase === PlayerPhase.Pause) {
      player.play();
      return;
    }

    if (player.phase === PlayerPhase.Ended) {
      player.seekToScheduleTime(0);
      player.play();
      return;
    }
  }

  const handleChange = (event: any, newValue: any) => {
    replayStore.setCurrentTime(newValue);
    replayStore.updateProgress(newValue);
  }

  const onWindowResize = () => {
    if (state.player) {
      state.player.refreshViewSize();
    }
  }

  const handleSpaceKey = (evt: any) => {
    if (evt.code === 'Space') {
      if (state.player) {
        handleOperationClick(state.player);
      }
    }
  }

  const handleOperationClick = (player: Player) => {
    switch (player.phase) {
      case PlayerPhase.WaitingFirstFrame:
      case PlayerPhase.Pause: {
        player.play();
        break;
      }
      case PlayerPhase.Playing: {
        player.pause();
        break;
      }
      case PlayerPhase.Ended: {
        player.seekToScheduleTime(0);
        break;
      }
    }
  }

  const duration = useMemo(() => {
    if (!startTime || !endTime) return 0;
    const _duration = Math.abs(+startTime - +endTime);
    return _duration;
  }, [startTime, endTime]);

  const lock = useRef<boolean>(false);

  useEffect(() => {
    return () => {
      lock.current = true;
    }
  }, []);

  useEffect(() => {
    window.addEventListener('resize', onWindowResize);
    window.addEventListener('keydown', handleSpaceKey);
    if (roomId && startTime && endTime) {
        replayStore.joinRoom(roomId).then(({roomToken, uuid}) => {
          WhiteboardAPI.replayRoom(whiteboard.client,
          {
            beginTimestamp: +startTime,
            duration: duration,
            room: uuid,
            mediaURL: mediaUrl,
            roomToken: roomToken,
          }, {
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
              replayStore.updateWhiteboardPhase(phase);
            },
            onLoadFirstFrame: () => {
              // replayStore.loadFirstFrame();
            },
            onSliceChanged: () => {
            },
            onPlayerStateChanged: (error) => {
            },
            onStoppedWithError: (error) => {
              error && console.warn(error);
              globalStore.showToast({
                message: t('toast.replay_failed'),
                type: 'notice'
              });
              replayStore.setReplayFail(true);
            },
            onScheduleTimeChanged: (scheduleTime) => {
              if (lock.current) return;
              replayStore.setCurrentTime(scheduleTime);
            }
          }).then((player: Player | undefined) => {
            if (player) {
              replayStore.setPlayer(player);
              player.bindHtmlElement(document.getElementById("whiteboard") as HTMLDivElement);
            }
          })
        });
    }
    return () => {
      window.removeEventListener('resize', onWindowResize);
      window.removeEventListener('keydown', onWindowResize);
    }
  }, []);

  const totalTime = useMemo(() => {
    return moment(duration).format("mm:ss");
  }, [duration]);

  const time = useMemo(() => {
    return moment(state.currentTime).format("mm:ss");
  }, [state.currentTime]);

  const PlayerCover = useCallback(() => {
    if (!player) {
      return (<Progress title={t("replay.loading")} />)
    }

    if (player.phase === PlayerPhase.Playing) return null;

    return (
      <div className="player-cover">
        {player.phase === PlayerPhase.Buffering ? <Progress title={t("replay.loading")} />: null}
        {player.phase === PlayerPhase.Pause || player.phase === PlayerPhase.Ended || player.phase === PlayerPhase.WaitingFirstFrame ? 
          <div className="play-btn" onClick={handlePlayerClick}></div> : null}
      </div>
    )
  }, [player, state]);

  return (
    <div className={`replay`}>
      <div className={`player-container`} >
        <PlayerCover />
        <div className="player">
          <div className="agora-logo"></div>
          <div id="whiteboard" className="whiteboard"></div>
          <div className="video-menu">
            <div className="control-btn">
              <div className={`btn ${player && player.phase === PlayerPhase.Playing ? 'paused' : 'play'}`} onClick={handlePlayerClick}></div>
            </div>
            <div className="progress">
              <Slider
                className='custom-video-progress'
                value={state.currentTime}
                onMouseDown={() => {
                  if (replayStore.state && replayStore.state.player) {
                    const player = replayStore.state.player as Player;
                    player.pause();
                    lock.current = true;
                  }
                }}
                onMouseUp={() => {
                  if (replayStore.state && replayStore.state.player) {
                    const player = replayStore.state.player as Player;
                    player.seekToScheduleTime(state.currentTime);
                    player.play();
                    lock.current = false;
                  }
                }}
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
          <video id="white-sdk-video-js" className="video-js video-layout" style={{width: "100%", height: "100%", objectFit: "cover"}}></video>
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
                player?.stop();
              }
            }}
          ></RTMReplayer>
        </div>
      </div>
    </div>
  )
}