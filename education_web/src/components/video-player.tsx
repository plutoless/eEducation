import React, { useRef, useEffect, useState, useMemo } from 'react';
import Icon from './icon';
import './video-player.scss';
import { AgoraElectronStream, StreamType, AgoraRtcEngine } from '../utils/agora-electron-client';
import { useRoomState } from '../containers/root-container';
import { platform } from '../utils/platform';

const fillContentMode = 0;
const fitContentMode = 1;

interface VideoPlayerProps {
  domId?: string
  id?: string
  streamID: number
  preview?: boolean
  account?: any
  stream?: any
  role?: string
  audio?: boolean
  video?: boolean
  className?: string
  showProfile?: boolean
  local?: boolean
  handleClick?: (type: string, streamID: number, uid: string) => Promise<any>
  close?: boolean
  handleClose?: (uid: string, streamID: number) => void
  autoplay?: boolean
}

const VideoPlayer: React.FC<VideoPlayerProps> = ({
  preview,
  role,
  account,
  stream,
  className,
  domId,
  streamID,
  audio,
  id,
  video,
  handleClick,
  local,
  handleClose,
  close,
  autoplay
}) => {
  const loadVideo = useRef<boolean>(false);
  const loadAudio = useRef<boolean>(false);

  const lockPlay = useRef<boolean>(false);

  const [resume, setResume] = useState<boolean>(false);

  // TODO: 根据组件autoplay属性，仅判断远端流autoplay失败时触发
  // TODO: only trigger resume when play remote stream
  const needResume = useMemo(() => {
    return resume === true &&
      autoplay === false &&
      local === false
  }, [resume, autoplay, local])

  useEffect(() => {
    if (!domId || !stream || !AgoraRtcEngine) return;
    if (platform === 'electron') {
      const _stream = stream as AgoraElectronStream;
      const dom = document.getElementById(domId);
      if (!dom) return;
      console.log("[agora-electron] video player", dom, streamID, fillContentMode);
      if (preview) {
        // set for preview
        AgoraRtcEngine.setupLocalVideo(dom);
        AgoraRtcEngine.setupViewContentMode(streamID, fillContentMode);
        AgoraRtcEngine.setClientRole(1);
        // preview mode required you become host
        AgoraRtcEngine.startPreview();
        // AgoraRtcEngine.muteLocalVideoStream(nativeClient.published);
        // AgoraRtcEngine.muteLocalAudioStream(nativeClient.published);
        return () => {
          console.log("[agora-electron] stop preview", dom, streamID, fillContentMode);
          AgoraRtcEngine.stopPreview();
          AgoraRtcEngine.setClientRole(2);
        }
      }
      if (_stream.type === StreamType.local) {
        console.log("[agora-electron] video-player play ", AgoraRtcEngine.setupViewContentMode(streamID, fillContentMode));
        console.log("[agora-electron] video-player setupLocalVideo ", AgoraRtcEngine.setupLocalVideo(dom));
        return () => {
          // AgoraRtcEngine.destroyRenderView(streamID, dom, (err: any) => { console.warn(err.message) });
        }
      }

      if (_stream.type === StreamType.localVideoSource) {
        AgoraRtcEngine.setupLocalVideoSource(dom);
        AgoraRtcEngine.setupViewContentMode('videosource', fitContentMode);
        // AgoraRtcEngine.setupViewContentMode(streamID, fitContentMode);
        return () => {
          // AgoraRtcEngine.destroyRenderView('videosource');
          // AgoraRtcEngine.destroyRenderView(streamID, dom, (err: any) => { console.warn(err.message) });
        }
      }

      if (_stream.type === StreamType.remote) {
        AgoraRtcEngine.subscribe(streamID, dom);
        AgoraRtcEngine.setupViewContentMode(streamID, fillContentMode);
        return () => {
          // AgoraRtcEngine.destroyRenderView(streamID, dom, (err: any) => { console.warn(err.message) });
        }
      }

      if (_stream.type === StreamType.remoteVideoSource) {
        AgoraRtcEngine.subscribe(streamID, dom);
        // AgoraRtcEngine.setupViewContentMode('videosource', fitContentMode);
        AgoraRtcEngine.setupViewContentMode(streamID, fitContentMode);
        return () => {
          // AgoraRtcEngine.destroyRenderView('videosource');
          // AgoraRtcEngine.destroyRenderView(streamID, dom, (err: any) => { console.warn(err.message) });
        }
      }
    }
  }, [domId, stream, AgoraRtcEngine]);

  useEffect(() => {
    if (platform === 'web') {
      if (!stream || !domId || lockPlay.current && stream.isPlaying()) return;
      lockPlay.current = true;
      stream.play(`${domId}`, { fit: 'cover' }, (err: any) => {
        lockPlay.current = false;
        console.warn('[video-player] ', JSON.stringify(err), id, stream.isPaused(), stream.isPlaying(), ' isLocal: ', local);
        if (!autoplay && err && err.audio && err.audio.status !== "aborted" && !local) {
          stream.isPaused() && setResume(true);
          console.warn('[video-player] play failed ', JSON.stringify(err), id, stream.isPaused(), stream.isPlaying());
        }
      })
      return () => {
        if (stream.isPlaying()) {
          stream.stop();
        }
      }
    }
  }, [domId, stream]);


  useEffect(() => {
    if (stream && platform === 'web') {
      // prevent already muted audio
      if (!loadAudio.current) {
        if (!audio) {
          stream.muteAudio();
          console.log('stream mute audio');
        }
        loadAudio.current = true;
        return;
      }

      if (audio) {
        console.log('stream unmute audio');
        stream.unmuteAudio();
      } else {
        console.log('stream mute audio');
        stream.muteAudio();
      }
    }

    if (stream && platform === 'electron') {
      if (stream.type !== StreamType.local) return;
      // prevent already muted video
      if (!loadAudio.current) {
        if (!audio) {
          const res = AgoraRtcEngine.muteLocalAudioStream(true);
          console.log("[agora-electron] muteLocalAudioStream(true); ", res);
        }
        loadAudio.current = true;
        return;
      }

      if (audio) {
        const res = AgoraRtcEngine.muteLocalAudioStream(false);
        console.log("[agora-electron] muteLocalAudioStream(false); ", res);
      } else {
        const res = AgoraRtcEngine.muteLocalAudioStream(true);
        console.log("[agora-electron] muteLocalAudioStream(true); ", res);
      }
    }
  }, [stream, audio, AgoraRtcEngine]);

  useEffect(() => {
    if (stream && platform === 'web') {
      // prevent already muted video
      if (!loadVideo.current) {
        if (!video) {
          console.log('stream mute video');
          stream.muteVideo();
        }
        loadVideo.current = true;
        return;
      }

      if (video) {
        console.log('stream unmute video');
        stream.unmuteVideo();
      } else {
        console.log('stream mute video');
        stream.muteVideo();
      }
    }

    if (stream && platform === 'electron') {
      if (stream.type !== StreamType.local) return;
      // prevent already muted video
      if (!loadVideo.current) {
        if (!video) {
          // const res = AgoraRtcEngine.muteLocalVideoStream(true);
          const res = AgoraRtcEngine.enableLocalVideo(false);
          console.log("[agora-electron] enableLocalVideo(false); ", res);
        }
        loadVideo.current = true;
        return;
      }

      if (video) {
        // const res = AgoraRtcEngine.muteLocalVideoStream(false);
        const res2 = AgoraRtcEngine.enableLocalVideo(true);
        console.log("[agora-electron] enableLocalVideo(true); ", res2);
      } else {
        // const res = AgoraRtcEngine.muteLocalVideoStream(true);
        const res2 = AgoraRtcEngine.enableLocalVideo(false);
        console.log("[agora-electron] enableLocalVideo(false); ", res2);
      }
    }
  }, [stream, video, AgoraRtcEngine]);

  const onAudioClick = (evt: any) => {
    if (handleClick && id) {
      handleClick('audio', streamID, id);
    }
  }

  const onVideoClick = (evt: any) => {
    if (handleClick && id) {
      handleClick('video', streamID, id);
    }
  }

  const onClose = (evt: any) => {
    if (handleClose && id) {
      handleClose('close', streamID);
    }
  }

  const roomState = useRoomState()

  const me = roomState.me;

  return (
    <div className={`${className ? className : (preview ? 'preview-video rotateY180deg' : `agora-video-view ${Boolean(video) === false && stream ? 'show-placeholder' : ''}`)}`}>
      {close ? <div className="icon-close" onClick={onClose}></div> : null}
      {className !== 'screen-sharing' ? <div className={role === 'teacher' ? 'teacher-placeholder' : 'student-placeholder'}></div> : null}
      {preview ? null :
        account ?
          <div className="video-profile">
            <span className="account">{account}</span>
            {`${me.uid}` === `${id}` || me.role === 1 ?
              <span className="media-btn">
                <Icon onClick={onAudioClick} className={audio ? "icon-speaker-on" : "icon-speaker-off"} data={"audio"} />
                <Icon onClick={onVideoClick} className={video ? "icons-camera-unmute-s" : "icons-camera-mute-s"} data={"video"} />
              </span> : null}
          </div>
          : null
      }
      <div id={`${domId}`} className={`agora-rtc-video ${local ? 'rotateY180deg' : ''}`}></div>
      {needResume ? <div className="clickable" onClick={() => {
        stream.resume().then(() => {
          setResume(false);
          console.log("clickable");
        }).catch(console.warn);
      }}></div> : null}
    </div>
  )
}

export default React.memo(VideoPlayer);