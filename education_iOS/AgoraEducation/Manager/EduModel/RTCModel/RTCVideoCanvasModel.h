//
//  RTCVideoCanvasModel.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTCVideoCanvasModel : NSObject

@property (nonatomic, assign) NSUInteger uid;
@property (nonatomic, weak) UIView *videoView;
@property (nonatomic, assign) RTCVideoRenderMode renderMode;
@property (nonatomic, assign) RTCVideoCanvasType canvasType;

@end

NS_ASSUME_NONNULL_END
