import React, {useRef, useEffect} from 'react';
import VideoPlayer from '@/components/video-player';

import './big-class.scss';
import ChatBoard from '@/components/chat/board';
import MediaBoard from '@/components/mediaboard';
import useStream from '@/hooks/use-streams';
import useChatText from '@/hooks/use-chat-text';
import { AgoraElectronClient } from '@/utils/agora-electron-client';
import {AgoraWebClient} from '@/utils/agora-web-client';
import { useRoomState } from '@/containers/root-container';
import { roomStore } from '@/stores/room';
import { platform } from '@/utils/platform';
import { eduApi } from '@/services/edu-api';
import { globalStore } from '@/stores/global';
import { t } from '@/i18n';

export default function BigClass() {
  const {
    value,
    messages,
    sendMessage,
    handleChange,
    role,
    roomName
  } = useChatText();

  const roomState = useRoomState();

  const me = roomState.me;

  const memberCount = roomState.course.memberCount;

  const {teacher, currentHost, onPlayerClick} = useStream();

  const rtmLock = useRef<boolean>(false);
  const lock = useRef<boolean>(false);
  
  useEffect(() => {
    rtmLock.current = false;
    return () => {
      rtmLock.current = true;
      lock.current = true;
    }
  }, []);

  const handleClick = (type: string) => {
    if (rtmLock.current) return;

    if (type === 'hands_up') {
      if (roomStore.state.course.teacherId) {
        eduApi.studentSendApply(roomStore.state.course.roomId)
          .then((data: any) => {
            console.log('hands_up fulfilled', data)
          })
          .catch((err: any) => {
            console.warn(err)
          })
      }
    }
  
    if (type === 'hands_up_end') {
      rtmLock.current = true;
      eduApi.studentStopCoVideo(roomStore.state.course.roomId)
        .then((data: any) => {
          console.log('hands_up_end success', data)
        })
        .catch((err: any) => {
          console.warn(err)
        })
        .finally(() => {
          rtmLock.current = false;
        })
    }
  }

  // TODO: handleClose
  const closeLock = useRef<boolean>(false);

  useEffect(() => {
    return () => {
      closeLock.current = true;
    }
  }, []);

  const handleClose = (type: string, streamID: number) => {
    if (type === 'close') {
      if (!currentHost || closeLock.current) return;

      const rtmClient = roomStore.rtmClient;
      const rtcClient = roomStore.rtcClient;
      const teacherUid = roomStore.state.course.teacherId;

      console.log("close rtmClient: ", rtmClient, ", rtcClient: ", rtcClient, ", teacherUid: ", teacherUid, ", lock :", closeLock.current);

      if (currentHost.streamID === +me.uid && teacherUid) {
        const quitClient = new Promise((resolve, reject) => {
          if (platform === 'electron') {
            const nativeClient = rtcClient as AgoraElectronClient;
            const val = nativeClient.unpublish();
            if (val >= 0) {
              resolve();
            } else {
              console.warn('quit native client failed');
              reject(val);
            }
          }
          if (platform === 'web') {
            const webClient = rtcClient as AgoraWebClient;
            resolve(webClient.unpublishLocalStream());
          }
        });
        closeLock.current = true;
        rtmLock.current = true;
        Promise.all([
          eduApi.studentStopCoVideo(
            roomStore.state.course.roomId
          ),
          quitClient
        ]).then(() => {
          globalStore.showToast({
            type: 'close_youself_co_video',
            message: t('toast.close_youself_co_video')
          })
          rtmLock.current = false;
        }).catch((err: any) => {
          rtmLock.current = false;
          console.warn(err);
          throw err;
        }).finally(() => {
          closeLock.current = false;
        })
      }

      if (`${teacherUid}` && `${teacherUid}` === `${me.uid}`) {
        rtmLock.current = true;
        closeLock.current = true;
        Promise.all([
          eduApi.teacherCancelStudent(
            roomStore.state.course.roomId,
            roomStore.state.applyUser.userId,
          )
        ]).then(() => {
          globalStore.showToast({
            type: 'peer_hands_up',
            message: t("toast.close_co_video")
          })
          roomStore.updateApplyUser({
            account: '',
            userId: '',
          })
          rtmLock.current = false;
        }).catch((err: any) => {
          rtmLock.current = false;
          console.warn(err);
        }).finally(() => {
          closeLock.current = false;
        })
      }
    }
  }
  
  return (
    <div className="room-container">
      <div className="live-container">
        <MediaBoard
          handleClick={handleClick}
        >
          <div className="video-container">
          {currentHost ? 
            <VideoPlayer
              role="teacher"
              streamID={currentHost.streamID}
              stream={currentHost.stream}
              domId={`${currentHost.streamID}`}
              id={`${currentHost.streamID}`}
              account={currentHost.account}
              handleClick={onPlayerClick}
              close={me.role === 1 || +me.uid === currentHost.streamID}
              handleClose={handleClose}
              video={currentHost.video}
              audio={currentHost.audio}
              local={currentHost.local}
              autoplay={Boolean(me.coVideo)}
            /> :
            null
          }
        </div>
        </MediaBoard>
      </div>
      <div className="live-board">
        <div className="video-board">
          {teacher ?
            <VideoPlayer
              role="teacher"
              streamID={teacher.streamID}
              stream={teacher.stream}
              domId={`dom-${teacher.streamID}`}
              id={`${teacher.streamID}`}
              account={teacher.account}
              handleClick={onPlayerClick}
              audio={Boolean(teacher.audio)}
              video={Boolean(teacher.video)}
              local={Boolean(teacher.local)}
              autoplay={Boolean(me.coVideo)}
              /> :
            <VideoPlayer
              role="teacher"
              account={'teacher'}
              streamID={0}
              video={true}
              audio={true}
              />}
        </div>
        <ChatBoard
          name={roomName}
          teacher={role === 1}
          messages={messages}
          mute={Boolean(roomState.course.muteChat)}
          value={value}
          roomCount={memberCount}
          sendMessage={sendMessage}
          handleChange={handleChange} />
      </div>
    </div>
  )
}
