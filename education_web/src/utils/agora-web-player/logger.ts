export enum LogLevel {
  DEBUG = 'debug',
  NONE = 'none'
}

const rawLog = console

export class PlayerLogger {
  constructor (public readonly level: LogLevel = LogLevel.DEBUG) {
  }

  prefix(text: string) {
    return `[${this.level}] ${text}`
  }

  info (text: string, ...args: any[]) {
    rawLog.info(this.prefix(text), ...args)
  }

  warn (text: string, ...args: any[]) {
    rawLog.info(this.prefix(text), ...args)
  }

  error (text: string, ...args: any[]) {
    rawLog.error(this.prefix(text), ...args)
  }
}