export interface ChatMessage {
  account: string
  text: string
  link?: string
  ts: number
  id: string
}
export enum ClassState {
  CLOSED = 0,
  STARTED = 1
}

export interface AgoraMediaStream {
  streamID: number
  local: boolean
  account?: string
  stream?: any
  video?: boolean
  audio?: boolean
  playing?: boolean
}

export class AgoraStream {
  constructor(
    public readonly stream: any = stream,
    public readonly streamID: number = streamID,
    public readonly local: boolean = local,
  ) {
  }
}