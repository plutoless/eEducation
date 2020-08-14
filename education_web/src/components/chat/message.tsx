import React from 'react';
import './index.scss';
import { Link } from 'react-router-dom';
import { useRoomState } from '@/containers/root-container';
import { t } from '@/i18n';
import { eduApi } from '@/services/edu-api';
import { roomStore } from '@/stores/room';
interface MessageProps {
  nickname: string
  content: string
  link?: string
  sender?: boolean
  children?: any
  ref?: any
  className?: string
}

export const Message: React.FC<MessageProps> = ({
  nickname,
  content,
  link,
  sender,
  children,
  ref,
  className
}) => {

  const roomState = useRoomState();

  const text = React.useMemo(() => {
    if (link && roomState.course.rid) {
      return (
        <Link to={`/replay/record/${link}?roomId=${roomState.course.roomId}&token=${eduApi.userToken}&senderId=${roomStore.state.me.uid}&channelName=${roomStore.state.course.rid}`} target="_blank">{t('course_recording')}</Link>
      )
    }
    return link ? link : content;
  }, [content, link, roomState.course.roomId])

  return (
  <div ref={ref} className={`message ${sender ? 'sent': 'receive'} ${className ? className : ''}`}>
    <div className="nickname">
      {nickname}
    </div>
    <div className="content">
      {text}
    </div>
    {children ? children : null}
  </div>
  )
}