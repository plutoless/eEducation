import React from 'react';
import { FormControl } from '@material-ui/core';
import {makeStyles} from '@material-ui/core/styles';
import Button from './custom-button';
import FormSelect from './form-select';
import SpeakerVolume from './volume/speaker';
import useSettingControl from '../hooks/use-setting-control';
import {t} from '../i18n';

import { usePlatform } from '../containers/platform-container';

const useStyles = makeStyles ({
  formControl: {
    minWidth: '240px',
    maxWidth: '240px',
  }
});

interface SettingProps {
  className?: string
  handleFinish: (evt: any) => void
}

export default function (props: SettingProps) {
  const classes = useStyles();

  const {SettingBtn} = usePlatform();
  const {
    cameraList,
    microphoneList,
    speakerList,
    camera,
    microphone,
    speaker,
    setCamera,
    setMicrophone,
    setSpeaker,
    // volume,
    speakerVolume,
    setSpeakerVolume,
    save,
    PreviewPlayer,
    MicrophoneVolume
  } = useSettingControl();

  const changeCamera = (evt: any) => {
    console.log('changeCamera ', evt.target.value);
    setCamera(evt.target.value);
  }

  const changeMicrophone = (evt: any) => {
    console.log('changeMicrophone ', evt.target.value);
    setMicrophone(evt.target.value);
  }

  const changeSpeaker = (evt: any) => {
    console.log('changeSpeaker ', evt.target.value);
    setSpeaker(evt.target.value);
  }

  const changeSpeakerVolume = (volume: number) => {
    console.log('changeSpeaker ', volume);
    setSpeakerVolume(volume);
  }

  return (
    <div className={props.className ? props.className : "flex-container"}>
      <div className="custom-card">
        <div className="flex-item cover">
          <PreviewPlayer />
        </div>
        <div className="flex-item card">
          <div className="position-top card-menu">
            <div></div>
            <div className="icon-container">
              <SettingBtn />
            </div>
          </div>
          <div className="position-content flex-direction-column">
            <FormControl className={classes.formControl}>
              <FormSelect 
                Label={t("device.camera")}
                value={camera}
                onChange={changeCamera}
                items={cameraList}
              />
            </FormControl>
            <FormControl className={classes.formControl}>
              <FormSelect 
                Label={t("device.microphone")}
                value={microphone}
                onChange={changeMicrophone}
                items={microphoneList}
              />
              <MicrophoneVolume />
            </FormControl>
            <FormControl className={classes.formControl}>
              <FormSelect 
                Label={t("device.speaker")}
                value={speaker}
                onChange={changeSpeaker}
                items={speakerList}
              />
              <SpeakerVolume volume={speakerVolume} onChange={changeSpeakerVolume} />
            </FormControl>
            <Button name={t("device.finish")} onClick={(evt: any) => {
              save({
                speakerVolume,
                camera,
                microphone,
                speaker,
              })
              props.handleFinish(evt);
            }}/>
          </div>
        </div>
      </div>
    </div>
  )
}