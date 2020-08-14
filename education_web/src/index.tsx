import React from 'react';
import ReactDOM from 'react-dom';
import './index.scss';
import App from './pages/index';
import * as serviceWorker from './serviceWorker';
import TagManager from 'react-gtm-module';
import Eruda from 'eruda';
import UAParser from 'ua-parser-js';
import {isElectron} from './utils/platform';

const parser = new UAParser();

const userAgentInfo = parser.getResult();

const isMobile = () => {
  return userAgentInfo.device.type === 'mobile';
};

// use gtm
if (process.env.REACT_APP_AGORA_GTM_ID) {
  !isElectron && TagManager.initialize({
    gtmId: process.env.REACT_APP_AGORA_GTM_ID
  })
}

ReactDOM.render(
  <App />,
  document.getElementById('root'));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();

if (isMobile()) {
  const el = document.createElement('div');
  document.body.appendChild(el);
  
  Eruda.init({
    container: el,
    tool: ['console', 'elements']
  });
}