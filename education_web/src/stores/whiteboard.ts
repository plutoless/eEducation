import { EventEmitter } from 'events';
import { videoPlugin } from '@netless/white-video-plugin';
import { audioPlugin } from '@netless/white-audio-plugin';
import { Room, WhiteWebSdk, DeviceType, SceneState, createPlugins, RoomPhase } from 'white-web-sdk';
import { Subject } from 'rxjs';
import GlobalStorage from '../utils/custom-storage';
import { isEmpty, get } from 'lodash';
import { roomStore } from './room';
import { globalStore } from './global';
import { t } from '../i18n';

const ENABLE_LOG = process.env.REACT_APP_AGORA_LOG === 'true';

interface SceneFile {
  name: string
  type: string
}

export interface CustomScene {
  path: string
  rootPath: string
  file: SceneFile
  type: string
}

export interface SceneResource {
  path: string
  rootPath: string
  file: SceneFile
}

const pathName = (path: string): string => {
  const reg = /\/([^\/]*)\//g;
  reg.exec(path);
  if (RegExp.$1 === "aria") {
    return "";
  } else {
    return RegExp.$1;
  }
}

export const plugins = createPlugins({"video": videoPlugin, "audio": audioPlugin});

plugins.setPluginContext("video", {identity: 'guest'});
plugins.setPluginContext("audio", {identity: 'guest'});

export type WhiteboardState = {
  loading: boolean
  joined: boolean
  scenes: CustomScene[]
  currentScenePath: string
  currentHeight: number
  currentWidth: number
  dirs: SceneResource[]
  zoomRadio: number
  scale: number
  room: Room | null
  recording: boolean
  startTime: number
  endTime: number

  totalPage: number
  currentPage: number
  type: string
}

type JoinParams = {
  rid: string
  uuid: string
  roomToken: string
  location?: string
  userPayload: {
    userId: string,
    identity: string
  }
}

class Whiteboard extends EventEmitter {
  public state: WhiteboardState;
  public subject: Subject<WhiteboardState> | null;
  public defaultState: WhiteboardState = {
    joined: false,
    scenes: [],
    currentScenePath: '',
    currentHeight: 0,
    currentWidth: 0,
    dirs: [],
    zoomRadio: 0,
    scale: 0,
    recording: false,
    startTime: 0,
    endTime: 0,
    room: null,
    loading: true,
    // isWritable: false,
    ...GlobalStorage.read('mediaDirs'),
    totalPage: 0,
    currentPage: 0,
    type: 'static'
  }

  public readonly client: WhiteWebSdk = new WhiteWebSdk({
    deviceType: DeviceType.Surface,
    // handToolKey: " ",
    plugins,
    loggerOptions: {
      disableReportLog: ENABLE_LOG ? false : true,
      reportLevelMask: "debug",
      printLevelMask: "debug",
    }
  });

  constructor() {
    super();
    this.subject = null;
    this.state = this.defaultState;
  }

  initialize() {
    this.subject = new Subject<WhiteboardState>();
    this.state = {
      ...this.defaultState,
    }
    this.subject.next(this.state);
  }

  subscribe(updateState: any) {
    this.initialize();
    this.subject && this.subject.subscribe(updateState);
  }

  unsubscribe() {
    this.subject && this.subject.unsubscribe();
    this.subject = null;
  }

  commit (state: WhiteboardState) {
    this.subject && this.subject.next(state);
  }

  updateState(newState: WhiteboardState) {
    this.state = {
      ...this.state,
      ...newState,
    }
    this.commit(this.state);
  }

  getNameByScenePath(scenePath: string) {
    const sceneMap = get(this.state.room, `state.globalState.sceneMap`, {})
    console.log("sceneMap", sceneMap)
    return get(sceneMap, scenePath, 'default name')
  }

  updateRoomState() {
    if (!this.state.room) return;
    console.log("current room state", this.state.room.state);
    const roomState = this.state.room.state;

    const path = roomState.sceneState.scenePath;
    const ppt = roomState.sceneState.scenes[0].ppt;

    const type = isEmpty(ppt) ? 'static' : 'dynamic';
    const currentPage = roomState.sceneState.index;
    const totalPage = roomState.sceneState.scenes.length;

    if (type !== 'dynamic') {
      this.state = {
        ...this.state,
        currentHeight: 0,
        currentWidth: 0
      }
    } else {
      this.state = {
        ...this.state,
        currentHeight: get(ppt, 'height', 0),
        currentWidth: get(ppt, 'width', 0)
      }
    }

    const entrieScenes = this.state.room ? this.state.room.entireScenes() : {};

    const paths = Object.keys(entrieScenes);

    let scenes: CustomScene[] = [];
    for (let dirPath of paths) {
      const sceneInfo = {
        path: dirPath,
        file: {
          name: this.getNameByScenePath(dirPath),
          type: 'whiteboard'
        },
        type: 'static',
        rootPath: '',
      }
      if (entrieScenes[dirPath]) {
        sceneInfo.rootPath = ['/', '/init'].indexOf(dirPath) !== -1 ? '/init' : `${dirPath}/${entrieScenes[dirPath][0].name}`
        sceneInfo.type = entrieScenes[dirPath][0].ppt ? 'dynamic' : 'static'
        if (sceneInfo.type === 'dynamic') {
          sceneInfo.file.type = 'ppt';
        }
      }
      scenes.push(sceneInfo);
    }

    const _dirPath = pathName(path);
    const currentScenePath = _dirPath === "" ? "/" : `/${_dirPath}`;

    const _dirs: SceneResource[] = [];
    scenes.forEach((it: CustomScene) => {
      _dirs.push({
        path: it.path,
        rootPath: it.rootPath,
        file: it.file
      });
    });

    this.state = {
      ...this.state,
      scenes: scenes,
      currentScenePath: currentScenePath,
      dirs: _dirs,
      totalPage,
      currentPage,
      type,
    }
    this.commit(this.state);
  }

  setCurrentScene(dirPath: string) {
    const currentDirIndex = this.state.dirs.findIndex((it: SceneResource) => it.path === dirPath);
    this.state = {
      ...this.state,
      currentScenePath: dirPath,
    }
    this.commit(this.state);
  }

  updateSceneState(sceneState: SceneState) {
    const path = sceneState.scenePath;
    const ppt = sceneState.scenes[0].ppt;
    const type = isEmpty(ppt) ? 'static' : 'dynamic';
    const currentPage = sceneState.index;
    const totalPage = sceneState.scenes.length;

    this.state = {
      ...this.state,
      currentPage,
      totalPage,
      type,
    }

    this.commit(this.state);
  }

  updateScale(scale: number) {
    this.state = {
      ...this.state,
      scale: scale
    }
    
    this.commit(this.state);
  }

  updateLoading(value: boolean) {
    this.state = {
      ...this.state,
      loading: value
    }
    this.commit(this.state);
  }

  async join({rid, uuid, roomToken, location, userPayload}: JoinParams) {
    await this.leave();
    const identity = userPayload.identity === 'host' ? 'host' : 'guest';

    plugins.setPluginContext("video", {identity});
    plugins.setPluginContext("audio", {identity});

    const disableDeviceInputs: boolean = location!.match(/big-class/) && identity !== 'host' ? true : false;
    const disableOperations: boolean = location!.match(/big-class/) && identity !== 'host' ? true : false;
    const isWritable: boolean = location!.match(/big-class/) && identity !== 'host' ? false : true;

    console.log(`[White] isWritable, ${isWritable}, disableDeviceInputs, ${disableDeviceInputs}, disableOperations, ${disableOperations}, location: ${location}`);

    const roomParams = {
      uuid,
      roomToken,
      disableBezier: true,
      disableDeviceInputs,
      disableOperations,
      isWritable,
      // rejectWhenReadonlyErrorLevel: RoomErrorLevel.Ignore,
    }

    const room = await this.client.joinRoom(roomParams, {
      onPhaseChanged: (phase: RoomPhase) => {
        if (phase === RoomPhase.Connected) {
          this.updateLoading(false);
        } else {
          this.updateLoading(true);
        }
        console.log("[White] onPhaseChanged phase : ", phase);
      },
      onRoomStateChanged: state => {
        console.log("onRoomStateChanged", state)
        if (state.zoomScale) {
          whiteboard.updateScale(state.zoomScale);
        }
        if (state.sceneState || state.globalState) {
          whiteboard.updateRoomState();
        }
      },
      onDisconnectWithError: error => {},
      onKickedWithReason: reason => {},
      onKeyDown: event => {},
      onKeyUp: event => {},
      onHandToolActive: active => {},
      onPPTLoadProgress: (uuid: string, progress: number) => {},
    });

    this.state = {
      ...this.state,
      room,
    }
    this.commit(this.state);
  }

  cleanRoom () {
    this.state = {
      ...this.state,
      room: null
    }
    this.commit(this.state);
  }

  async leave() {
    if (!this.state.room) return;
    try {
      await this.state.room.disconnect();
    } catch(err) {
      console.warn('disconnect whiteboard failed', err);
    } finally {
      this.cleanRoom();
      console.log("cleanRoom");
    }
    this.updateLoading(true);
  }

  async destroy() {
    await this.leave();
    this.state = {
      ...this.defaultState,
    }
    this.commit(this.state);
    this.removeAllListeners();
  }

  private operator: any = null;

  async lock() {
    const lockBoardStatus = Boolean(roomStore.state.course.lockBoard)
    const lockBoard = lockBoardStatus ? 0 : 1
    await roomStore.updateCourse({
      lockBoard
    })
    if (lockBoard) {
      globalStore.showToast({
        type: 'notice-board',
        message: t('toast.whiteboard_lock')
      })
    } else {
      globalStore.showToast({
        type: 'notice-board',
        message: t('toast.whiteboard_unlock')
      })
    }
  }
}

export const whiteboard = new Whiteboard();
// TODO: Please remove it before release in production
// 备注：请在正式发布时删除操作的window属性
//@ts-ignore
window.netlessStore = whiteboard;
