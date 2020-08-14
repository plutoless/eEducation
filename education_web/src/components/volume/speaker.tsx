import React, {useEffect} from 'react';
import Icon from '../icon';
import { makeStyles } from '@material-ui/core/styles';
import Slider from '@material-ui/core/Slider';

import './index.scss';

const useStyles = makeStyles({
  root: {
    display: 'flex',
    marginTop: '8px',
  },
  sliderClass: {
    color: '#44A2FC',
    minWidth: '210px',
    marginLeft: '6px'
  }
});

interface SliderProps {
  volume: number
  onChange: (volume: number) => void
}

export default function ContinuousSlider(props: SliderProps) {
  const classes = useStyles(props);
  const [value, setValue] = React.useState<number>(props.volume);

  const handleChange = (event: any, newValue: any) => {
    setValue(newValue);
  };

  useEffect(() => {
    props.onChange(value);
  }, [value]);

  return (
    <div className="volume-container">
      <div className={classes.root}>
        <Icon className="icon-speaker" disable/>
        <Slider className={classes.sliderClass} value={value} onChange={handleChange} aria-labelledby="continuous-slider" />
      </div>
    </div>
  );
}