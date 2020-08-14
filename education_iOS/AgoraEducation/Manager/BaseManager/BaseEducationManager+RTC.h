//
//  BaseEducationManager+RTC1.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager.h"
#import "RTCDelegate.h"
#import "RTCVideoSessionModel.h"
#import "RTCVideoCanvasModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseEducationManager (RTC)<RTCManagerDelegate>

- (void)initRTCEngineKitWithAppid:(NSString *)appid clientRole:(RTCClientRole)role dataSourceDelegate:(id<RTCDelegate> _Nullable)rtcDelegate;

- (int)joinRTCChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock;

- (void)setupRTCVideoCanvas:(RTCVideoCanvasModel *)model completeBlock:(void(^ _Nullable)(AgoraRtcVideoCanvas *videoCanvas))block;

- (void)setRTCClientRole:(RTCClientRole)role;

- (int)muteRTCLocalVideo:(BOOL) mute;
- (int)muteRTCLocalAudio:(BOOL) mute;

- (void)releaseRTCResources;

@end

NS_ASSUME_NONNULL_END
