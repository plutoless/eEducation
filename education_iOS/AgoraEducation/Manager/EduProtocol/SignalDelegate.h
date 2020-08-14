//
//  SignalDelegate.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalRoomModel.h"
#import "SignalUserModel.h"
#import "MessageModel.h"
#import "SignalReplayModel.h"
#import "SignalShareScreenModel.h"
#import "SignalP2PModel.h"

#import "SignalInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SignalDelegate <NSObject>

@optional

- (void)didReceivedPeerSignal:(SignalP2PInfoModel * _Nonnull)model;
- (void)didReceivedSignal:(SignalInfoModel *)signalInfoModel;

- (void)didReceivedMessage:(MessageInfoModel * _Nonnull)model;

- (void)didReceivedConnectionStateChanged:(AgoraRtmConnectionState)state;

@end

NS_ASSUME_NONNULL_END
