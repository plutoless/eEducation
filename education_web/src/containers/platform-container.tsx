import React, { useEffect } from 'react';
import Icon from '../components/icon';
import _ from 'lodash';
import { useLocation } from 'react-router';

export interface IPlatformContext {
  platform: string
  NavBtn: React.FC<any>
  HomeBtn: React.FC<any>
  SettingBtn: React.FC<any>
}

export interface IWindow {
  ownerName: string
  name: string
  windowId: any
  image: string
}

const PlatformContext: React.Context<IPlatformContext> = React.createContext({} as IPlatformContext);

export const usePlatform = () => React.useContext(PlatformContext);

export const PlatformContainer: React.FC<React.ComponentProps<any>> = ({ children }: React.ComponentProps<any>) => {

  const platform = _.get(process.env, 'REACT_APP_RUNTIME_PLATFORM', 'web')


  const location = useLocation();

  // @ts-ignore
  const ipc = window.ipc;

  useEffect(() => {
    if (!ipc) return;
    if (location.pathname.match(/classroom|replay/)) {
      ipc.send('resize-window', {width: 990, height: 706});
    } else {
      ipc.send('resize-window', {width: 700, height: 500});
    }
  }, [location, ipc]);

  const handleClick = (type: string) => {

    if (!ipc) return;
    
    switch (type) {
      case 'minimum': {
        ipc.send('minimum');
        return;
      }
      case 'maximum': {
        ipc.send('maximum');
        return;
      }
      case 'close': {
        ipc.send('close');
        return;
      }
    }
  }

  const NavBtn: React.FC<any> = () => {
    if (platform === 'electron') {
      return (
        <div className="menu-group">
          <Icon className="icon-minimum" icon onClick={() => {
            handleClick("minimum")
          }} />
          <Icon className="icon-maximum" icon onClick={() => {
            handleClick("maximum")
          }} />
          <Icon className="icon-close" icon onClick={() => {
            handleClick("close")
          }} />
        </div>
      )
    }
    return null
  }

  const HomeBtn: React.FC<any> = ({handleSetting}: any) => {
    if (platform === 'electron') {
      return (<>
        <Icon className="icon-setting" onClick={handleSetting} />
        <div className="icon-container">
          <Icon className="icon-minimum" onClick={() => {
            handleClick("minimum")
          }}/>
          <Icon className="icon-close" onClick={() => {
            handleClick('close')
          }}/>
        </div>
      </>)
    }
    return null
  }

  const SettingBtn: React.FC<any> = () => {
    if (platform === 'electron') {
      return (
        <>
          <Icon className="icon-minimum" onClick={() => {
            handleClick("minimum")
          }}/>
          <Icon className="icon-close" onClick={() => {
            handleClick('close')
          }}/>
        </>
      )
    }
    return null;
  }

  const value = {
    platform,
    NavBtn,
    HomeBtn,
    SettingBtn
  }

  return (
    <PlatformContext.Provider value={value}>
      {children}
    </PlatformContext.Provider>
  )
}