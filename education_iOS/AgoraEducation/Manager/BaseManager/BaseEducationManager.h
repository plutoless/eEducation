//
//  BaseEducationManager.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EduConfigModel.h"

#import "SignalManager.h"
#import "SignalDelegate.h"

#import "WhiteManager.h"
#import "WhitePlayDelegate.h"

#import "RTCManager.h"
#import "RTCDelegate.h"

typedef NS_ENUM(NSInteger, SceneType) {
    SceneType1V1        = 0,
    SceneTypeSmall      = 1,
    SceneTypeBig        = 2,
};

typedef NS_ENUM(NSInteger, UserRoleType) {
    UserRoleTypeTeacher = 1,
    UserRoleTypeStudent = 2,
};

typedef NS_ENUM(NSInteger, ClassState) {
    ClassStateInClass        = 1,
    ClassStateOutClass       = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface BaseEducationManager : NSObject

// RTC
@property (nonatomic, strong) RTCManager *rtcManager;
@property (nonatomic, weak) id<RTCDelegate> rtcDelegate;

// Signal
@property (nonatomic, strong) SignalManager * _Nullable signalManager;
@property (nonatomic, weak) id<SignalDelegate> signalDelegate;

// White
@property (nonatomic, strong) WhiteManager *whiteManager;
@property (nonatomic, weak) id<WhitePlayDelegate> whitePlayerDelegate;

- (void)releaseResources;

@end

NS_ASSUME_NONNULL_END
