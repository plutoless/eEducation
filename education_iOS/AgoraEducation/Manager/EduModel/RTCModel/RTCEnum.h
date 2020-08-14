//
//  RTCEnum.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Video display mode. */
typedef NS_ENUM(NSUInteger, RTCVideoRenderMode) {
    RTCVideoRenderModeHidden = 1,
    RTCVideoRenderModeFit = 2,
};

/** Local or remote videoCanvas. */
typedef NS_ENUM(NSUInteger, RTCVideoCanvasType) {
    RTCVideoCanvasTypeLocal = 1,
    RTCVideoCanvasTypeRemote = 2,
};

/** Client role in a live broadcast. */
typedef NS_ENUM(NSInteger, RTCClientRole) {
    RTCClientRoleBroadcaster = 1,
    RTCClientRoleAudience = 2,
};

typedef NS_ENUM(NSInteger, RTCVideoStreamType) {
    RTCVideoStreamTypeHigh = 0,
    RTCVideoStreamTypeLow = 1,
};

/** Network type. */
typedef NS_ENUM(NSInteger, RTCNetworkGrade) {
    RTCNetworkGradeUnknown = -1,
    RTCNetworkGradeHigh = 1,
    RTCNetworkGradeMiddle = 2,
    RTCNetworkGradeLow = 3,
};
