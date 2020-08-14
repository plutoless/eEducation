//
//  BaseEducationManager+RTC1.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager+RTC.h"

@implementation BaseEducationManager (RTC)

- (void)initRTCEngineKitWithAppid:(NSString *)appid clientRole:(RTCClientRole)role dataSourceDelegate:(id<RTCDelegate> _Nullable)rtcDelegate {
    
    AgoraLogInfo(@"init rtcEngineKit appid:%@", appid);
    
    self.rtcDelegate = rtcDelegate;

    self.rtcManager = [[RTCManager alloc] init];
    self.rtcManager.rtcManagerDelegate = self;
    [self.rtcManager initEngineKit:appid];
    [self.rtcManager setChannelProfile:(AgoraChannelProfileLiveBroadcasting)];
    
    AgoraVideoEncoderConfiguration *configuration = [AgoraVideoEncoderConfiguration new];
    configuration.dimensions = AgoraVideoDimension360x360;
    configuration.frameRate = 15;
    configuration.bitrate = AgoraVideoBitrateStandard;
    configuration.orientationMode = AgoraVideoOutputOrientationModeFixedLandscape;
    [self.rtcManager setVideoEncoderConfiguration:configuration];

    [self.rtcManager enableVideo];
    [self.rtcManager enableWebSdkInteroperability:YES];
    [self.rtcManager enableDualStreamMode:YES];
    [self setRTCClientRole: role];
    if(role == RTCClientRoleBroadcaster){
        [self.rtcManager startPreview];
    }
}

- (int)joinRTCChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock {
    
    AgoraLogInfo(@"join rtc token:%@ channel:%@", token, channelId);
    return [self.rtcManager joinChannelByToken:token channelId:channelId info:info uid:uid joinSuccess:joinSuccessBlock];
}

- (void)setupRTCVideoCanvas:(RTCVideoCanvasModel *)model completeBlock:(void(^ _Nullable)(AgoraRtcVideoCanvas *videoCanvas))block {
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = model.uid;
    videoCanvas.view = model.videoView;
    
    if(model.renderMode == RTCVideoRenderModeFit) {
        videoCanvas.renderMode = AgoraVideoRenderModeFit;
    } else if(model.renderMode == RTCVideoRenderModeHidden){
        videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    }

    if(model.canvasType == RTCVideoCanvasTypeLocal) {
        [self.rtcManager setupLocalVideo: videoCanvas];
    } else if(model.canvasType == RTCVideoCanvasTypeRemote) {
        [self.rtcManager setupRemoteVideo: videoCanvas];
    }
    
    if(block != nil){
        block(videoCanvas);
    }
}

- (void)setRTCClientRole:(RTCClientRole)role {
    if(role == RTCClientRoleAudience){
        [self.rtcManager setClientRole:(AgoraClientRoleAudience)];
        AgoraLogInfo(@"set role audience");
    } else if(role == RTCClientRoleBroadcaster){
        [self.rtcManager setClientRole:(AgoraClientRoleBroadcaster)];
        AgoraLogInfo(@"set role broadcaster");
    }
}

- (int)muteRTCLocalVideo:(BOOL) mute {
    AgoraLogInfo(@"muteRTCLocalVideo: %d", mute);
    return [self.rtcManager muteLocalVideoStream:mute];
}
- (int)muteRTCLocalAudio:(BOOL) mute {
    AgoraLogInfo(@"muteRTCLocalAudio: %d", mute);
    return [self.rtcManager muteLocalAudioStream:mute];
}

- (void)releaseRTCResources {
    AgoraLogInfo(@"releaseRTCResources");
    [self.rtcManager releaseResources];
}

#pragma mark RTCManagerDelegate
- (void)rtcEngine:(AgoraRtcEngineKit *_Nullable)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    AgoraLogInfo(@"didJoinedOfUid: %lu", (unsigned long)uid);
    if([self.rtcDelegate respondsToSelector:@selector(rtcDidJoinedOfUid:)]) {
        [self.rtcDelegate rtcDidJoinedOfUid:uid];
    }
}
- (void)rtcEngine:(AgoraRtcEngineKit *_Nullable)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    
    AgoraLogInfo(@"didOfflineOfUid: %lu", (unsigned long)uid);
    if([self.rtcDelegate respondsToSelector:@selector(rtcDidOfflineOfUid:)]) {
        [self.rtcDelegate rtcDidOfflineOfUid:uid];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine networkQuality:(NSUInteger)uid txQuality:(AgoraNetworkQuality)txQuality rxQuality:(AgoraNetworkQuality)rxQuality {
    
    // local user uid = 0
    if(uid != 0){
        return;
    }
    
    RTCNetworkGrade grade = RTCNetworkGradeUnknown;
    
    AgoraNetworkQuality quality = MAX(txQuality, rxQuality);
    switch (quality) {
        case AgoraNetworkQualityExcellent:
        case AgoraNetworkQualityGood:
            grade = RTCNetworkGradeHigh;
            break;
        case AgoraNetworkQualityPoor:
        case AgoraNetworkQualityBad:
            grade = RTCNetworkGradeMiddle;
            break;
        case AgoraNetworkQualityVBad:
        case AgoraNetworkQualityDown:
            grade = RTCNetworkGradeLow;
            break;
        default:
            break;
    }
    
    if([self.rtcDelegate respondsToSelector:@selector(rtcNetworkTypeGrade:)]) {
        [self.rtcDelegate rtcNetworkTypeGrade:grade];
    }
}

@end
