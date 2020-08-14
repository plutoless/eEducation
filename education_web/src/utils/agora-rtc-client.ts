import EventEmitter from 'events';
import AgoraRTC from 'agora-rtc-sdk';

export type DeviceInfo = {
  cameraCanUse: boolean
  microphoneCanUse: boolean
  devices: Device[]
}

AgoraRTC.Logger.enableLogUpload();
AgoraRTC.Logger.setLogLevel(AgoraRTC.Logger.DEBUG);
export interface AgoraStreamSpec {
  streamID: number
  video: boolean
  audio: boolean
  mirror?: boolean
  screen?: boolean
  microphoneId?: string
  cameraId?: string
  screenAudio?: boolean
  audioOutput?: {
    volume: number
    deviceId: string
  }
}

const streamEvents: string[] = [
  'accessAllowed', 
  'accessDenied',
  'stopScreenSharing',
  'videoTrackEnded',
  'audioTrackEnded',
  'player-status-changed'
];

const clientEvents: string[] = [
  'stream-published',
  'stream-added',
  'stream-removed',
  'stream-subscribed',
  'peer-online',
  'peer-leave',
  'error',
  'network-type-changed',
  'network-quality',
  'exception',
  'onTokenPrivilegeWillExpire',
  'onTokenPrivilegeDidExpire',
]

export class AgoraRTCClient {

  private streamID: any;
  public _init: boolean = false;
  public _joined: boolean = false;
  public _published: boolean = false;
  private _internalTimer: NodeJS.Timeout | any;
  public _client: any = AgoraRTC.createClient({mode: 'live', codec: 'vp8'});
  public _bus: EventEmitter = new EventEmitter();
  public _localStream: any = null;
  public _streamEvents: string[];
  public _clientEvents: string[];
  public _addEventListener: boolean = false;

  constructor () {
    this.streamID = null;
    this._streamEvents = [];
    this._clientEvents = [];
  }

  // init rtc client when _init flag is false;
  async initClient(appId: string) {
    if (this._init) return;
    let prepareInit = new Promise((resolve, reject) => {
      this._init === false && this._client.init(appId, () => {
        this._init = true;
        resolve()
      }, reject);
    })
    await prepareInit;
  }

  // create rtc client;
  async createClient(appId: string, enableRtt?: boolean) {
    await this.initClient(appId);
    this.subscribeClientEvents();
    if (enableRtt) {
      this._internalTimer = setInterval(() => {
        this._client.getTransportStats((stats: any) => {
          const RTT = stats.RTT ? stats.RTT : 0;
          this._bus.emit('watch-rtt', RTT);
        });
      }, 100);
    }
  }

  destroyClient(): void {
    this.unsubscribeClientEvents();
  }

  subscribeClientEvents() {
    if (this._addEventListener) return
    this._addEventListener = true
    for (let evtName of clientEvents) {
      this._clientEvents.push(evtName);
      this._client.on(evtName, (args: any) => {
        this._bus.emit(evtName, args);
      });
    }
  }

  unsubscribeClientEvents() {
    if (this._addEventListener) {
      for (let evtName of this._clientEvents) {
        this._client.off(evtName, () => {});
        this._clientEvents = this._clientEvents.filter((it: any) => it === evtName);
      }
      this._addEventListener = false
    }
  }

  subscribeLocalStreamEvents() {
    for (let evtName of streamEvents) {
      this._streamEvents.push(evtName);
      this._localStream.on(evtName, (args: any) => {
        this._bus.emit(evtName, args);
      });
    }
  }

  unsubscribeLocalStreamEvents() {
    if (this._localStream) {
      for (let evtName of this._streamEvents) {
        this._localStream.removeEventListener(evtName, (args: any[]) => {});
        this._streamEvents = this._streamEvents.filter((it: any) => it === evtName);
      }
    }
  }

  renewToken(newToken: string) {
    if (!this._client) return console.warn('renewToken is not permitted, checkout your instance');
    this._client.renewToken(newToken);
  }

  removeAllListeners() {
    console.log('[agora-rtc] prepare remove all event listeners')
    this.unsubscribeClientEvents();
    this._bus.removeAllListeners();
    console.log('[agora-rtc] remove all event listeners');
  }

  // subscribe
  on(evtName: string, cb: (args: any) => void) {
    this._bus.on(evtName, cb);
  }

  // unsubscribe
  off(evtName: string, cb: (args: any) => void) {
    this._bus.off(evtName, cb);
  }

  async publish() {
    return new Promise((resolve, reject) => {
      if (this._published) {
        return resolve();
      }
      this._client.publish(this._localStream, (err: any) => {
        reject(err);
      })
      setTimeout(() => {
        resolve();
        this._published = true;
      }, 300);
    })
  }

  async unpublish() {
    return new Promise((resolve, reject) => {
      if (!this._published || !this._localStream) {
        return resolve();
      }
      this._client.unpublish(this._localStream, (err: any) => {
        reject(err);
      })
      setTimeout(() => {
        resolve();
        this.destroyLocalStream();
        this._published = false;
      }, 300);
    })
  }

  setRemoteVideoStreamType(stream: any, streamType: number) {
    this._client.setRemoteVideoStreamType(stream, streamType);
  }

  async enableDualStream() {
    return new Promise((resolve, reject) => {
      this._client.enableDualStream(resolve, reject);
    });
  }

  createLocalStream(data: AgoraStreamSpec): Promise<any> {
    this._localStream = AgoraRTC.createStream({...data, mirror: false});
    return new Promise((resolve, reject) => {
      this._localStream.init(() => {
        this.streamID = data.streamID;
        this.subscribeLocalStreamEvents();
        if (data.audioOutput && data.audioOutput.deviceId) {
          this.setAudioOutput(data.audioOutput.deviceId).then(() => {
            console.log('setAudioOutput success', data.audioOutput)
          }).catch((err: any) => {
            console.warn('setAudioOutput failed', err, JSON.stringify(err))
          })
        }
        resolve();
      }, (err: any) => {
        reject(err);
      })
    });
  }

  destroyLocalStream () {
    this.unsubscribeLocalStreamEvents();
    if(this._localStream) {
      if (this._localStream.isPlaying()) {
        this._localStream.stop();
      }
      this._localStream.close();
    }
    this._localStream = null;
    this.streamID = 0;
  }

  async join (uid: number, channel: string, token?: string) {
    return new Promise((resolve, reject) => {
      this._client.join(token, channel, +uid, resolve, reject);
    })
  }

  async leave () {
    if (this._client) {
      return new Promise((resolve, reject) => {
        this._client.leave(resolve, reject);
      })
    }
  }

  setAudioOutput(speakerId: string) {
    return new Promise((resolve, reject) => {
      if (this._client) {
        this._client.setAudioOutput(speakerId, resolve, reject);
        return
      }
      resolve()
    })
  }

  setAudioVolume(volume: number) {
    this._client.setAudioVolume(volume);
  }

  subscribe(stream: any) {
    this._client.subscribe(stream, {video: true, audio: true}, (err: any) => {
      console.log('[rtc-client] subscribe failed: ', JSON.stringify(err));
    });
  }

  destroy (): void {
    this._internalTimer && clearInterval(this._internalTimer);
    this._internalTimer = null;
    this.destroyLocalStream();
    this.removeAllListeners();
  }

  async exit () {
    try {
      await this.leave();       
    } catch (err) {
      throw err;
    } finally {
      this.destroy();
    }
  }

  getDevices (): Promise<DeviceInfo> {
    return new Promise((resolve, reject) => {
      AgoraRTC.getDevices((devices: any) => {
        const _devices: any[] = [];
        devices.forEach((item: any) => {
          _devices.push({deviceId: item.deviceId, kind: item.kind, label: item.label});
        })
        resolve({
          cameraCanUse: devices.filter((it: any) => it.kind === 'videoinput').length > 0 ? true : false,
          microphoneCanUse: devices.filter((it: any) => it.kind === 'audioinput').length > 0 ? true : false,
          devices: _devices,
        });
      }, (err: any) => {
        reject(err);
      });
    })
  }

  async forceGetDevices (): Promise<DeviceInfo> {
    const tempAudioStream = AgoraRTC.createStream({ audio: true, video: false })
    const tempVideoStream = AgoraRTC.createStream({ audio: false, video: true })

    const audioPermissionOK = new Promise(resolve => {
      tempAudioStream.init(() => resolve(null), (err: any) => resolve(err))
    })
    const videoPermissionOK = new Promise(resolve => {
      tempVideoStream.init(() => resolve(null), (err: any) => resolve(err))
    })

    try {
      let [microphone, camera] = await Promise.all([audioPermissionOK, videoPermissionOK])
      let result = await this.getDevices()

      if (microphone !== null) {
        result.microphoneCanUse = false
        console.warn("create audio temp stream failed!", microphone)
      }
      if (camera !== null) {
        result.cameraCanUse = false
        console.warn("create video temp stream failed!", camera)
      }
      
      return result
    } catch (err) {
      throw err
    } finally {
      tempAudioStream.close()
      tempVideoStream.close()
    }
  }
}