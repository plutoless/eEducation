import React from 'react';
import VideoPlayer from '@/components/video-player';
import MediaBoard from '@/components/mediaboard';
import ChatBoard from '@/components/chat/board';
import useStream from '@/hooks/use-streams';
import useChatText from '@/hooks/use-chat-text';

export default function OneToOne() {
  const {
    value,
    messages,
    sendMessage,
    handleChange,    
  } = useChatText();

  const {teacher, students, onPlayerClick} = useStream();

  return (
    <div className="room-container">
      <MediaBoard />
      <div className="live-board">
        <div className="video-board">
          {teacher ?
            <VideoPlayer
              role="teacher"
              streamID={teacher.streamID}
              stream={teacher.stream}
              domId={`${teacher.streamID}`}
              id={`${teacher.streamID}`}
              account={teacher.account}
              handleClick={onPlayerClick}
              video={teacher.video}
              audio={teacher.audio}
              local={teacher.local}
              autoplay={true}
              /> :
            <VideoPlayer
              role="teacher"
              account={'teacher'}
              domId={'teacher'}
              streamID={0}
              video
              audio
              />}
          {students[0] ?
            <VideoPlayer
              role="student"
              streamID={students[0].streamID}
              stream={students[0].stream}
              domId={`${students[0].streamID}`}
              id={`${students[0].streamID}`}
              handleClick={onPlayerClick}
              account={students[0].account}
              video={students[0].video}
              audio={students[0].audio}
              local={students[0].local}
              autoplay={true}
            /> :
            <VideoPlayer
              role="student"
              account={"student"}
              domId={"student"}
              streamID={0}
              video={false}
              audio={false}
            />}
        </div>
        <ChatBoard
          messages={messages}
          value={value}
          sendMessage={sendMessage}
          handleChange={handleChange}
        />
      </div>
    </div>
  )
}