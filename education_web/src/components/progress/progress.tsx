import React from 'react';
import './progress.scss';
import { CircularProgress } from '@material-ui/core';

type ProgressProps = {
  title: string
}

export const Progress: React.FC<ProgressProps> = ({
  title,
}) => {
  return (
    <div className="progress-cover">
      <div className="progress">
        <div className="content">
          <CircularProgress className="circular"/>
          <span className="title">{title}...</span>
        </div>
      </div>
    </div>
  )
}

export default React.memo(Progress);