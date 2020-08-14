//
//  URL.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/16.
//  Copyright © 2020 yangmoumou. All rights reserved.
//


#define HTTP_BASE_URL @"https://api.agora.io"

#define HTTP_GET_LANGUAGE @"%@/edu/v1/multi/language"

// http: get app config
#define HTTP_LOG_PARAMS @"%@/edu/v1/log/params"
// http: get app config
#define HTTP_OSS_STS @"%@/edu/v1/log/sts"
// http: get app config
#define HTTP_OSS_STS_CALLBACK @"%@/edu/v1/log/sts/callback"

// /edu/v1/apps/{appId}/room/entry
#define HTTP_ENTER_ROOM @"%@/edu/v1/apps/%@/room/entry"

// /edu/v1/apps/{appId}/room/exit
#define HTTP_LEFT_ROOM @"%@/edu/v1/apps/%@/room/%@/exit"

// http: get or update global state
// /edu/v1/apps/{appId}/room/{roomId}
#define HTTP_ROOM_INFO @"%@/edu/v1/apps/%@/room/%@"

#warning if you want to configure your own whiteboard information，you need to use your own backend service API
// http: get white board keys in room
// /edu/v1/apps/{appId}/room/{roomId}
#define HTTP_WHITE_ROOM_INFO @"%@/edu/v1/apps/%@/room/%@/board"

// http: update user info
// /edu/v1/apps/{appId}/room/{roomId}/user/{userId}
#define HTTP_UPDATE_USER_INFO @"%@/edu/v1/apps/%@/room/%@/user/%@"

// http: im
// /edu/v1/apps/{appId}/room/{roomId}/chat
#define HTTP_USER_INSTANT_MESSAGE @"%@/edu/v1/apps/%@/room/%@/chat"

// http: covideo
// /edu/v1/apps/{appId}/room/{roomId}/covideo
#define HTTP_USER_COVIDEO @"%@/edu/v1/apps/%@/room/%@/covideo"

// http: get replay info
// /edu/v1/apps/{appId}/room/{roomId}/record/{recordId}
#define HTTP_GET_REPLAY_INFO @"%@/edu/v1/apps/%@/room/%@/record/%@"
