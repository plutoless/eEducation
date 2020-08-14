import { useMemo } from 'react';
import { isEmpty } from 'lodash';
import { roomStore } from '../stores/room';
import { useRoomState } from '../containers/root-container';

type StreamValue = {
  teacher: any
  students: any[]
  sharedStream: any
  currentHost: any
  onPlayerClick: (type: string, streamID: number, uid: string) => Promise<any>
}


export default function useStream () {
  const roomState = useRoomState();
  const me = roomState.me;
  const course = roomState.course;

  const teacher = useMemo(() => {
    if (!course.teacherId || !me.uid) return;
    const teacherInfo = roomStore.state.users.get(`${course.teacherId}`);
    if (!teacherInfo) return;

    // 当本地流为老师时
    if (+me.uid === +course.teacherId) {
      return {
        ...roomState.rtc.localStream,
        account: teacherInfo.account,
        video: teacherInfo.video,
        audio: teacherInfo.audio,
        local: true,
      }
    } else {
      // when peer teacher is online
      // 当远端流为老师时
      const teacherUid = roomState.rtc.users.get(+course.teacherId);
      if(!teacherUid) return null;
      // when peer teacher stream is found
      // 当找到老师的音视频流时
      const remoteTeacherStream = roomState.rtc.remoteStreams.get(`${teacherUid}`);
      if (remoteTeacherStream) {
        return {
          ...remoteTeacherStream,
          account: teacherInfo.account,
          video: teacherInfo.video,
          audio: teacherInfo.audio,
        }
      }
      return {
        streamID: teacherUid,
        account: teacherInfo.account,
        video: teacherInfo.video,
        audio: teacherInfo.audio,
      }
    }
  }, [
    JSON.stringify(
      [
        course.teacherId,
        me.uid
      ]
    ),
    roomState.users,
    roomState.rtc.users,
    roomState.rtc.remoteStreams,
    roomState.rtc.localStream
  ]);

  const screenId = useMemo(() => {
    const teacher = roomState.users.get(`${course.teacherId}`)
    let id = ''
    if (teacher) {
      id = teacher.screenId
    }
    return id
  }, [course.teacherId, roomState.users])

  const students = useMemo(() => {
    const userAttrs = roomStore.state.users;
    if (!me.uid || userAttrs.count() === 0) return [];
    const teacherUid = course.teacherId;
    const peerUsers = roomState.rtc.users;
    // exclude teacher and me and screenId
    // 排除老师，屏幕共享，和自己的uid
    let studentIds = peerUsers.filter((it: number) => it !== +teacherUid && it !== +me.uid && it !== +screenId);

    const studentStreams: any[] = [];
    const myAttr = userAttrs.get(`${me.uid}`);

    // when i m student
    // 当自己是学生流时
    if (+me.role === 2) {
      if (myAttr && roomState.rtc.localStream) {
        const _tmpStream = {
          ...roomState.rtc.localStream,
          account: myAttr.account,
          video: myAttr.video,
          audio: myAttr.audio,
          local: true,
        }
        studentStreams.push(_tmpStream);
      }
    }

    // capture all remote streams
    // 所有远端的学生流
    for (let studentId of studentIds) {
      const studentAttr = userAttrs.get(`${studentId}`);
      const stream = roomState.rtc.remoteStreams.get(`${studentId}`);
      if (studentAttr) {
        let _tmpStream = {
          streamID: studentId,
          account: studentAttr.account,
          video: studentAttr.video,
          audio: studentAttr.audio,
        }
        if (stream) {
          _tmpStream = {
            ...stream,
            streamID: studentId,
            account: studentAttr.account,
            video: studentAttr.video,
            audio: studentAttr.audio,
          }
        }
        studentStreams.push(_tmpStream);
      }
    }
    return studentStreams;
  }, [
    JSON.stringify(
      [
        course.teacherId,
        screenId,
        me.uid
      ]
    ),
    roomState.users,
    roomState.rtc.users,
    roomState.rtc.remoteStreams,
    roomState.rtc.localStream
  ]);

  const sharedStream = useMemo(() => {
    if (roomState.rtc.localSharedStream) {
      const _tmpStream = {
        ...roomState.rtc.localSharedStream,
        video: 1,
        audio: 1,
        local: true,
      }
      return _tmpStream;
    }

    const remoteStream = roomState.rtc.remoteStreams.get(`${screenId}`);

    if (remoteStream) {
      const _tmpStream = {
        ...remoteStream,
        video: 1,
        audio: 1,
      }
      return _tmpStream;
    }

    return null;
  }, [
    screenId,
    roomState.rtc.remoteStreams,
    roomState.rtc.localSharedStream
  ]);

  const currentHost = useMemo(() => {
    if (!course.coVideoUids || isEmpty(course.coVideoUids)) return null;
    const coVideoUid = ''+course.coVideoUids[0];
    const userAttr = roomState.users.get(`${coVideoUid}`);
    if (!userAttr) return null;
    // when i am current broadcaster
    if (`${me.uid}` === coVideoUid) {
      if (roomState.rtc.localStream) {
        let _tmpStream = {
          ...roomState.rtc.localStream,
          account: userAttr.account,
          video: userAttr.video,
          audio: userAttr.audio,
          local: true,
          streamID: +me.uid,
        }
        return _tmpStream;
      }
    } else {
      // when remote user is broadcaster
      const peerUid = coVideoUid;
      const peerUserAttr = roomState.users.get(`${peerUid}`);
      if (peerUid && peerUserAttr) {
        let tmpStream = {
          account: peerUserAttr.account,
          video: peerUserAttr.video,
          audio: peerUserAttr.audio,
          streamID: +peerUid,
        }
        const remoteStream = roomState.rtc.remoteStreams.get(`${peerUid}`);
        if (remoteStream) {
          tmpStream = {
            ...tmpStream,
            ...remoteStream
          }
        }
        return tmpStream
      }
    }
    return null;
  }, [
    course.coVideoUids,
    me.uid,
    me.role,
    roomState.users,
    roomState.rtc.remoteStreams,
    roomState.rtc.localStream,
  ]);

  const value: StreamValue = {
    teacher: teacher,
    students: students,
    sharedStream: sharedStream,
    currentHost: currentHost,
    onPlayerClick: async (type: string, streamID: number, uid: string) => {
      console.log("streamID ", streamID, uid);
      const me = roomStore.state.me;
      if (!roomStore.state.rtm.joined || !me.uid) return console.warn("please confirm joined rtm");
      const targetUser = roomStore.state.users.get(`${uid}`);
      if (!targetUser) return;

      const targetUid = targetUser.uid;

      const video = Boolean(targetUser.video);
      const audio = Boolean(targetUser.audio);
      const chat = Boolean(targetUser.chat);

      if (type === 'video') {
        if (video) {
          await roomStore.mute(targetUid, 'video');
        } else {
          await roomStore.unmute(targetUid, 'video');
        }
        return;
      }

      if (type === 'audio') {
        if (audio) {
          await roomStore.mute(targetUid, 'audio');
        } else {
          await roomStore.unmute(targetUid, 'audio');
        }
        return;
      }

      if (type === 'chat') {
        if (chat) {
          await roomStore.mute(targetUid, 'chat');
        } else {
          await roomStore.unmute(targetUid, 'chat');
        }
        return;
      }
    }
  }
  return value;
}