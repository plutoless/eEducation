//
//  WhiteReplayManager.h
//  AgoraEducation
//
//  Created by SRS on 2020/2/24.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Whiteboard/Whiteboard.h>
#import "ReplayManagerModel.h"

@protocol WhiteReplayProtocol <NSObject>

@required
- (void)whiteReplayerStartBuffering;
- (void)whiteReplayerEndBuffering;
- (void)whiteReplayerDidFinish;
- (void)whiteReplayerError:(NSError * _Nullable)error;

@optional

@end

NS_ASSUME_NONNULL_BEGIN

@interface WhiteReplayManager : NSObject

/** 设置 WhitePlayer，会同时更新 WhitePlayerPhase
 如果不设置，PauseReason 不会移除 CombineSyncManagerPauseReasonWaitingWhitePlayerBuffering 的 flag
 */
@property (nonatomic, strong, nullable, readwrite) WhitePlayer *whitePlayer;

@property (nonatomic, weak, nullable) id<WhiteReplayProtocol> delegate;

- (void)setupWithValue:(ReplayManagerModel *)model completeSuccessBlock:(void (^) (void)) successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;

/** 播放时，播放速率。即使暂停，该值也不会变为 0 */
@property (nonatomic, assign) CGFloat playbackSpeed;

- (void)play;
- (void)pause;
- (void)seekToScheduleTime:(NSTimeInterval)beginTime;

- (void)updateWhitePlayerPhase:(WhitePlayerPhase)phase;
@end

NS_ASSUME_NONNULL_END

