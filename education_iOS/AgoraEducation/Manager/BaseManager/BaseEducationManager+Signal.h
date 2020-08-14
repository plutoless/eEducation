//
//  BaseEducationManager+BaseEducationManager_Signal.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/29.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager.h"
#import "SignalDelegate.h"
#import "SignalManager.h"
#import "MessageModel.h"
#import "SignalModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseEducationManager (Signal)<SignalManagerDelegate>

- (void)initSignalWithAppid:(NSString *)appid appToken:(NSString *)token userId:(NSString *)uid dataSourceDelegate:(id<SignalDelegate> _Nullable)signalDelegate completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock;

- (void)joinSignalWithChannelName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock;

- (void)handleRTMMessage:(NSString *)messageText;

- (void)releaseSignalResources;

@end

NS_ASSUME_NONNULL_END
