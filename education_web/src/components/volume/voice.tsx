import React from 'react';
import Icon from '../icon';
import {makeStyles} from '@material-ui/core/styles';

import './index.scss';

const useStyles = makeStyles({
  root: {
    display: 'flex',
    marginTop: '8px',
  },
  sliderClass: {
    color: '#44A2FC',
    minWidth: '210px',
    marginLeft: '6px',
  },
  sliderRailClass: {
    height: '12px',
    color: '#44A2FC'
  },
  sliderMarkClass: {
    height: '12px',
    color: '#CCCCCC'
  }
});

const totalVolumes = 52;

function CustomSlider(props: any) {
  return (
    <div className="voice-sliders">
      {[...Array(totalVolumes)].map((e: any, key: number) => <span className={props.volume > key ? "active" : ""} key={key}></span>)}
    </div>
  )
}

function VoiceSlider(props: any) {
  const classes = useStyles(props);
  const volume = props.volume;

  return (
    <div className={classes.root}>
      <Icon className="icon-voice" disable />
      <CustomSlider volume={volume * totalVolumes} className={classes.sliderClass} />
    </div>
  );
}

export default function (props: any) {
  return (
    <div className="volume-container">
      <VoiceSlider volume={props.volume}/>
    </div>
  )
}