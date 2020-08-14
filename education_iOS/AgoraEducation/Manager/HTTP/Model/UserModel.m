//
//  UserModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/4/23.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }

  if (![object isKindOfClass:[UserModel class]]) {
    return NO;
  }

  return [self isEqualToModel:(UserModel *)object];
}

- (BOOL)isEqualToModel:(UserModel *)model {
    if (!model) {
        return NO;
    }

    BOOL equalUserId = (!self.userId && !model.userId) || [self.userId isEqualToString:model.userId];
    BOOL equalUserName = (!self.userName && !model.userName) || [self.userName isEqualToString:model.userName];
    BOOL equalRole = self.role == model.role;
    BOOL equalEnableChat = self.enableChat == model.enableChat;
    BOOL equalEnableVideo = self.enableVideo == model.enableVideo;
    BOOL equalEnableAudio = self.enableAudio == model.enableAudio;
    BOOL equalUid = self.uid == model.uid;
    BOOL equalGrantBoard = self.grantBoard == model.grantBoard;
    BOOL equalScreenId = self.screenId == model.screenId;

  return equalUserId
    && equalUserName
    && equalRole
    && equalEnableChat
    && equalEnableVideo
    && equalEnableAudio
    && equalUid
    && equalGrantBoard
    && equalScreenId;
}

- (NSUInteger)hash {
  return [self.userId hash]
    ^ [self.userName hash]
    ^ [@(self.role) hash]
    ^ [@(self.enableChat) hash]
    ^ [@(self.enableVideo) hash]
    ^ [@(self.enableAudio) hash]
    ^ [@(self.uid) hash]
    ^ [@(self.grantBoard) hash]
    ^ [@(self.screenId) hash];
}

@end
