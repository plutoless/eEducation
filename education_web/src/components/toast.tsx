import React, { useEffect, useRef, useState } from 'react';
import './toast.scss';
import {useGlobalState} from '../containers/root-container';
import { isEmpty } from 'lodash';

export interface SnackbarMessage {
  message: string;
  key: number;
}

interface SnackbarsProps {
  duration?: number
}

export default function ConsecutiveSnackbars({
  duration = 2500
}: SnackbarsProps) {

  const globalState = useGlobalState();

  const queueRef = React.useRef<SnackbarMessage[]>([]);
  const [messages, setMessages] = useState<SnackbarMessage[]>([]);
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
    if (queueRef.current && globalState.toast.message) {
      queueRef.current.push({
        message: globalState.toast.message,
        key: +Date.now()
      })
      setMessages([...queueRef.current]);
    }
  }, [globalState.toast]);

  return (
    <div className="notice-message-container">
      {messages.map((message: any, idx: number) => 
        <div key={`${idx}${message.key}`} className={"custom-toast"}>
          <div className="toast-container">
            <span className="text">{message.message}</span>
          </div>
        </div>
      )}
    </div>
  )
}
