//
//  CombineReplayManager.h
//  AgoraEducation
//
//  Created by SRS on 2020/2/24.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ReplayManagerModel.h"

@protocol CombineReplayDelegate <NSObject>

@required
- (void)combinePlayTimeChanged:(NSTimeInterval)time;
- (void)combinePlayStartBuffering;
- (void)combinePlayEndBuffering;
- (void)combinePlayDidFinish;

// 由外部事件打断，比如用户主动进入后台
- (void)combinePlayPause;
- (void)combinePlayError:(NSError * _Nullable)error;

@optional
- (void)rtcPlayDidFinish;
- (void)whitePlayDidFinish;

@end

NS_ASSUME_NONNULL_BEGIN

#pragma mark - CombineSyncManagerPauseReason

typedef NS_OPTIONS(NSUInteger, CombineSyncManagerPauseReason) {
    //正常播放
    CombineSyncManagerPauseReasonNone                           = 0,
    //暂停，暂停原因：白板缓冲
    CombineSyncManagerPauseReasonWaitingWhitePlayerBuffering    = 1 << 0,
    //暂停，暂停原因：音视频缓冲
    CombineSyncManagerPauseReasonWaitingRTCPlayerBuffering      = 1 << 1,
    //暂停，暂停原因：主动暂停
    CombineSyncManagerWaitingPauseReasonPlayerPause             = 1 << 2,
    //初始状态，暂停，全缓冲
    CombineSyncManagerPauseReasonInit                           = CombineSyncManagerPauseReasonWaitingWhitePlayerBuffering | CombineSyncManagerPauseReasonWaitingRTCPlayerBuffering | CombineSyncManagerWaitingPauseReasonPlayerPause,
};


#pragma mark - CombineReplayManager
@interface CombineReplayManager : NSObject

@property (nonatomic, weak, nullable) id<CombineReplayDelegate> delegate;

/** 播放时，播放速率。即使暂停，该值也不会变为 0 */
@property (nonatomic, assign) CGFloat playbackSpeed;

/** 暂停原因，默认所有 buffer + 主动暂停 */
@property (nonatomic, assign, readonly) NSUInteger pauseReason;

- (AVPlayer *)setupRTCReplayWithURL:(NSURL *)mediaUrl;
- (void)setupWhiteReplayWithValue:(ReplayManagerModel *)model completeSuccessBlock:(void (^) (void)) successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;

- (void)play;
- (void)pause;
- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler;

- (void)updateWhitePlayerPhase:(WhitePlayerPhase)phase;

- (void)releaseResource;
@end

NS_ASSUME_NONNULL_END

