const {ipcRenderer: ipc} = require('electron');

const AgoraRtcEngine = require('agora-electron-sdk').default;

const {promisify} = require('util')

const path = require('path');
const fs = require('fs');

const rtcEngine = new AgoraRtcEngine();

window.rtcEngine = rtcEngine;
window.ipc = ipc;
window.path = path;

const AdmZip = require('adm-zip');

window.ipc.on('appPath', (event, args) => {
  const appPath = args[0];
  const logPath = path.join(appPath, `log`, `agora_sdk.log`)
  const dstPath = path.join(appPath, `log`, `agora_sdk.log.zip`)
  window.dstPath = dstPath;
  window.logPath = logPath;
  window.videoSourceLogPath = args[1];
})

const doGzip = async () => {
  const zip = new AdmZip();
  zip.addLocalFile(window.logPath)
  // if (window.videoSourceLogPath) {
  zip.addLocalFile(window.videoSourceLogPath)
  // }
  zip.writeZip(window.dstPath)
  return promisify(fs.readFile)(window.dstPath)
}

window.doGzip = doGzip;
