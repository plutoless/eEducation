//
//  RTCVideoSessionModel.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTCVideoSessionModel : NSObject

@property (nonatomic, assign) NSUInteger uid;
@property (nonatomic, strong) AgoraRtcVideoCanvas * _Nullable videoCanvas;

@end

NS_ASSUME_NONNULL_END
