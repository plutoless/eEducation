import React, {useRef } from 'react';
import './student-list.scss';
import Icon from './icon';
import { useRoomState } from '../containers/root-container';
import {roomStore, AgoraUser} from '../stores/room';
import { get } from 'lodash';

interface CustomIconProps {
  value: boolean
  type: string
  icon: string
  id: string
  onClick: (evt: any, id: string, type: string) => any
}

function CustomIcon ({
  value,
  icon,
  id,
  type,
  onClick
}: CustomIconProps) {
  const handleClick = (evt: any) => {
    onClick(evt, id, type);
  }
  return (
    <div className="items">
        {/* {value ? */}
          <Icon className={`icon-${icon}-${value ? "on" : "off"}`}
            onClick={handleClick}
            />
             {/* : null } */}
    </div>
  )
}

interface UserProps {
  uid: string
  account: string
  video: number
  audio: number
  chat: number
}

interface StudentListProps {
  list: AgoraUser[]
  role: number
}

export default function StudentList ({
  list,
  role
}: StudentListProps) {

  const state = useRoomState();

  const me = state.me;

  const lock = useRef<any>(false);

  const handleClick = (evt: any, id: string, type: string) => {
    if (!roomStore.state || !me) return;
    const targetUser = roomStore.state.users.get(`${id}`);
    if (!targetUser) return;
    if (!lock.current) {
      const val = Boolean(get(targetUser, type));
      lock.current = true;
      if (val) {
        roomStore.mute(targetUser.uid, type)
        .then(() => {
        }).catch(console.warn)
        .finally(() => {
          lock.current = false;
        });
      } else {
        roomStore.unmute(targetUser.uid, type)
        .then(() => {
        }).catch(console.warn)
        .finally(() => {
          lock.current = false;
        });
      }
    }
  }

  return (
    <div className="student-list">
      {list.map((item: AgoraUser, key: number) => (
        <div key={key} className="item">
          <div className="nickname">{item.account}</div>
          <div className="attrs-group">
            <CustomIcon type="grantBoard" id={item.uid} value={Boolean(item.grantBoard)} icon="connect" onClick={handleClick} />
            <CustomIcon type="chat" id={item.uid} value={Boolean(item.chat)} icon="chat" onClick={handleClick} />
            <CustomIcon type="audio" id={item.uid} value={Boolean(item.audio)} icon="audio" onClick={handleClick} />
            <CustomIcon type="video" id={item.uid} value={Boolean(item.video)} icon="video" onClick={handleClick} />
          </div>
        </div>
      ))}
    </div>
  )
}