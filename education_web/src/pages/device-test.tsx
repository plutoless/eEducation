import React, { useEffect } from 'react';
import {useHistory} from 'react-router-dom';
import SettingCard from '../components/setting-card';
import { isElectron } from '../utils/platform';
import { roomStore } from '../stores/room';
import {AgoraWebClient} from '../utils/agora-web-client';
import {platform} from '../utils/platform';

function DeviceTest() {
  const history = useHistory();

  const handleClick = (evt: any) => {
    history.push('/')
  }

  useEffect(() => {
    if (platform === 'web') {
      const webClient = roomStore.rtcClient as AgoraWebClient;
      return () => {
        if (webClient.tmpStream) {
          webClient.tmpStream.isPlaying() && webClient.tmpStream.stop();
          webClient.tmpStream.close();
        }
      }
    }
  }, []);

  return (
    <div className={`flex-container ${isElectron ? 'draggable' : 'home-cover-web'}`}>
      <SettingCard handleFinish={handleClick} />
    </div>
  )
}

export default React.memo(DeviceTest);