import React, { useRef } from 'react';
import Icon from '../icon';
import { roomStore } from '@/stores/room';
import { whiteboard } from '@/stores/whiteboard';
import moment from 'moment';
import { globalStore } from '@/stores/global';
import { t } from '@/i18n';
import { Tooltip } from '@material-ui/core';
import { useRoomState } from '@/containers/root-container';
interface ControlItemProps {
  name: string
  onClick: (evt: any, name: string) => void
  active: boolean
  text?: string
  loading?: boolean
}

const ControlItem = (props: ControlItemProps) => {
  const onClick = (evt: any) => {
    props.onClick(evt, props.name);
  }
  return (
    props.text ?
      <div className={`control-btn control-${props.name} ${props.loading ? 'icon-loading' : ''}`} onClick={onClick}>
        <div className={`btn-icon ${props.name} ${props.active ? 'active' : ''}`}
          data-name={props.name} />
        <div className="control-text">{props.text}</div>
      </div>
      :
      <Icon
        loading={props.loading}
        data={props.name}
        onClick={onClick}
        className={`items ${props.name} ${props.active ? 'active' : ''}`}
      />
  )
}

interface NoticeProps {
  reason: string
  text?: string
}

interface ControlProps {
  sharing: boolean
  isHost?: boolean
  current: string
  currentPage: number
  totalPage: number
  role: number
  notice?: NoticeProps
  onClick: (evt: any, type: string) => void
}

export default function Control({
  sharing,
  isHost,
  current,
  currentPage,
  totalPage,
  onClick,
  role,
  notice,
}: ControlProps) {

  const roomState = useRoomState();
  const lock = useRef<boolean>(false);

  const canStop = () => {
    const timeMoment = moment(whiteboard.state.startTime).add(15, 'seconds');
    if (+timeMoment >= +Date.now()) {
      globalStore.showToast({
        type: 'netlessClient',
        message: t('toast.recording_too_short')
      })
      return false;
    }
    return true;
  }

  const onRecordButtonClick = (evt: any, type: string) => {
    handleRecording(evt, type)
    .then(() => {}).catch(console.warn);
  }
  
  const handleRecording = async (evt: any, type: string) => {
    try {
      const roomState = roomStore.state;
      const me = roomState.me;
      if (lock.current || !me.uid) return;
  
      if (roomState.course.isRecording) {
        if (!canStop()) return;
        await roomStore.stopRecording();
        globalStore.showToast({
          type: 'recording',
          message: t('toast.stop_recording'),
        });
      } else {
        await roomStore.startRecording();
        globalStore.showToast({
          type: 'recording',
          message: t('toast.start_recording'),
        });
      }
    } catch(err) {
      if (err.recordingErr) {
        globalStore.showToast({
          type: 'recordingErr',
          message: t('toast.recording_failed', {reason: err.recordingErr.message})
        });
      }
    }
  }

  return (
    <div className="controls-container">
      <div className="interactive">
      {notice && roomState.users.count() <= 1 ?
          <ControlItem name={notice.reason}
            onClick={onClick}
            active={notice.reason === current} />
        : null}
      </div>
      <div className="controls">
        {!sharing && role === 1 ?
          <>
            <Tooltip title={t(`control_items.first_page`)} placement="top">
              <span>
                <ControlItem name={`first_page`}
                  active={'first_page' === current}
                  onClick={onClick} />
              </span>
            </Tooltip>
            <Tooltip title={t(`control_items.prev_page`)} placement="top">
              <span>
                <ControlItem name={`prev_page`}
                  active={'prev_page' === current}
                  onClick={onClick} />
              </span>
            </Tooltip>
            <div className="current_page">
              <span>{currentPage}/{totalPage}</span>
            </div>
            <Tooltip title={t(`control_items.next_page`)} placement="top">
              <span>
                <ControlItem name={`next_page`}
                  active={'next_page' === current}
                  onClick={onClick} />
              </span>
            </Tooltip>
            <Tooltip title={t(`control_items.last_page`)} placement="top">
              <span>
                <ControlItem name={`last_page`}
                  active={'last_page' === current}
                  onClick={onClick} />
              </span>
            </Tooltip>
            <div className="menu-split" style={{ marginLeft: '7px', marginRight: '7px' }}></div>
          </> : null
        }
        {+role === 1 ?
          <>
            <Tooltip title={t(roomStore.state.course.isRecording ? 'control_items.stop_recording' : 'control_items.recording')} placement="top">
              <span>
                <ControlItem
                  loading={Boolean(roomStore.state.recordLock)}
                  name={Boolean(roomStore.state.recordLock) ? 'icon-loading ' : (roomStore.state.course.isRecording ? 'stop_recording' : 'recording')}
                  onClick={onRecordButtonClick}
                  active={false}
                />
              </span>
            </Tooltip>
            <Tooltip title={t(sharing ? 'control_items.quit_screen_sharing' : 'control_items.screen_sharing')} placement="top">
              <span>
                <ControlItem
                  name={sharing ? 'quit_screen_sharing' : 'screen_sharing'}
                  onClick={(evt: any) => {
                    if (sharing) {
                      roomStore.stopScreenShare()
                      .then(() => {
                        console.log("stop screen share")
                      }).catch(console.warn)
                    } else {
                      roomStore.startScreenShare()
                      .then(() => {
                        console.log("start screen share")
                      }).catch(console.warn)
                    }
                  }}
                  active={false}
                  text={sharing ? 'stop sharing' : ''}
                />
              </span>
            </Tooltip>
          </> : null }
        {+role === 2 ?
          <>
            <ControlItem
              name={isHost ? 'hands_up_end' : 'hands_up'}
              onClick={onClick}
              active={false}
              text={''}
            />
          </>
         :null}
      </div>

    </div>
  )
}