import AgoraRTM from 'agora-rtm-sdk';
import EventEmitter from 'events';
import * as _ from 'lodash';
import { resolveMessage, jsonParse } from './helper';

export const APP_ID = process.env.REACT_APP_AGORA_APP_ID as string;
const ENABLE_LOG = process.env.REACT_APP_AGORA_LOG === 'true';
const logFilter = ENABLE_LOG ? AgoraRTM.LOG_FILTER_DEBUG : AgoraRTM.LOG_FILTER_OFF;

export enum RoomMessage {
  muteAudio = 101,
  unmuteAudio = 102,
  muteVideo = 103,
  unmuteVideo = 104,
  applyCoVideo = 105,
  acceptCoVideo = 106,
  rejectCoVideo = 107,
  cancelCoVideo = 108,
  muteChat = 109,
  unmuteChat = 110,
  muteBoard = 200,
  unmuteBoard = 201,
  lockBoard = 301,
  unlockBoard = 302,
  startCourse = 401,
  endCourse = 402,
  muteAllChat = 501,
  unmuteAllChat = 502
}

export enum ChatCmdType {
  chat = 1,
  roomMemberChanged = 2,
  roomInfoChanged = 3,
  coVideoUsersChanged = 4,
  replay = 5,
  screenShare = 6,
  recordStateChanged = 7
}

export enum CoVideoType {
  studentSendApply = 1,
  teacherSendReject = 2,
  // studentCancelApply = 3,
  teacherSendAccept = 4,
  teacherSendStop = 5,
  studentSendStop = 6,
}

export interface ChannelBodyParams {
  account: string
  content: string
  recordId: string
}

export interface NotifyMessageParams {
  cmd: ChatCmdType
  data: ChatMessage | UserMessage | CourseMessage | ReplayMessage
  enableHistoricalMessaging?: boolean
}

export interface CourseMessage {
  operate: 
    RoomMessage.startCourse | 
    RoomMessage.endCourse | 
    RoomMessage.muteAllChat |
    RoomMessage.unmuteAllChat |
    RoomMessage.lockBoard |
    RoomMessage.unlockBoard |
    RoomMessage.acceptCoVideo |
    RoomMessage.cancelCoVideo |
    RoomMessage.applyCoVideo
}

export type ChatMessage = {
  account: string
  content: string
  userId?: string
}

export interface ReplayMessage {
  account: string
  recordId: string
}

export interface UserMessage {
  uid: string
  account: string
  resource: string
  value: number
}


export interface ChatBody {
  account: string
  content: string
}

export interface PeerMessage {
  uid: string
  userId: string
  account: string
  operate: number
}

export interface MessageBody {
  cmd: RoomMessage
  text?: string
  data?: ChatMessage |
    UserMessage |
    CourseMessage |
    PeerMessage |
    ReplayMessage
}

export type SessionProps = {
  roomType: number,
  role: string,
  id: string,
  room: string,
  token: string
}

export default class AgoraRTMClient {

  private _bus: EventEmitter;
  public _currentChannel: any;
  public _currentChannelName: string | any;
  private _channels: any;
  private _client: any;
  private _channelAttrsKey: string | any;
  public _logged: boolean = false;
  private _joined: boolean = false;

  constructor () {
    this._bus = new EventEmitter();
    this._channels = {};
    this._currentChannel = null;
    this._currentChannelName = null;
    this._channelAttrsKey = null;
    this._client = null;
  }

  public removeAllListeners(): any {
    this._bus.removeAllListeners();
  }

  destroy (): void {
    for (let channel of Object.keys(this._channels)) {
      if (this._channels[channel]) {
        this._channels[channel].removeAllListeners();
        this._channels[channel] = null;
      }
    }
    this._currentChannel = null;
    this._currentChannelName = null;
    this._client.removeAllListeners();
  }

  on(evtName: string, cb: (args: any) => void) {
    this._bus.on(evtName, cb);
  }

  off(evtName: string, cb: (args: any) => void) {
    this._bus.off(evtName, cb);
  }

  async login (appID: string, uid: string, token?: string) {
    const rtmClient = AgoraRTM.createInstance(appID, { enableLogUpload: ENABLE_LOG, logFilter });
    try {
      await rtmClient.login({uid, token});
      rtmClient.on("ConnectionStateChanged", (newState: string, reason: string) => {
        this._bus.emit("ConnectionStateChanged", {newState, reason});
      });
      rtmClient.on("MessageFromPeer", (message: any, peerId: string, props: any) => {
        this._bus.emit("MessageFromPeer", {message, peerId, props});
      });
      this._client = rtmClient
      this._logged = true;
    } catch(err) {
      rtmClient.removeAllListeners()
      throw err
    }
    return
  }

  async logout () {
    if (!this._logged) return;
    await this._client.logout();
    this.destroy();
    this._logged = false;
    return;
  }

  async join (channel: string) {
    const _channel = this._client.createChannel(channel);
    this._channels[channel] = _channel;
    this._currentChannel = this._channels[channel];
    this._currentChannelName = channel;
    await _channel.join();
    _channel.on('ChannelMessage', (message: string, memberId: string) => {
      this._bus.emit('ChannelMessage', {message, memberId});
    });

    _channel.on('MemberJoined', (memberId: string) => {
      this._bus.emit('MemberJoined', memberId);
    });

    _channel.on('MemberLeft', (memberId: string) => {
      this._bus.emit('MemberLeft', memberId);
    });

    _channel.on('MemberCountUpdated', (count: number) => {
      this._bus.emit('MemberCountUpdated', count);
    })

    _channel.on('AttributesUpdated', (attributes: any) => {
      this._bus.emit('AttributesUpdated', attributes);
    });
    this._joined = true;
    return;
  }

  destroyChannel(channel: string) {
    if (this._channels[channel]) {
      this._channels[channel].removeAllListeners();
      this._channels[channel] = null;
    }
  }

  async leave (channel: string) {
    if (this._channels[channel]) {
      // await this._channels[channel].leave();
      this._joined = false;
      this.destroyChannel(channel);
    }
  }

  async exit() {
    try {
      await this.deleteChannelAttributesByKey();
    } catch (err) {

    } finally {
      await this.leave(this._currentChannelName);
      await this.logout();
    }
  }

  async notifyMessage(params: NotifyMessageParams) {
    const {cmd, data, enableHistoricalMessaging = false} = params

    const body = JSON.stringify({
      cmd,
      data,
    })

    return this._currentChannel.sendMessage({text: body}, {enableHistoricalMessaging})
  }

  async sendPeerMessage(peerId: string, body: MessageBody) {
    resolveMessage(peerId, body);
    console.log("[rtm-client] send peer message ", peerId, JSON.stringify(body));
    let result = await this._client.sendMessageToPeer({text: JSON.stringify(body)}, peerId, {enableHistoricalMessaging: true});
    return result.hasPeerReceived;
  }

  async sendRecordMessage(data: Partial<ChannelBodyParams>) {
    const msgData: ReplayMessage = {
      account: data.account as string,
      recordId: data.recordId as string,
    }

    return this.notifyMessage({
      cmd: ChatCmdType.replay,
      data: msgData,
      enableHistoricalMessaging: false
    })
  }

  // async sendChannelMessage(data: Partial<ChannelBodyParams>) {
  //   const msgData: ChatMessage = {
  //     account: data.account as string,
  //     content: data.content as string,
  //   }

  //   return this.notifyMessage({
  //     cmd: ChatCmdType.chat,
  //     data: msgData,
  //     enableHistoricalMessaging: true
  //   })
  // }

  async updateChannelAttrsByKey (key: string, attrs: any) {
    this._channelAttrsKey = key;
    const channelAttributes: {[key: string]: string} = {}
    if (key) {
      channelAttributes[key] = JSON.stringify(attrs);
    }

    console.log("[rtm-client] updateChannelAttrsByKey ", attrs, " key ", key, channelAttributes);
    await this._client.addOrUpdateChannelAttributes(
      this._currentChannelName,
      channelAttributes,
      {enableNotificationToChannelMembers: true});
  }

  async deleteChannelAttributesByKey() {
    if (!this._channelAttrsKey) return;
    await this._client.deleteChannelAttributesByKeys(
      this._currentChannelName,
      [this._channelAttrsKey],
      {enableNotificationToChannelMembers: true}
    );
    this._channelAttrsKey = null;
    return;
  }
  
  async getChannelAttrs (): Promise<string> {
    let json = await this._client.getChannelAttributes(this._currentChannelName);
    return JSON.stringify(json);
  }

  async getChannelMemberCount(ids: string[]) {
    return this._client.getChannelMemberCount(ids);
  }

  async queryOnlineStatusBy(accounts: any[]) {
    let results: any = {
      teacherCount: 0,
      totalCount: 0,
      studentTotalCount: 0
    };
    if (accounts.length > 0) {
      const ids = accounts.map((it: any) => `${it.uid}`);
      results = await this._client.queryPeersOnlineStatus(ids);
      if (results && Object.keys(results).length) {
        const teacher = accounts.find((it: any) => it.role === 'teacher');
        if (teacher && results[teacher.uid]) {
          results.teacher = results[teacher.uid];
          results.teacherCount = 1;
        }
        results.totalCount = accounts.filter((it: any) => results[it.uid]).length;
        results.studentsTotalCount = results.totalCount - results.teacherCount;
      } else {
        console.warn(`accounts: ${ids}, cannot get peers online status from [queryPeersOnlineStatus]`);
      }
    }
    return results;
  }

  async getChannelAttributeBy(channelName: string) {
    let json = await this._client.getChannelAttributes(channelName);
    const accounts = [];
    for (let key of Object.keys(json)) {
      if (key === 'teacher') {
        const teacherObj = jsonParse(_.get(json, `${key}.value`));
        // when teacher is not empty object
        if(teacherObj && Object.keys(teacherObj).length) {
          accounts.push({role: 'teacher', ...teacherObj});
        }
        continue;
      }
      const student = jsonParse(_.get(json, `${key}.value`));
      // when student is not empty object
      if (student && Object.keys(student).length) {
        student.uid = key;
        accounts.push(student);
      }
    }
    return accounts;
  }
}