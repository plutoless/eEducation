import React, {useMemo} from 'react';
import Button from '../custom-button';
import {Dialog, DialogContent, DialogContentText} from '@material-ui/core';

import './dialog.scss';
import { useGlobalState } from '@/containers/root-container';
import { roomStore } from '@/stores/room';
import { globalStore } from '@/stores/global';
import { useHistory } from 'react-router-dom';
// import { RoomMessage } from '@/utils/agora-rtm-client';
import { t } from '@/i18n';
import { isElectron } from '@/utils/platform';
import { eduApi } from '@/services/edu-api';

interface RoomProps {
  onConfirm: (type: string) => void
  onClose: (type: string) => void
  desc: string
  type: string
}

function RoomDialog(
{
  onConfirm,
  onClose,
  desc,
  type
}: RoomProps) {

  const handleClose = () => {
    onClose(type)
  };

  const handleConfirm = () => {
    onConfirm(type)
  }

  return (
    <div>
      <Dialog
        disableBackdropClick
        open={true}
        onClose={handleClose}
        aria-labelledby="alert-dialog-title"
        aria-describedby="alert-dialog-description"
      >
        <DialogContent
          className="modal-container"
        >
          <DialogContentText className="dialog-title">
            {desc}
          </DialogContentText>
          <div className="button-group">
            <Button name={t("toast.confirm")} className="confirm" onClick={handleConfirm} color="primary" />
            <Button name={t("toast.cancel")} className="cancel" onClick={handleClose} color="primary" />
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

const DialogContainer = () => {

  const history = useHistory();
  const {dialog} = useGlobalState();

  const visible = useMemo(() => {
    if (!dialog.type) return false;
    return true;
  }, [dialog]);

  const onClose = (type: string) => {
    if (type === 'exitRoom') {
      globalStore.removeDialog();
    }
    else if (type === 'apply') {
      eduApi
      .teacherRejectApply(
        roomStore.state.course.roomId,
        roomStore.state.applyUser.userId,
      )
      .then(() => {
        globalStore.showToast({
          type: 'peer_hands_up', 
          message: t('toast.reject_co_video')
        });
        globalStore.removeNotice();
        globalStore.removeDialog();
      })
      .catch((err: any) => {
        console.warn(err)
      })
    } else if (type === 'uploadLog') {
      globalStore.removeDialog()
    }
  }

  const onConfirm = (type: string) => {
    if (type === 'exitRoom') {
      globalStore.showLoading()
      roomStore.exitRoom().finally(() => {
        globalStore.removeDialog();
        globalStore.stopLoading()
        if (isElectron) {
          history.push('/')
        } else {
          history.goBack()
        }
      })
    }
    else if (type === 'apply') {
      // p2p message accept coVideo
      // 老师同意学生连麦申请
      eduApi.teacherAcceptApply(roomStore.state.course.roomId, roomStore.state.applyUser.userId)
        .then(() => {
          globalStore.showToast({
            type: 'peer_hands_up', 
            message: t('toast.accept_co_video')
          });
          globalStore.removeNotice();
          globalStore.removeDialog();
        })
        .catch((err: any) => {
          console.warn(err)
        })
    }
    else if (type === 'uploadLog') {
      globalStore.removeDialog()
    }

    return;
  }

  return (
    visible ? 
      <RoomDialog 
        type={dialog.type}
        desc={dialog.message}
        onClose={onClose}
        onConfirm={onConfirm}
      /> : 
      null
  )
}


export default React.memo(DialogContainer);