import Dexie from 'dexie';

const db = new Dexie('webdemo_agora_edu');

db.version(1).stores({
  logs: 'content'
});

export default db;
