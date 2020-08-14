import React from 'react';
import ChatPanel from './panel';
import { ChatMessage } from '@/utils/types';
import { List } from 'immutable';

interface ChatBoard {
  name?: string
  messages: List<ChatMessage>
  value: string
  teacher?: boolean
  mute?: boolean
  roomCount?: number
  sendMessage: (evt: any) => void
  handleChange: (evt: any) => void
}

export default function ChatBoard (props: ChatBoard) {
  return (
    <div className="chat-board">
      {props.name ? <div className="chat-roomname">{props.name}{props.roomCount ? `(${props.roomCount})` : null }</div> : null}
        <ChatPanel
          messages={props.messages}
          value={props.value}
          sendMessage={props.sendMessage}
          handleChange={props.handleChange} />
    </div>
  )
}