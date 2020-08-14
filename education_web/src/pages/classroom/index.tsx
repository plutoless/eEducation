import React, { useEffect, useMemo, useRef } from 'react';
import { useHistory, useLocation } from 'react-router-dom';
import Nav from '@/components/nav';
import RoomDialog from '@/components/dialog';
import { AgoraStream } from '@/utils/types';
import './room.scss';
import NativeSharedWindow from '@/components/native-shared-window';
import { roomStore } from '@/stores/room';
import { useRoomState } from '@/containers/root-container';
import { globalStore } from '@/stores/global';
import { platform } from '@/utils/platform';
import { AgoraWebClient } from '@/utils/agora-web-client';
import { AgoraStreamSpec } from '@/utils/agora-rtc-client';
import { AgoraElectronClient, StreamType } from '@/utils/agora-electron-client';
import { t } from '@/i18n';
import { eduApi } from '@/services/edu-api';
import { genUUID } from '@/utils/api';
// import { useInterval } from 'react-use';

export const roomTypes = [
  {value: 0, path: 'one-to-one'},
  {value: 1, path: 'small-class'},
  {value: 2, path: 'big-class'},
];

// const delay = 5000

export function RoomPage({ children }: any) {

  const history = useHistory();

  const lock = useRef<boolean>(false);

  // useInterval(() => {
  //   roomStore.fetchRoomState()
  // }, delay)

  useEffect(() => {
    const me = roomStore.state.me;
    const course = roomStore.state.course;

    if (!me.account || !course.roomName) {
      history.push('/');
    }

    lock.current = true;
    if (roomStore.state.rtm.joined) return;
    globalStore.showLoading();
    roomStore.fetchCurrentRoom().then(() => {
    }).catch((err: any) => {
      if (err.reason) {
        globalStore.showToast({
          type: 'rtmClient',
          message: t('toast.rtm_login_failed_reason', {reason: err.reason}),
        })
      } else {
        globalStore.showToast({
          type: 'rtmClient',
          message: t('toast.rtm_login_failed'),
        })
      }
      console.warn(err)
    }).finally(() => {
      globalStore.stopLoading()
    })
  }, []);

  const roomType = roomTypes[roomStore.state.course.roomType];

  const location = useLocation();

  const roomState = useRoomState();
  const me = roomStore.state.me;
  // const course = roomStore.state.course;
  const classroom = Boolean(location.pathname.match(/classroom/));
  // const isBigClass = Boolean(location.pathname.match(/big-class/));
  const isSmallClass = Boolean(location.pathname.match(/small-class/));
  
  useEffect(() => {
    return () => {
      globalStore.removeUploadNotice();
      roomStore.exitAll()
      .then(() => {
      })
      .catch(console.warn)
      .finally(() => {
      });
    }
  }, [location]);

  const rtc = useRef<boolean>(false);
  
  const canPublish = useMemo(() => {
    return me.coVideo;
  }, [me.coVideo]);

  useEffect(() => {
    return () => {
      rtc.current = true
    }
  },[]);

  const publishLock = useRef<boolean>(false);

  const {rtcJoined, uid, role, mediaDevice} = useMemo(() => {
    return {
      rtcJoined: roomState.rtc.joined,
      uid: roomState.me.uid,
      role: roomState.me.role,
      mediaDevice: roomState.mediaDevice,
    }
  }, [roomState]);

  useEffect(() => {
    if (!location.pathname.match(/big-class/) || me.role === 1) return
    // if (course.linkId) return;
    const rtcClient = roomStore.rtcClient;
    if (platform === 'web') {
      const webClient = rtcClient as AgoraWebClient;
      if (!webClient.published) return;
      Promise.all([
        webClient
        .unpublishLocalStream()
      ])
        .then(() => {
          console.log("[agora-web] unpublish local stream");
        }).catch(console.warn)
    }

    if (platform === 'electron') {
      const nativeClient = rtcClient as AgoraElectronClient;
      if (!nativeClient.published) return;
      nativeClient.unpublish();
    }

  }, [me.role, location.pathname, canPublish]);

  useEffect(() => {
    if (!rtcJoined || rtc.current) return;

    if (platform === 'web') {
      const webClient = roomStore.rtcClient as AgoraWebClient;
      const uid = +roomStore.state.me.uid as number;
      const streamSpec: AgoraStreamSpec = {
        streamID: uid,
        video: true,
        audio: true,
        mirror: false,
        screen: false,
        microphoneId: mediaDevice.microphoneId,
        cameraId: mediaDevice.cameraId,
        audioOutput: {
          volume: mediaDevice.speakerVolume,
          deviceId: mediaDevice.speakerId
        }
      }
      console.log("canPb>>> ", canPublish, roomStore.state.me.uid);
      if (canPublish && !publishLock.current) {
        publishLock.current = true;
        Promise.all([
          webClient
          .publishLocalStream(streamSpec)
        ])
        .then((res: any[]) => {
          console.log("[agora-web] any: ", res[0], res[1]);
          console.log("[agora-web] publish local stream");
        }).catch(console.warn)
        .finally(() => {
          publishLock.current = false;
        })
      }
    }

    if (platform === 'electron' && rtcJoined) {
      const nativeClient = roomStore.rtcClient as AgoraElectronClient;
      if (canPublish && !publishLock.current) {
        publishLock.current = true;
        console.log("board updateLocal")
        nativeClient.publish();
        publishLock.current = false;
      }
    }
  }, [
    rtcJoined,
    uid,
    role,
    mediaDevice,
    canPublish,
  ]);

  useEffect(() => {
    if (!roomState.me.uid || !roomState.course.rid ||!roomState.appID) return;
    if (classroom) {
      if (platform === 'web') {
        const webClient = roomStore.rtcClient as AgoraWebClient;
        if (webClient.joined || rtc.current) {
          return;
        }
        console.log("[agora-rtc] add event listener");
        webClient.rtc.on('onTokenPrivilegeWillExpire', (evt: any) => {
          // you need obtain the `newToken` token from server side 
          eduApi.refreshToken().then((res: any) => {
            const newToken = res.rtcToken
            webClient.rtc.renewToken(newToken);
            console.log('[agora-web] onTokenPrivilegeWillExpire', evt);
          })
        });
        webClient.rtc.on('onTokenPrivilegeDidExpire', (evt: any) => {
          // you need obtain the `newToken` token from server side 
          eduApi.refreshToken().then((res: any) => {
            const newToken = res.rtcToken
            webClient.rtc.renewToken(newToken);
            console.log('[agora-web] onTokenPrivilegeDidExpire', evt);
          })
        });
        webClient.rtc.on('error', (evt: any) => {
          console.log('[agora-web] error evt', evt);
        });
        webClient.rtc.on('stream-published', ({ stream }: any) => {
          const _stream = new AgoraStream(stream, stream.getId(), true);
          roomStore.addLocalStream(_stream);
          roomStore.addRTCUser(stream.getId())
        });
        webClient.rtc.on('stream-subscribed', ({ stream }: any) => {
          const streamID = stream.getId();
          // when streamID is not share_id use switch high or low stream in dual stream mode
          if (location.pathname.match(/small-class/)) {
            if (roomStore.state.course.teacherId
              && roomStore.state.course.teacherId === `${streamID}`) {
              webClient.setRemoteVideoStreamType(stream, 0);
              console.log("[agora-web] dual stream set high for teacher");
            }
            else {
              webClient.setRemoteVideoStreamType(stream, 1);
              console.log("[agora-web] dual stream set low for student");
            }
          }
          const _stream = new AgoraStream(stream, stream.getId(), false);
          console.log("[agora-web] subscribe remote stream, id: ", stream.getId());
          roomStore.addRemoteStream(_stream);
        });
        webClient.rtc.on('stream-added', ({ stream }: any) => {
          console.log("[agora-web] added remote stream, id: ", stream.getId());
          webClient.subscribe(stream);
        });
        webClient.rtc.on('stream-removed', ({ stream }: any) => {
          console.log("[agora-web] removed remote stream, id: ", stream.getId());
          // const id = stream.getId();
          roomStore.removeRemoteStream(stream.getId());
        });
        webClient.rtc.on('peer-online', ({uid}: any) => {
          console.log("[agora-web] peer-online, id: ", uid);
          roomStore.addRTCUser(uid);
        });
        webClient.rtc.on('peer-leave', ({ uid }: any) => {
          console.log("[agora-web] peer-leave, id: ", uid);
          roomStore.removePeerUser(uid);
          roomStore.removeRemoteStream(uid);

          if (roomStore.state.me.role === 1 && roomStore.state.course.roomType === 2) {
            if (roomStore.state.applyUser.account) {
              globalStore.showToast({
                type: 'rtmClient',
                message: t('toast.student_peer_leave', {reason: roomStore.state.applyUser.account}),
              })
            }
          }
        });
        webClient.rtc.on("stream-fallback", ({ uid, attr }: any) => {
          const msg = attr === 0 ? 'resume to a&v mode' : 'fallback to audio mode';
          console.info(`[agora-web] stream: ${uid} fallback: ${msg}`);
        })
        rtc.current = true;
        // WARN: IF YOU ENABLED APP CERTIFICATE, PLEASE SIGN YOUR TOKEN IN YOUR SERVER SIDE AND OBTAIN IT FROM YOUR OWN TRUSTED SERVER API
        webClient
          .joinChannel({
            uid: +roomState.me.uid, 
            channel: roomState.course.rid,
            token: roomState.me.rtcToken,
            dual: isSmallClass,
            appId: roomState.appID,
          }).then(() => {
            
          }).catch(console.warn).finally(() => {
            rtc.current = false;
          });
        return () => {
          const events = [
            'onTokenPrivilegeWillExpire',
            'onTokenPrivilegeDidExpire',
            'error',
            'stream-published',
            'stream-subscribed',
            'stream-added',
            'stream-removed',
            'peer-online',
            'peer-leave',
            'stream-fallback'
          ]
          for (let eventName of events) {
            webClient.rtc.off(eventName, () => {});
          }
          console.log("[agora-web] remove event listener");
          !rtc.current && webClient.exit().then(() => {
            console.log("[agora-web] do remove event listener");
          }).catch(console.warn)
            .finally(() => {
              rtc.current = true;
              roomStore.removeLocalStream();
            });
        }
      }

      if (platform === 'electron') {
        const rtcClient = roomStore.rtcClient;
        const nativeClient = rtcClient as AgoraElectronClient;
        if (nativeClient.joined) {
          console.log("[agora-electron] electron joined ", nativeClient.joined);
          return;
        }
        nativeClient.on('executefailed', (...args: any[]) => {
          console.warn("[agora-electron] executefailed", ...args);
        });
        nativeClient.on('error', (evt: any) => {
          console.warn('[agora-electron] error evt', evt);
        });
        // when trigger `joinedchannel` it means publish rtc stream success
        nativeClient.on('joinedchannel', (evt: any) => {
          console.log("[agora-electron stream-published")
          const stream = evt.stream;
          const _stream = new AgoraStream(stream, stream.uid, true);
          roomStore.addLocalStream(_stream);
        });
        // when trigger `userjoined` it means peer user & peer stream is online
        nativeClient.on('userjoined', (evt: any) => {
          const stream = evt.stream;
          const _stream = new AgoraStream(stream, stream.uid, false);
          if (location.pathname.match(/small-class/) && +stream.uid !== +roomStore.state.course.screenId) {
            if (roomStore.state.course.teacherId
              && roomStore.state.course.teacherId === `${stream.uid}`) {
              const res = nativeClient.rtcEngine.setRemoteVideoStreamType(stream, 0);
              console.log("[agora-electron] dual stream set high for teacher, ", res);
            }
            else {
              const res = nativeClient.rtcEngine.setRemoteVideoStreamType(stream, 1);
              console.log("[agora-electron] dual stream set low for student, ", res);
            }
          }
          if (_stream && _stream.stream && +roomStore.state.course.screenId === +stream.uid) {
            if (+roomStore.state.course.screenId === +roomStore.state.me.screenId) {
              _stream.stream.type = StreamType.localVideoSource
            } else {
              _stream.stream.type = StreamType.remoteVideoSource
            }
          }
          roomStore.addRTCUser(stream.uid);
          roomStore.addRemoteStream(_stream);
        });
        // when trigger `removestream` it means peer user & peer stream is offline
        nativeClient.on('removestream', ({ uid }: any) => {
          roomStore.removePeerUser(uid);
          roomStore.removeRemoteStream(uid);
        });
        // WARN: IF YOU ENABLED APP CERTIFICATE, PLEASE SIGN YOUR TOKEN IN YOUR SERVER SIDE AND OBTAIN IT FROM YOUR OWN TRUSTED SERVER API
        nativeClient.joinChannel({
          uid: +roomState.me.uid, 
          channel: roomState.course.rid,
          token: roomState.me.rtcToken,
          dual: isSmallClass
        });
        roomStore.setRTCJoined(true);
        return () => {
          const events = [
            'executefailed',
            'error',
            'joinedchannel',
            'userjoined',
            'removestream',
          ]
          for (let eventName of events) {
            nativeClient.off(eventName, () => {})
          }
          !rtc.current && nativeClient.exit();
          !rtc.current && roomStore.setRTCJoined(false);
          !rtc.current && roomStore.removeLocalStream();
        }
      }
    }
  }, [JSON.stringify([roomState.me.uid, roomState.course.rid, roomState.appID])]);

  return (
    <div className={`classroom ${roomType.path}`}>
      <NativeSharedWindow />
      <Nav />
      {children}
      <RoomDialog />
    </div>
  );
}

