import { BehaviorSubject } from "rxjs"

export interface ErrorState {
  reason: string | null,
  errors: {[key: string]: any}[] | []
}

export class ErrorStore {
  public readonly defaultState: ErrorState = {
    reason: null,
    errors: [] 
  }

  private subject: BehaviorSubject<ErrorState> = new BehaviorSubject<ErrorState>(this.defaultState);

  constructor() {
    // console.log("defaultValue", this.subject.getValue());
  }

  set state(newState: Partial<ErrorState>) {
    this.subject.next({...this.subject.getValue(), ...newState});
  }

  get state() {
    return this.subject.getValue();
  }

  subscribe(updateState: any) {
    this.subject.subscribe(updateState);
  }

  unsubscribe() {
    this.subject.unsubscribe();
    this.state = this.defaultState;
  }
}

export const errorStore = new ErrorStore();