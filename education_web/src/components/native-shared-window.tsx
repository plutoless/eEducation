import React from 'react';
import './native-shared-window.scss';
import Button from './custom-button';
import { usePlatform } from '../containers/platform-container';
import { AgoraElectronClient } from '../utils/agora-electron-client';
import { AgoraStream } from '../utils/types';
import { globalStore } from '../stores/global';
import { roomStore } from '../stores/room';
import { useGlobalState } from '../containers/root-container';
import { eduApi } from '../services/edu-api';
import { t } from '../i18n';

export const WindowItem: React.FC<any> = ({
  ownerName,
  name,
  className,
  windowId,
  image,
}) => {

  return (
    <div className={className ? className : ''} >
      <div className="screen-image">
        <div className="content" style={{ backgroundImage: `url(data:image/png;base64,${image})` }}>
        </div>
      </div>
      <div className="screen-meta">{name}</div>
    </div>
  )
}

export interface WindowListProps {
  title: string
  items: any[]
  windowId: number
  selectWindow: (windowId: any) => void
  confirm: (evt: any) => void
  cancel: (evt: any) => void
}

export const WindowList: React.FC<WindowListProps> = ({
  title,
  items,
  windowId,
  selectWindow,
  confirm,
  cancel
}) => {
  return (
    <div className="window-picker-mask">
      <div className="window-picker">
        <div className="header">
          <div className="title">{title}</div>
          <div className="cancelBtn" onClick={cancel}></div>
        </div>
        <div className='screen-container'>
          {
            items.map((it: any, key: number) =>
              <div className="screen-item" 
                key={key}
                onClick={() => {
                  selectWindow(it.windowId);
                }}
                onDoubleClick={confirm}
                >
                <WindowItem
                  ownerName={it.ownerName}
                  name={it.name}
                  className={`window-item ${it.windowId === windowId ? 'active' : ''}`}
                  windowId={it.windowId}
                  image={it.image}
                />
              </div>
            )
          }
        </div>
        <div className='footer'>
          <Button className={'share-confirm-btn'} name={"start"}
            onClick={confirm} />
        </div>
      </div>
    </div>
  )
}

export default function NativeSharedWindowContainer() {

  const {
    platform
  } = usePlatform();

  const globalState = useGlobalState();
  const nativeWindowInfo = globalState.nativeWindowInfo;
  const [windowId, setWindowId] = React.useState<any>('');

  return (
    nativeWindowInfo.visible ? 
    <WindowList
      windowId={windowId}
      title={'Please select and click window for share'}
      items={nativeWindowInfo.items}
      cancel={() => {
        globalStore.setNativeWindowInfo({visible: false, items: []});
      }}
      selectWindow={(windowId: any) => {
        setWindowId(windowId)
      }}
      confirm={async (evt: any) => {
        if (!windowId) {
          console.warn("windowId is empty");
          return;
        }
        try {
          if (platform === 'electron') {
            globalStore.showLoading();
            const rtcClient = roomStore.rtcClient;
            const nativeClient = rtcClient as AgoraElectronClient;
            // screen share token
            let {screenToken} = await eduApi.refreshToken();
            let electronStream = await nativeClient.startScreenShare(
              windowId,
              +roomStore.state.course.screenId,
              roomStore.state.course.rid,
              screenToken,
              roomStore.state.appID,
            );
            roomStore.addLocalSharedStream(new AgoraStream(electronStream, electronStream.uid, true));
          }
        } catch(err) {
          const rtcClient = roomStore.rtcClient;
          const nativeClient = rtcClient as AgoraElectronClient;
          nativeClient.releaseScreenShare()
          globalStore.showToast({
            type: 'nativeScreenShare',
            message: t("electron.start_screen_share_failed")
          })
          console.warn(JSON.stringify(err))
          throw err;
        } finally {
          globalStore.stopLoading();
          globalStore.setNativeWindowInfo({visible: false, items: []});
        }
      }}
    />
    : null
  )
}