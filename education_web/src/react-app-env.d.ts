/// <reference types="react-scripts" />

declare interface RecordState {
  roomId: string
  recordId: string
  isRecording: number
  recordingTime: number
}

type RecordStateParams = RecordState

declare interface RecordingConfigParams {
  maxIdleTime: number, // seconds
  streamTypes: number,
  channelType: number,
  transcodingConfig: any,
  subscribeVideoUids: Array<string>,
  subscribeAUdioUids: Array<string>,
  subscribeUidGroup: number,
}

declare interface StorageConfigParams {
  vendor: number
  region: number
  accessKey: string
  bucket: string
  secretKey: string
  fileNamePrefix: Array<string>
}

declare interface RecordingConfig {
  recordingConfig: Partial<RecordingConfigParams>
  storageConfig?: Partial<StorageConfigParams>
}

declare module 'react-gtm-module'
declare module 'eruda'

declare module 'agora-rtc-sdk' {
  const AgoraRTC: any;
  export default AgoraRTC;
}

declare module 'agora-rtm-sdk' {
  const AgoraRTM: any;
  export default AgoraRTM;
}

declare module 'js-md5' {
  const MD5: any;
  export default MD5;
}

declare module 'ua-parser-js' {
  const UAParserJs: any;
  export default UAParserJs;
}

declare interface Device {
  deviceId: string
  label: string
  kind: string
}

declare module "worker-loader!*" {
  class WebpackWorker extends Worker {
    constructor();
  }

  export default WebpackWorker;
}

declare module '*.scss';