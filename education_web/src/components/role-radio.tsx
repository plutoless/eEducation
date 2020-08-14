import React from 'react';
import { Theme, RadioGroup, Radio, FormControlLabel, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';

import './role-radio.scss';
import { t } from '../i18n';

const useStyles = makeStyles ((theme: Theme) => ({
  radioGroup: {
    display: 'block',
    clear: 'both',
    justifyContent: 'space-between'
  },
  required: {
    fontSize: '12px',
    color: '#ff0000',
    lineHeight: '17px',
    position: 'absolute',
    top: '23px',
  }
}));

export default function (props: any) {
  const classes = useStyles();
  return (
    <RadioGroup className={classes.radioGroup} row value={props.role} onChange={props.onChange}>
      <FormControlLabel
        className={"custom-radio align-left"}
        value="teacher"
        control={<Radio className={"custom-radio"} color="primary" />}
        label={t("home.teacher")}
        labelPlacement="end"
      />
      <FormControlLabel
        className={"custom-radio align-right"}
        value="student"
        control={<Radio className={"custom-radio"} color="primary" />}
        label={t("home.student")}
        labelPlacement="end"
      />
      {props.requiredText ? <Typography className={classes.required}>{props.requiredText}</Typography> : null}
    </RadioGroup>
  )
}