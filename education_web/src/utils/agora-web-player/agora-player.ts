import { PlayerLogger } from './logger';

import { EventEmitter } from 'events'
import Videojs, {VideoJsPlayer} from 'video.js'
import './index.css';

import '@videojs/http-streaming'

export { TimelineScheduler } from './timeline-scheduler';

export interface AgoraPlayerCallback {
  onPhaseChanged: (evt: any) => void
}

type Player = VideoJsPlayer

export enum PhaseState {
  init = 'init',
  buffering = 'buffering',
  waiting = 'waiting',
  playing = 'playing',
  paused = 'paused',
  ended = 'ended',
  loading = 'loading'
}

export type PhaseStateType = 
  'init' |
  'buffering' |
  'playing' | 
  'paused' | 
  'ended' | 
  'waiting' |
  'ready' |
  'loading'

export class AgoraPlayer extends EventEmitter {

  public player: Player

  type: string

  public cover: string = ''

  private log: PlayerLogger

  public phaseState: PhaseStateType

  private $el: HTMLElement
  mediaType: string

  constructor(
    public readonly url: string,
    public readonly callback: AgoraPlayerCallback,
  ) {
    super()
    this.log = new PlayerLogger()

    this.$el = document.createElement('video')
    this.$el.id = 'video-player'
    this.$el.className = "video-js video-layout"
    this.player = Videojs(this.$el, {
      preload: 'auto',
      controls: false,
      autoplay: false,
      loop: false,
      html5: {
        hls: {
          overrideNative: true
        }
      }
    })

    this.type = this.url.split('.').pop() || 'mp4'

    const mediaTypes: any = {
      'm3u8': 'application/x-mpegURL',
      'mp4': 'video/mp4',
    }

    this.mediaType = mediaTypes[this.type] || 'video/mp4'
    if (!this.url) {
      console.error(`URL: invalid ${this.url}`)
    }
    this.phaseState = 'init'
    this.on('phaseChanged', (phaseState: any) => {
      callback.onPhaseChanged(phaseState)
      // this.log.info('phaseChanged', phaseState)
    })
  }

  initVideo (domId: string) {
    if (!domId) {
      throw `DOMException: domId shouldn't empty`
    }

    const $dom = document.getElementById(domId)
    if (!$dom) {
      throw `DOMException: couldn't find ${domId} element`
    }

    $dom.appendChild(this.$el)

    this.player.src({
      src: this.url,
      type: this.mediaType
    })

    this.player.on('loadeddata', (evt: any) => {
      this.emit('phaseChanged', this.phaseState = 'ready')
    })

    this.player.on('loadstart', (evt: any) => {
      this.emit('phaseChanged', this.phaseState = 'loading')
    })

    this.player.on('waiting', (evt: any) => {
      this.emit('phaseChanged', this.phaseState = 'waiting')
    })

    this.player.on('ended', (evt: any) => {
      this.emit('phaseChanged', this.phaseState = 'ended')
    })

    this.player.on('error', (evt: any) => {
      console.error('error', this.phaseState)
    })

    this.player.load();
  }

  get isPlaying () {
    return this.player.duration() > 0 
      && !this.player.paused() 
      && !this.player.ended()
      && this.player.readyState() > 2
  }

  play () {
    if (!this.isPlaying && this.player.paused()) {
      this.player.play()
    }
  }

  pause () {
    if (this.isPlaying && !this.player.paused()) {
      this.player.pause()
    }
  }

  seekTo(seconds: number) {
    const duration = this.player.duration()
    if (this.player.ended() && seconds !== 0) return
    this.player.currentTime(Math.min(seconds, duration))
  }

  destroy () {
    this.player.dispose()
  }
}
