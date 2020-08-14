import db from './db';

const ctx: DedicatedWorkerGlobalScope = self as any;
ctx.onmessage = async (evt: any) => {
  if (evt.data) {
    if (evt.data.type === 'log') {
      if (db.isOpen()) {
        // @ts-ignore
        await db.logs.put({ content: evt.data.data });
      } else {
        await db.open();
      }
    }
  }
};

export default null as any;
