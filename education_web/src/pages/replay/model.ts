import React from 'react';
import { Subject } from 'rxjs';
import { Player, PlayerPhase } from 'white-web-sdk';
import { useParams, useLocation, Redirect } from 'react-router';
import moment from 'moment';
import { Progress } from '@/components/progress/progress';
import { globalStore } from '@/stores/global';
import { WhiteboardAPI, RTMRestful } from '@/utils/api';
import { whiteboard } from '@/stores/whiteboard';
import { RtmPlayerState } from '@/components/whiteboard/agora/rtm-player';
import { eduApi } from '@/services/edu-api';

interface IObserver<T> {
  subscribe: (setState: (state: T) => void) => void
  unsubscribe: () => void
  defaultState: T
}

export function useObserver<T>(store: IObserver<T>) {
  const [state, setState] = React.useState<T>(store.defaultState);
  React.useEffect(() => {
    store.subscribe((state: any) => {
      setState(state);
    });
    return () => {
      store.unsubscribe();
    }
  }, []);

  return state;
}


export interface IPlayerState {
  beginTimestamp: number
  duration: number
  roomToken: string
  mediaURL: string
  isPlaying: boolean
  progress: number

  currentTime: number
  phase: string
  boardPlayPhase: PlayerPhase
  isFirstScreenReady: boolean
  isPlayerSeeking: boolean
  isChatOpen: boolean
  isVisible: boolean
  replayFail: boolean
  courseRecordData: {
    startTime: number
    endTime: number
    url: string
    boardId: string
    status: number
    statusText: string
  }
  player: any
  timelineScheduler: any
  videoPlayer: any
}

export const defaultState: IPlayerState = {
  beginTimestamp: 0,
  duration: 0,
  roomToken: '',
  mediaURL: '',
  isPlaying: false,
  progress: 0,

  currentTime: 0,
  phase: 'waiting',
  boardPlayPhase: PlayerPhase.Pause,
  isFirstScreenReady: false,
  isPlayerSeeking: false,
  isChatOpen: false,
  isVisible: false,
  replayFail: false,

  courseRecordData: {
    startTime: -1,
    endTime: -1,
    url: '',
    boardId: '',
    status: 0,
    statusText: '',
  },
  player: null,
  videoPlayer: null,
  timelineScheduler: null
}

class ReplayStore {
  public subject: Subject<IPlayerState> | null;
  public state: IPlayerState | null;
  public defaultState: IPlayerState = defaultState

  constructor() {
    this.subject = null;
    this.state = null;
  }

  initialize() {
    this.subject = new Subject<IPlayerState>();
    this.state = defaultState;
    this.subject.next(this.state);
  }

  subscribe(setState: any) {
    this.initialize();
    this.subject && this.subject.subscribe(setState);
  }

  unsubscribe() {
    this.subject && this.subject.unsubscribe();
    this.state = null;
    this.subject = null;
  }

  commit(state: IPlayerState) {
    this.subject && this.subject.next(state);
  }

  setPlayer(player: Player) {
    if (!this.state) return;
    this.state = {
      ...this.state,
      player
    }
    this.commit(this.state);
  }

  setCurrentTime(scheduleTime: number) {
    if (!this.state) return;
    this.state = {
      ...this.state,
      currentTime: scheduleTime
    }
    this.commit(this.state);
  }

  async getCourseRecordBy(recordId: string, roomId: string, userToken: string) {
    if (!this.state) return;
    if (this.state.courseRecordData.status === 2 && this.state.courseRecordData.url) return;
    const {boardId, startTime, endTime, url, status, statusText} = await eduApi.getCourseRecordBy(recordId as string, roomId as string, userToken)
    this.state = {
      ...this.state,
      courseRecordData: {
        startTime,
        endTime,
        url,
        boardId,
        status,
        statusText
      }
    }
    this.commit(this.state)
  }

  updatePlayerStatus(isPlaying: boolean) {
    if (!this.state) return;

    this.state = {
      ...this.state,
      isPlaying,
    }
    if (!this.state.isPlaying && this.state.player) {
      this.state.player.seekToScheduleTime(0);
    }
    this.commit(this.state);
  }

  updateProgress(progress: number) {
    if (!this.state) return
    this.state = {
      ...this.state,
      progress
    }
    this.commit(this.state);
  }

  setReplayFail(val: boolean) {
    if (!this.state) return
    this.state = {
      ...this.state,
      replayFail: val
    }
    this.commit(this.state);
  }

  updateWhiteboardPhase(boardPlayPhase: PlayerPhase) {
    if (!this.state) return
    let isPlaying = this.state.isPlaying;

    if (boardPlayPhase === PlayerPhase.Playing) {
      isPlaying = true;
    }

    if (boardPlayPhase === PlayerPhase.Ended || boardPlayPhase === PlayerPhase.Pause) {
      isPlaying = false;
    }

    this.state = {
      ...this.state,
      boardPlayPhase,
      isPlaying,
    }
    
    this.commit(this.state);
  }

  // updatePhase(phase: PlayerPhase) {
  //   if (!this.state) return
  //   let isPlaying = this.state.isPlaying;

  //   if (phase === PlayerPhase.Playing) {
  //     isPlaying = true;
  //   }

  //   if (phase === PlayerPhase.Ended || phase === PlayerPhase.Pause) {
  //     isPlaying = false;
  //   }

  //   this.state = {
  //     ...this.state,
  //     phase,
  //     isPlaying,
  //   }
    
  //   this.commit(this.state);
  // }

  updatePlayState(phase: any) {
    if (!this.state) return

    this.state = {
      ...this.state,
      phase,
    }
    
    this.commit(this.state);
  }

  // loadFirstFrame() {
  //   if (!this.state) return
  //   this.state = {
  //     ...this.state,
  //     isFirstScreenReady: true,
  //   }
  //   this.commit(this.state);
  // }

  addWhiteboardPlayer(player: any) {
    if (!this.state) return
    this.state = {
      ...this.state,
      player: player
    }
    this.commit(this.state)
  }

  addVideoPlayer(player: any) {
    if (!this.state) return
    this.state = {
      ...this.state,
      videoPlayer: player
    }
    this.commit(this.state)
  }

  addTimeline(scheduler: any) {
    if (!this.state) return
    this.state = {
      ...this.state,
      timelineScheduler: scheduler
    }
    this.commit(this.state)
  }

  async joinRoom(roomId: string) {
    const res = await eduApi.getWhiteboardBy(roomId);
    return {
      roomToken: res.boardToken,
      uuid: res.boardId,
    }
  }
}

export const replayStore = new ReplayStore();