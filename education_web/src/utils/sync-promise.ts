export enum SyncPromiseState {
  pending = "pending",
  fulfilled = "fulfilled",
  rejected = "rejected"
};

export type SyncPromiseResolver<T> = (val?: T) => void;
export type SyncPromiseRejecter = (err?: any) => void;

export type SyncPromiseExecutor<T> = (resolve: SyncPromiseResolver<T>, reject: SyncPromiseRejecter) => void;

export class SyncPromise<T> {

  state: SyncPromiseState = SyncPromiseState.pending
  result: T | any = undefined
  resolveCallableFunctions: SyncPromiseResolver<T>[] = []
  rejectCallableFunctions: SyncPromiseRejecter[] = []

  constructor(executor: SyncPromiseExecutor<T>) {
    const resolve: SyncPromiseResolver<T> = (val?: T) => {
      if (this.state === SyncPromiseState.pending) {
        this.result = val
        this.state = SyncPromiseState.fulfilled
        for (let nextResolve of this.resolveCallableFunctions) {
          nextResolve(val)
        }
      }
    }

    const reject: SyncPromiseRejecter = (err?: any) => {
      if (this.state === SyncPromiseState.pending) {
        this.result = err
        this.state = SyncPromiseState.rejected
        for (let nextReject of this.rejectCallableFunctions) {
          nextReject(err)
        }
      }
    }

    try {
      executor(resolve, reject)
    } catch(err) {
      reject(err)
    }
  }

  handleMyPromise(_onResolve: SyncPromiseResolver<T>, _onReject: SyncPromiseRejecter) {
    if (this instanceof SyncPromise) {
      this.then(_onResolve, _onReject)
    }
  }

  private executorBuilder(handler: CallableFunction): SyncPromiseExecutor<T> {
    return (resolve: SyncPromiseResolver<T>, reject: SyncPromiseRejecter) => {
      try {
        let res: T = handler();
        this.handleMyPromise.apply(res, [resolve, reject]);
        resolve(res);
      } catch (err) {
        reject(err);
      }
    }
  }

  private executorPendingBuilder(onResolve: SyncPromiseResolver<T>, onReject: SyncPromiseRejecter) {
    const callbackBuilder = (handler: CallableFunction, resolve: SyncPromiseResolver<T>, reject: SyncPromiseRejecter) => {
      return (val?: T) => {
        try {
          let res: T = handler(val)
          this.handleMyPromise.apply(res, [resolve, reject])
        } catch(err) {
          reject(err)
        }
      }
    }

    return (resolve: SyncPromiseResolver<T>, reject: SyncPromiseRejecter) => {
      this.resolveCallableFunctions.push(callbackBuilder(onResolve, resolve, reject))
      this.rejectCallableFunctions.push(callbackBuilder(onReject, resolve, reject))
    }
  }
  
  public then(_onResolve?: SyncPromiseResolver<T> | any, _onReject?: SyncPromiseRejecter | any) {
    const onResolve = typeof _onResolve === 'function' ? _onResolve.bind(null, this.result) : (val: T) => val;
    const onReject = typeof _onReject === 'function' ? _onReject.bind(null, this.result) : (val: T) => val;

    if (this.state === SyncPromiseState.fulfilled) {
      return new SyncPromise<T>(this.executorBuilder(onResolve))
    }

    if (this.state === SyncPromiseState.rejected) {
      return new SyncPromise<T>(this.executorBuilder(onReject))
    }

    if (this.state === SyncPromiseState.pending) {
      return new SyncPromise<T>(this.executorPendingBuilder.apply(this, [_onResolve, _onReject]));
    }
  }

  public catch(reason: any) {
    return this.then(null, reason)
  }
};


//@ts-ignore
window.SyncPromise = SyncPromise