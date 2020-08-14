//
//  RTCManager.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "RTCManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTCManager : NSObject

@property (nonatomic, strong) AgoraRtcEngineKit * _Nullable rtcEngineKit;

@property (nonatomic, weak) id<RTCManagerDelegate> rtcManagerDelegate;

- (void)initEngineKit:(NSString *)appid;

- (int)joinChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock;

- (void)setChannelProfile:(AgoraChannelProfile)channelProfile;
- (void)setVideoEncoderConfiguration:(AgoraVideoEncoderConfiguration*)configuration;
- (void)setClientRole:(AgoraClientRole)clientRole;
- (void)enableVideo;
- (void)startPreview;
- (void)enableWebSdkInteroperability:(BOOL) enabled;
- (void)enableDualStreamMode:(BOOL) enabled;
- (int)enableLocalVideo:(BOOL) enabled;
- (int)enableLocalAudio:(BOOL) enabled;
- (int)muteLocalVideoStream:(BOOL)enabled;
- (int)muteLocalAudioStream:(BOOL)enabled;
- (int)setRemoteVideoStream:(NSUInteger)uid type:(AgoraVideoStreamType)streamType;
- (int)stopPreview;

- (int)setupLocalVideo:(AgoraRtcVideoCanvas * _Nullable)local;
- (int)setupRemoteVideo:(AgoraRtcVideoCanvas * _Nonnull)remote;

- (void)releaseResources;
@end

NS_ASSUME_NONNULL_END
