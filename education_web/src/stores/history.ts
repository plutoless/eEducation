import { Subject } from 'rxjs';
export class RouterHistoryEntity {
  private subject: Subject<any> | null;
  public state: any;

  public readonly defaultState: any = {
    state: 'ready',
    history: null,
  }

  constructor() {
    this.subject = null;
    this.state = this.defaultState;
  }

  initialize() {
    this.subject = new Subject<any>();
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

  commit (state: any) {
    this.subject && this.subject.next(state);
  }

  setHistory(history: any) {
    if (!this.state) return
    this.state = {
      ...this.state,
      history,
    }
    this.commit(this.state)
  }

  getHistory() {
    if (!this.state) return
    return this.state.history
  }
}

export const historyStore = new RouterHistoryEntity();

// TODO: Please remove it before release in production
// 备注：请在正式发布时删除操作的window属性
//@ts-ignore
window.historyStore = historyStore