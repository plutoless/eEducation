//
//  RTCDelegate.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCEnum.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RTCDelegate <NSObject>

@optional

- (void)rtcDidJoinedOfUid:(NSUInteger)uid;

- (void)rtcDidOfflineOfUid:(NSUInteger)uid;

- (void)rtcNetworkTypeGrade:(RTCNetworkGrade)grade;

@end

NS_ASSUME_NONNULL_END
