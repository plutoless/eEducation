import React from 'react';
import {t} from '../i18n';

import './404.scss';
import { useHistory } from 'react-router-dom';

const BasicLayout: React.FC<any> = ({children}) => {
  return (
    <div className="main-layout-container">
      {children}
    </div>
  )
}

export const PageNotFound: React.FC<any> = () => {

  const history = useHistory();

  return (
    <BasicLayout>
      <div className="layout-content">
        <h1>404</h1>
        <h2>{t('error.not_found')}</h2>
        <a style={{"cursor": "pointer"}} onClick={() => {
            history.push('/');
        }}>{t('return.home')}</a>
      </div>
    </BasicLayout>
  )
}