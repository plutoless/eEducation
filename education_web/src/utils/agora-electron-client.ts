import { APP_ID } from './config';
import EventEmitter from 'events';
import { btoa } from './helper';
import { RoomStore } from '../stores/room';
import { globalStore } from '../stores/global';
// @ts-ignore
export const AgoraRtcEngine = window.rtcEngine;

if (AgoraRtcEngine) {
  AgoraRtcEngine.initialize(APP_ID);
  AgoraRtcEngine.setChannelProfile(1);
  AgoraRtcEngine.enableVideo();
  AgoraRtcEngine.enableAudio();
  AgoraRtcEngine.enableWebSdkInteroperability(true);
  AgoraRtcEngine.setVideoProfile(43, false);
  //@ts-ignore
  window.ipc && window.ipc.once("initialize", (events: any, args: any) => {
    const logPath = args[0]
    const videoSourceLogPath = args[2];
    const videoSourceAddonLogPath = args[3];
    //@ts-ignore
    window.videoSourceLogPath = videoSourceLogPath;
    //@ts-ignore
    window.videoSourceAddonLogPath = videoSourceAddonLogPath;
    AgoraRtcEngine.setLogFile(logPath)
  })
}

//@ts-ignore
window.ipc && window.ipc.on("export-log", (events: any, args: any) => {
  //@ts-ignore
  window.doGzip();
  //@ts-ignore
  console.log('doGzip', window.doGzip);
})

export interface Stream {
  uid: number
}

export enum StreamType {
  local,
  remote,
  localVideoSource,
  remoteVideoSource,
}

export class AgoraElectronStream {
  public stream: Stream;
  public playing: boolean = false;
  private domID: string;
  constructor(
    public uid: number = uid,
    public type: StreamType = StreamType.remote,
  ) {
    this.domID = '';
    this.stream = {
      uid: this.uid,
    }
  }
}

export interface ElectronStreamSpec {
  streamID: number
  microphoneId?: string
  cameraId?: string
  speakerId?: string
  speakerVolume?: number
}

export class AgoraElectronClient {

  public joined: boolean;
  private readonly bus: EventEmitter;
  public localUid: number;
  public rid: string;
  public readonly rtcEngine: any
  public published: boolean;
  public shared: boolean;
  private roomStore: RoomStore;
  subscribeVideoSource: boolean = false;

  constructor(deps: {roomStore: RoomStore}) {
    this.rtcEngine = AgoraRtcEngine;
    this.published = false;
    this.localUid = 0;
    this.joined = false;
    this.shared = false;
    this.rid = '';
    this.bus = new EventEmitter();
    this.roomStore = deps.roomStore;
  }

  private isLocal(uid: number) {
    return this.localUid === uid;
  }

  createStream ({streamID, microphoneId, cameraId, speakerId, speakerVolume}: ElectronStreamSpec) {
    if (microphoneId) {
      const res = this.rtcEngine.setAudioRecordingDevice(microphoneId);
      res !== 0 && console.warn(`[createStream] set microphone: ${microphoneId} failed`);
    }

    if (cameraId) {
      const res = this.rtcEngine.setVideoDevice(cameraId);
      res !== 0 && console.warn(`[createStream] set cameraId: ${cameraId} failed`);
    }

    if (speakerId) {
      const res = this.rtcEngine.setAudioPlaybackDevice(speakerId);
      res !== 0 && console.warn(`[creaetStream] set speakerId: ${speakerId}`);
    }

    if (speakerVolume) {
      const res = this.rtcEngine.setAudioPlaybackVolume(speakerVolume);
      res !== 0 && console.warn(`[creaetStream] set setAudioPlaybackVolume: ${speakerVolume}`);
    }

    return new AgoraElectronStream(streamID, +streamID !== +this.roomStore.state.course.screenId ? StreamType.local : StreamType.localVideoSource);
  }

  private readonly events: string[] = [
    'joinedchannel',
    'userjoined',
    'removestream',
    'leavechannel',
    'audiodevicestatechanged',
    'videodevicestatechanged',
    'error',
    'executefailed',
    'rtcStats',
    'networkquality',
    'audioquality',
  ]

  private _subscribedEvents: any[] = [];
  private destroyed: boolean = false;

  joinChannel({
    uid,
    channel,
    dual,
    token
  }: {
    uid: number,
    channel: string,
    dual: boolean,
    token: string
  }): number {
    this.localUid = uid;
    this.rid = channel;
    const rtcEngine = this.rtcEngine;
    const events = [
      // 'joinedchannel',
      // 'userjoined',
      // 'removestream',
      'leavechannel',
      'error',
      'executefailed',
      'rtcStats',
      'networkquality',
      'audioquality',
    ]
    for (let event of events) {
      this._subscribedEvents.push(event);
      rtcEngine.on(event, (...args: any[]) => {
        this.bus.emit(event, ...args);
      })
    }
    rtcEngine.on('joinedchannel', (channel: string, uid: number) => {
      const stream = new AgoraElectronStream(uid, +uid !== +this.roomStore.state.course.screenId ? StreamType.local : StreamType.localVideoSource);
      this.bus.emit('joinedchannel', {stream});
    })
    rtcEngine.on('userjoined', (uid: number) => {
      const stream = new AgoraElectronStream(uid, StreamType.remote);
      console.log("userjoined", uid)
      this.bus.emit('userjoined', {stream});
    })
    rtcEngine.on('removestream', (uid: number) => {
      this.bus.emit('removestream', {uid});
    })
    if (dual) {
      rtcEngine.enableDualStreamMode(true);
    }
    // default role is audience
    this.rtcEngine.setClientRole(2);
    // WARN: TOKEN
    let res = this.rtcEngine.joinChannel(token, channel, '', this.localUid);
    if(res === 0) {
      this.joined = true;
      this.destroyed = false;
    }
    return res;
  }

  play(uid: number, dom: Element, videosource?: boolean) {
    const rtcEngine = this.rtcEngine;
    const local = this.isLocal(uid);
    if (videosource) {
      if (local) {
        rtcEngine.setupLocalVideoSource(dom)
        rtcEngine.setupViewContentMode('videosource', 1);
        rtcEngine.setupViewContentMode(uid, 1);
      } else {
        rtcEngine.subscribe(uid, dom)
        rtcEngine.setupViewContentMode('videosource', 1);
        rtcEngine.setupViewContentMode(uid, 1);
      }
    } else {
      if (local) {
        this.rtcEngine.setupLocalVideo(dom);
      } else {
        this.rtcEngine.subscribe(uid, dom)
        this.rtcEngine.setupViewContentMode(uid, 1);
      }
    }
  }

  stop(uid: number, dom: Element) {
    this.rtcEngine.destroyRenderView(uid, dom, (err: any) => {console.warn(err.message)});
  }

  leave() {
    if (!this.joined) return;
    const result = this.rtcEngine.leaveChannel();
    this.joined = false;
    this.localUid = 0;
    this.rid = '';
    return result;
  }

  on(name: string, cb: (...args: any[]) => void) {
    this.bus.on(name, cb);
  }

  off(name: string, cb: (...args: any[]) => void) {
    this.bus.off(name, cb);
  }

  destroyClient() {
    if (this.destroyed) return;
    for (let event of this._subscribedEvents) {
      this.rtcEngine.off(event, () => {});
    }
    this.bus.removeAllListeners();
    this.destroyed = true;
  }

  getScreenShareWindows() {
    return this.rtcEngine.getScreenWindowsInfo()
      .map((item: any) => ({
        ownerName: item.ownerName,
        name: item.name,
        windowId: item.windowId,
        image: btoa(item.image)
      }));
  }

  async startScreenShare(
    windowId: number,
    uid: number,
    channel: string,
    token: string,
    appId: string,
    rect = {x: 0, y: 0, width: 0, height: 0},
    param = {width: 0, height: 0, bitrate: 500, frameRate: 15}
  ): Promise<AgoraElectronStream> {
    console.log("[native] start screen share", token, uid, appId);
    const shareClient = this.rtcEngine;
    return new Promise((resolve, reject) => {
      shareClient.videoSourceInitialize(APP_ID);
      shareClient.videoSourceSetChannelProfile(1);
      shareClient.videoSourceEnableWebSdkInteroperability(true);
      // shareClient.setVideoRenderDimension(3, SHARE_ID, 1280, 960);
      shareClient.videoSourceSetVideoProfile(50, false);
      //@ts-ignore
      if (window.videoSourceLogPath) {
        //@ts-ignore
        shareClient.videoSourceSetLogFile(window.videoSourceLogPath)
        //@ts-ignore
        console.log(`[native] videoSourceSetLogFile, videoSourceLogPath: `, window.videoSourceLogPath)
      }
      //@ts-ignore
      // if (window.videoSourceAddonLogPath) {
      //   //@ts-ignore
      //   shareClient.videoSourceSetAddonLogFile(window.videoSourceAddonLogPath)
      //   //@ts-ignore
      //   console.log(`[native] videoSourceSetAddonLogFile, videoSourceAddonLogPath: `, window.videoSourceAddonLogPath)
      // }
      // to adjust render dimension to optimize performance
      console.log("[electron-debug] SHARE_ID", uid, " TOKEN: ", token, " CHANNEL", channel);
      shareClient.videoSourceJoin(token, channel, '', uid);
      if (!shareClient.subscribeVideoSource) {
        shareClient.once('videoSourceJoinedSuccess', (uid: number) => {
          shareClient.subscribeVideoSource = false;
          console.log("[electron-debug] videoSource Joined", uid);
          // shareClient.startScreenCapture2(windowId, 15, rect, 0);
          shareClient.videoSourceStartScreenCaptureByWindow(windowId, {x: 0, y: 0, width: 0, height: 0}, {width: 0, height: 0, bitrate: 500, frameRate: 15});
          shareClient.startScreenCapturePreview();
          // shareClient.videoSourceSetVideoProfile(43, false);
          // shareClient.startScreenCapture2(windowId, 15, rect, 0);
          // shareClient.startScreenCapturePreview();
          this.shared = true;

          const electronStream = new AgoraElectronStream(uid, StreamType.localVideoSource);
          resolve(electronStream);
          shareClient.off('videoSourceJoinedSuccess', () => {});
        });

        shareClient.subscribeVideoSource = true;

        setTimeout(() => {
          reject();
        }, 5000);
      }
    })
  }

  async stopScreenShare() {
    globalStore.showLoading();
    let stopPromise = new Promise((resolve, reject) => {
      const onSuccess = () => {
        this.roomStore.removeLocalSharedStream();
        this.rtcEngine.off('videoSourceLeaveChannel', (evt: any) => {});
        globalStore.stopLoading();
      }

      const onFailure = () => {
        this.roomStore.removeLocalSharedStream();
        this.rtcEngine.off('videoSourceLeaveChannel', (evt: any) => {});
        globalStore.stopLoading();
      }

      // this.rtcEngine.once('videoSourceLeaveChannel', (evt: any) => {
      //   onSuccess();
      // });
      // this.rtcEngine.videoSourceLeave();
      this.rtcEngine.videoSourceRelease();
      this.shared = false;
      resolve(onSuccess());
      // setTimeout(() => {
      //   reject(onFailure())
      // }, 5000)
    })

    return await stopPromise;
  }

  releaseScreenShare() {
    this.roomStore.removeLocalSharedStream();
    this.rtcEngine.videoSourceLeave()
    this.rtcEngine.videoSourceRelease();
    this.rtcEngine.removeAllListeners();
    this.shared = false;
    this.rtcEngine.subscribeVideoSource = false;
  }

  exit () {
    try {
      this.leave();
    } catch(err) {
      throw err;
    } finally {
      this.destroyClient();
    }
  }

  publish() {
    this.published = true;
    const res = this.rtcEngine.setClientRole(1);
    return res;
  }

  unpublish() {
    this.published = false;
    const res = this.rtcEngine.setClientRole(2);
    return res;
  }
}

// export const nativeRTCClient = roomStore.rtcClient as AgoraElectronClient;