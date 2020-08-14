import { WhiteWebSdk, ReplayRoomParams, PlayerCallbacks } from 'white-web-sdk';

export const WhiteboardAPI = {
  async replayRoom(client: WhiteWebSdk, args: ReplayRoomParams, callback: PlayerCallbacks) {
    let retrying;
    do {
      try {
        let result = await client.replayRoom({
          beginTimestamp: args.beginTimestamp,
          duration: args.duration,
          room: args.room,
          mediaURL: args.mediaURL,
          roomToken: args.roomToken,
        }, callback);
        retrying = false;
        return result;
      } catch (err) {
        retrying = true;
      }
    } while (retrying);
  }
}