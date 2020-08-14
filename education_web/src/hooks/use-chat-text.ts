import { useState, useMemo } from 'react';
import { useRoomState } from '../containers/root-container';
import { roomStore, AgoraUser } from '../stores/room';

export default function useChatText () {
  const [value, setValue] = useState('');

  const roomState = useRoomState();

  const roomName = roomState.course.roomName;

  const me = roomState.me;

  const role = me.role;

  const messages = useMemo(() => {
    return roomState.messages;
  }, [roomState.messages]);

  const rtmClient = roomStore.rtmClient;

  const sendMessage = async (content: string) => {
    if (rtmClient &&  me.uid) {
      if (me.role !== 1 && (!me.chat || Boolean(roomState.course.muteChat))) return console.warn("chat already muted");
      if (me.role === 1 && !me.chat) return console.warn("chat already muted");
      await roomStore.sendChannelMessage({
        message: content,
      });
      const message = {
        account: me.account,
        id: me.uid,
        text: content,
        ts: +Date.now()
      }
      roomStore.updateChannelMessage(message);
      setValue('');
    }
  }

  const handleChange = (evt: any) => {
    setValue(evt.target.value.slice(0, 100));
  }
  const list = useMemo(() => {
    if (!roomState.me.uid || !roomState.rtc.users.count() && !roomState.rtc.localStream) return [];
    const my = roomState.users.get(roomState.me.uid);
    const users = [];
    if (my) {
      users.push(my);
    }
    for (let id of roomState.rtc.users) {
      const user = roomState.users.get(''+id);
      if (user) {
        users.push(user);
      }
    }
    return users.filter((user: AgoraUser) => +user.role === 2);
  }, [roomState.me.uid, roomState.rtc.users, roomState.users, roomState.rtc.localStream]);

  return {
    list,
    role,
    messages,
    sendMessage,
    value,
    handleChange,
    roomName
  }
}