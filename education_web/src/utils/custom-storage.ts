import { isEmpty } from "lodash";

export class CustomStorage {

  private storage: Storage;

  languageKey: string = 'demo_language'

  constructor() {
    this.storage = window.sessionStorage;
  }

  read(key: string): any {
    try {
      let json = JSON.parse(this.storage.getItem(key) as string);
      return json
    } catch(_) {
      return this.storage.getItem(key);
    }
  }

  save(key: string, val: any) {
    this.storage.setItem(key, JSON.stringify(val));
  }

  clear(key: string) {
    this.storage.removeItem(key);
  }

  setLanguage(lang: string) {
    this.save(this.languageKey, lang)
  }

  getLanguage() {
    const language = this.read(this.languageKey) ? this.read(this.languageKey) : navigator.language;
    return {language};
  }

  getRtmMessage (): {count: any, messages: any[]} {
    const channelMessages = GlobalStorage.read('channelMessages');
    if (isEmpty(channelMessages)) return {
      count: 0,
      messages: []
    }
    const messages = channelMessages.filter((it: any) => it.message_type === "group_message");
    const chatMessages = messages.reduce((collect: any[], value: any) => {
      const payload = value.payload;
      const json = JSON.parse(payload);
      if (json.content) {
        return collect.concat({
          account: json.account,
          content: json.content,
          ms: value.ms,
          src: value.src
        });
      }
      return collect;
    }, []);
    return {
      messages: chatMessages,
      count: chatMessages.length
    }
  }
}

const GlobalStorage = new CustomStorage();
// @ts-ignore
window.GlobalStorage = GlobalStorage;
export default GlobalStorage;