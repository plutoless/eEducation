import React, { useState, useEffect, useRef } from 'react';
import Icon from './icon';
import SettingCard from '../components/setting-card';
import './nav.scss';
import Button from './custom-button';
import * as moment from 'moment';
import { ClassState } from '../utils/types';
import { NetworkQualityEvaluation } from '../utils/helper';
import { usePlatform } from '../containers/platform-container';
import {AgoraWebClient} from '../utils/agora-web-client';
import { AgoraElectronClient } from '../utils/agora-electron-client';
import { isElectron, platform } from '../utils/platform';
import { useRoomState } from '../containers/root-container';
import { roomStore } from '../stores/room';
import { globalStore } from '../stores/global';
import { t } from '../i18n';
import Log from '../utils/LogUploader';
import { Tooltip } from '@material-ui/core';

interface NavProps {
  delay: string
  network: string
  cpu: string
  role: number
  roomName: string
  time: number
  showSetting: boolean
  classState: boolean
  onCardConfirm: (type: string) => void
  handleClick: (type: string) => void
}

const networkQualityIcon: {[key: string]: string} = {
  'excellent': 'network-good',
  'good': 'network-good',
  'poor': 'network-normal',
  'bad': 'network-normal',
  'very bad': 'network-bad',
  'down': 'network-bad',
  'unknown': 'network-bad',
}

export function Nav ({
  delay,
  network,
  cpu,
  role,
  roomName,
  time,
  handleClick,
  showSetting,
  classState,
  onCardConfirm,
}: NavProps) {

  const {NavBtn} = usePlatform();
    
  const handleFinish = (evt: any) => {
    onCardConfirm('setting');
  }

  return (
    <>
    <div className={`nav-container ${isElectron ? 'draggable' : ''}`}>
      <div className="class-title">
        <span className="room-name">{roomName}</span>
        {+role === 1 ? 
          <Button className={`nav-button ${classState ? "stop" : "start"}`} name={classState ? t('nav.class_end') : t('nav.class_start')} onClick={(evt: any) => {
            handleClick("classState")
          }} /> : null}
      </div>
      <div className="network-state">
        {platform === 'web' ? <span className="net-field">{t('nav.delay')}<span className="net-field-value">{delay}</span></span> : null}
        {/* <span className="net-field">Packet Loss Rate: <span className="net-field-value">{lossPacket}</span></span> */}
        <span className="net-field net-field-container">
          {t('nav.network')}
          <span className={`net-field-value ${networkQualityIcon[network]}`} style={{marginLeft: '.2rem'}}>
          </span>
        </span>
        {platform === 'electron' ? <span className="net-field">{t('nav.cpu')}<span className="net-field-value">{cpu}</span></span> : null}
      </div>
      <div className="menu">
        <div className="timer">
          <Icon className="icon-time" disable />
          <span className="time">{moment.utc(time).format('HH:mm:ss')}</span>
        </div>
        <span className="menu-split" />
        <div className={platform === 'web' ? "btn-group" : 'electron-btn-group' }>
          {platform === 'web' ?
            <>
            <Tooltip title={t("icon.setting")} placement="bottom">
              <span>
                <Icon className="icon-setting" onClick={(evt: any) => {
                  handleClick("setting");
                }}/>
              </span>
            </Tooltip>

            </> : null
          }
          <Tooltip title={t("icon.upload-log")} placement="bottom">
            <span>
              <Icon className={globalStore.state.lock ? "icon-loading" : "icon-upload"} onClick={(evt: any) => {
                handleClick('uploadLog')
              }}></Icon>
            </span>
          </Tooltip>
          <Tooltip title={t("icon.exit-room")} placement="bottom">
            <span>
              <Icon className="icon-exit" onClick={(evt: any) => {
                handleClick("exit");
              }} />
            </span>
          </Tooltip>
        </div>
        <NavBtn />
      </div>
    </div>
    {showSetting ? 
      <SettingCard className="internal-card"
        handleFinish={handleFinish} /> : null
    }
    </>
  )
}

export default function NavContainer() {
  const {
    platform
  } = usePlatform();

  const ref = useRef<boolean>(false);

  const [time, updateTime] = useState<number>(0);

  const [timer, setTimer] = useState<any>(null);

  const calcDuration = (time: number) => {
    return setInterval(() => {
      !ref.current && updateTime(+Date.now() - time);
    }, 150, time)
  }

  const [card, setCard] = useState<boolean>(false);

  const [rtt, updateRtt] = useState<number>(0);
  const [quality, updateQuality] = useState<string>('unknown');
  const [cpuUsage, updateCpuUsage] = useState<number>(0);

  useEffect(() => {
    return () => {
      ref.current = true;
      if (timer) {
        clearInterval(timer);
        setTimer(null);
      }
    }
  }, []);

  const roomState = useRoomState();

  const me = roomState.me;

  useEffect(() => {
    const rtcClient = roomStore.rtcClient;
    if (platform === 'web') {
      const webClient = rtcClient as AgoraWebClient;
      webClient.rtc.on('watch-rtt', (rtt: number) => {
        !ref.current && updateRtt(rtt);
      });
      webClient.rtc.on('network-quality', (evt: any) => {
        const quality = NetworkQualityEvaluation(evt);
        !ref.current && updateQuality(quality);
      })
      return () => {
        webClient.rtc.off('watch-rtt', () => {});
        webClient.rtc.off('network-quality', () => {});
      }
    }
    if (platform === 'electron') {
      const nativeClient = rtcClient as AgoraElectronClient;
      nativeClient.on('rtcStats', ({cpuTotalUsage}: any) => {
        !ref.current && updateCpuUsage(cpuTotalUsage);
      });
      nativeClient.on('networkquality', (
        uid: number,
        txquality: number,
        rxquality: number) => {
        if (uid === 0) {
          const quality = NetworkQualityEvaluation({
            downlinkNetworkQuality: rxquality,
            uplinkNetworkQuality: txquality,
          });
          !ref.current && updateQuality(quality);
        }
      })

      return () => {
        nativeClient.off('rtcStats', () => {});
        nativeClient.off('networkquality', () => {});
        nativeClient.off('audioquality', () => {});
      }
    }
  }, []);

  const courseState = roomState.course.courseState;
  const course = roomState.course;

  useEffect(() => {
    if (courseState === ClassState.STARTED
      && timer === null) {
        const now: number = +Date.now();
        setTimer(calcDuration(now));
    }
    if (timer && courseState === ClassState.CLOSED) {
      clearInterval(timer);
      setTimer(null);
    }
  }, [courseState]);

  const lock = useRef<boolean>(false);

  useEffect(() => {
    return () => {
      lock.current = true;
    }
  }, []);

  const updateClassState = () => {
    if (!lock.current) {
      lock.current = true;
      roomStore.updateCourse({
        courseState: +!Boolean(roomStore.state.course.courseState)
      }).then(() => {
        console.log("update success");
      }).catch(console.warn)
      .finally(() => {
        lock.current = false;
      })
    }
  };

  const handleClick = (type: string) => {
    if (type === 'setting') {
      setCard(true);
    } else if (type === 'exit') {
      globalStore.showDialog({
        type: 'exitRoom',
        message: t('toast.quit_room'),
      });
    } else if (type === 'classState') {
      updateClassState();
    } else if (type === 'uploadLog') {
      globalStore.lock()
      Log.doUpload().then((resultCode: any) => {
        globalStore.showDialog({
          type: 'uploadLog',
          message: t('toast.show_log_id', {reason: `${resultCode}`})
        });
      }).finally(() => {
        globalStore.unlock()
      })
    }
  }

  const handleCardConfirm = (type: string) => {
    switch (type) {
      case 'setting':
        setCard(false);
        return;
      case 'exitRoom':
        globalStore.removeDialog();
        return;
    }
  }

  return (
    <Nav 
      role={me.role}
      roomName={course.roomName}
      classState={Boolean(course.courseState)}
      delay={`${rtt}ms`}
      time={time}
      network={`${quality}`}
      cpu={`${cpuUsage}%`}
      showSetting={card}
      onCardConfirm={handleCardConfirm}
      handleClick={handleClick}
    />
  )
}