//
//  RoomAllModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/8.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RoomModel : NSObject
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger courseState;// 1=inclass 2=outclass
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger muteAllChat;
@property (nonatomic, assign) NSInteger isRecording;
@property (nonatomic, strong) NSString *recordId;
@property (nonatomic, assign) NSInteger recordingTime;
@property (nonatomic, assign) NSInteger lockBoard; //1=locked 0=no lock
@property (nonatomic, strong) NSArray<UserModel*> *coVideoUsers;
@end

@interface RoomInfoModel : NSObject
@property (nonatomic, strong) RoomModel *room;
@property (nonatomic, strong) UserModel *localUser;
@end

@interface RoomAllModel : NSObject
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) RoomInfoModel *data;
@end

NS_ASSUME_NONNULL_END
