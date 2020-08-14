import React, { useState } from 'react';
import '../classroom/room.scss';
import { isElectron } from '@/utils/platform';
import '@/components/nav.scss';
import { Tooltip } from '@material-ui/core';
import { t } from '@/i18n';
import { globalStore } from '@/stores/global';
import Log from '@/utils/LogUploader';
import { usePlatform } from '@/containers/platform-container';
import Icon from '@/components/icon';

const MenuNav = () => {

  const [loading, setLoading] = useState<boolean>(false)

  const {NavBtn} = usePlatform();

  const handleClick = (type: string) => {
    if (type === 'exit') {
      globalStore.showDialog({
        type: 'exitRoom',
        message: t('toast.quit_room'),
      });
    } else if (type === 'uploadLog') {
      setLoading(true)
      Log.doUpload().then((resultCode: any) => {
        globalStore.showDialog({
          type: 'uploadLog',
          message: t('toast.show_log_id', { reason: `${resultCode}` })
        });
      }).finally(() => {
        setLoading(false)
      })
    }
  }
  return (
    <div className={`nav-container menu-nav ${isElectron ? 'draggable' : ''}`}>
      <div className="menu-nav-right">
        {/* <Tooltip title={t("icon.upload-log")} placement="bottom">
          <div>
            <Icon className={loading ? "icon-loading" : "icon-upload"} onClick={(evt: any) => {
              handleClick('uploadLog')
            }}></Icon>
          </div>
        </Tooltip> */}
        <NavBtn />
      </div>
    </div>
  )
}

export function ReplayPageWrapper({ children }: any) {
  return (
    <>
    {isElectron ? 
      <div className="replay-page-wrapper">
        <MenuNav />
        {children}
      </div>
      : children
    }
    </>
  );
}

