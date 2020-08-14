import React, { useRef, useEffect, useState } from 'react';

import './upload-notice.scss';
import { useGlobalState } from '@/containers/root-container';

type UploadNoticeProps = {
  title: string
  type: string
}

const UploadNotice: React.FC<UploadNoticeProps> = ({
  type,
  title
}) => {
  return (
    <div className={`notice-container ${type}`}>
      <span className={`icon-${type}`}></span>
      <span className="title">{title}</span>
    </div>
  )
}

export interface NoticeMessage {
  title: string
  key?: number
  type: string
}

type NoticeContext = {
  state: NoticeMessage
  Notice: (state: NoticeMessage) => any
}

const UploadNoticeContext = React.createContext({} as NoticeContext);

export const useUploadNotice = () => React.useContext(UploadNoticeContext);

const duration = 2500;

export const UploadNoticeContainer: React.FC<{}> = () => {

  const globalState = useGlobalState();

  const uploadNotice = globalState.uploadNotice;

  const queueRef = React.useRef<NoticeMessage[]>([]);
  const [messages, setMessages] = useState<NoticeMessage[]>([]);
  const timerRef = useRef<any>(null);

  useEffect(() => {
    if (messages.length > 0 && timerRef.current === null) {
      timerRef.current = setTimeout(() => {
        queueRef.current.shift()
        setMessages([...queueRef.current]);
        timerRef.current = null;
      }, duration);
    }
  }, [messages]);

  useEffect(() => {
    if (!uploadNotice.title || !uploadNotice.type) return;
    if (queueRef.current) {
      queueRef.current.push({
        ...uploadNotice,
        key: +Date.now()
      })
      setMessages([...queueRef.current]);
    }
  }, [uploadNotice]);

  return (
    <div className="upload-notice">
      {messages.map((it: any, idx: number) => 
        <UploadNotice key={`${idx}${it.key}`}
          type={it.type}
          title={it.title}
        />
      )}
    </div>
  )
}

export const UploadNoticeView = React.memo(UploadNoticeContainer);