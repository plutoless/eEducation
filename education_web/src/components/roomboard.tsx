import React, {useState} from 'react';
import ChatPanel from './chat/panel';
import StudentList from './student-list';
import useChatText from '../hooks/use-chat-text';
import { t } from '../i18n';
import { useGlobalState } from '../containers/root-container';
import { globalStore } from '../stores/global';

export default function Roomboard (props: any) {
  const {
    role, list, value,
    messages, sendMessage, handleChange
  } = useChatText();

  const {active} = useGlobalState();

  const [visible, setVisible] = useState(true);

  const toggleCollapse = (evt: any) => {
    setVisible(!visible);
  }

  const count = active !== 'chatroom' ? globalStore.state.newMessageCount : 0;

  return (
    <>
    <div className={`${visible ? "icon-collapse-off" : "icon-collapse-on" } fixed`} onClick={toggleCollapse}></div>
    {visible ? 
    <div className={`small-class chat-board`}>
      <div className="menu">
        <div onClick={() => { globalStore.setActive('chatroom') }} className={`item ${active === 'chatroom' ? 'active' : ''}`}>
          {t('room.chat_room')}
          {active !== 'chatroom' && count > 0 ? <span className={`message-count ${globalStore.state.language}`}>{count}</span> : null}
        </div>
        <div onClick={() => { globalStore.setActive('studentList') }} className={`item ${active === 'studentList' ? 'active' : ''}`}>{t('room.student_list')}</div>
      </div>
      <div className={`chat-container ${active === 'chatroom' ? '' : 'hide'}`}>
        <ChatPanel
          messages={messages}
          value={value}
          sendMessage={sendMessage}
          handleChange={handleChange} />
      </div>
      <div className={`student-container ${active !== 'chatroom' ? '' : 'hide'}`}>
        <StudentList
          role={role}
          list={list}
        />
      </div>
    </div>
    : null}
    </>
  )
}