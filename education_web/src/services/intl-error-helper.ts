import {globalStore} from '../stores/global'
import GlobalStorage from '../utils/custom-storage';

const key = 'demo-i18n-error'

export function setIntlError (payload: any) {
  if (payload) {
    GlobalStorage.save(key, payload)
  }
}

function _getIntlError (error: string) {
  try {
    const locale = globalStore.getLanguage().match(/^zh/) ? 'zh-cn' : 'en-us';
    const rawData: any = GlobalStorage.read(key)
    const json = rawData || {}
    return json[locale][error]
  } catch(err) {
    console.warn(err)
    return null
  }
}

export function getIntlError (errorCode: string) {
  const res = _getIntlError(errorCode)
  // TODO: return errorCode when error message not reached 
  // TODO: 处理错误码
  if (!res) {
    return errorCode
  }
  return res;
}