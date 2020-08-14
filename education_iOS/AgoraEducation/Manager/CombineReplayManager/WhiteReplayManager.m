//
//  WhiteReplayManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/2/24.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "WhiteReplayManager.h"
#import "HttpManager.h"

@interface WhiteReplayManager()<WhiteCommonCallbackDelegate, WhitePlayerEventDelegate>
@property (nonatomic, strong) WhiteSDK * _Nullable whiteSDK;
@end

@implementation WhiteReplayManager

- (void)setupWithValue:(ReplayManagerModel *)model completeSuccessBlock:(void (^) (void)) successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock {
    
    NSAssert(model.startTime && model.startTime.length == 13, @"startTime must be millisecond unit");
    NSAssert(model.endTime && model.endTime.length == 13, @"endTime must be millisecond unit");
    
    [self initWhiteSDKWithBoardView:model.boardView];
    
    WEAK(self);
    WhitePlayerConfig *playerConfig = [[WhitePlayerConfig alloc] initWithRoom:model.uuid roomToken:model.uutoken];
    
    // make up
    NSInteger iStartTime = [model.startTime substringToIndex:10].integerValue;
    NSInteger iDuration = labs(model.endTime.integerValue - model.startTime.integerValue) * 0.001;

    playerConfig.beginTimestamp = @(iStartTime);
    playerConfig.duration = @(iDuration);

    [self.whiteSDK createReplayerWithConfig:playerConfig callbacks:self completionHandler:^(BOOL success, WhitePlayer * _Nonnull player, NSError * _Nonnull error) {
        if (success) {
            weakself.whitePlayer = player;
            [weakself.whitePlayer refreshViewSize];

            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil){
                failBlock(error);
                AgoraLogError(@"createReplayer Err:%@", error);
            }
        }
    }];
}

- (void)initWhiteSDKWithBoardView:(WhiteBoardView *)boardView {
    self.whiteSDK = [[WhiteSDK alloc] initWithWhiteBoardView:boardView config:[WhiteSdkConfiguration defaultConfig] commonCallbackDelegate:self];
}

- (void)updateWhitePlayerPhase:(WhitePlayerPhase)phase {
    // WhitePlay 处于缓冲状态，pauseReson 加上 whitePlayerBuffering
    if (phase == WhitePlayerPhaseBuffering || phase == WhitePlayerPhaseWaitingFirstFrame) {
        [self whitePlayerStartBuffing];
    }
    // 进入暂停状态，whitePlayer 已经完成缓冲，移除 whitePlayerBufferring
    else if (phase == WhitePlayerPhasePause || phase == WhitePlayerPhasePlaying) {
        [self whitePlayerEndBuffering];
    }
}

- (void)setPlaybackSpeed:(CGFloat)playbackSpeed {
    _playbackSpeed = playbackSpeed;
    self.whitePlayer.playbackSpeed = playbackSpeed;
}

- (void)play {
    [self.whitePlayer play];
}

- (void)pause {
    [self.whitePlayer pause];
}

- (void)seekToScheduleTime:(NSTimeInterval)beginTime {
    [self.whitePlayer seekToScheduleTime:beginTime];
}

#pragma mark - white player buffering
- (void)whitePlayerStartBuffing {
    if ([self.delegate respondsToSelector:@selector(whiteReplayerStartBuffering)]) {
        [self.delegate whiteReplayerStartBuffering];
    }
}

- (void)whitePlayerEndBuffering {
    if ([self.delegate respondsToSelector:@selector(whiteReplayerEndBuffering)]) {
        [self.delegate whiteReplayerEndBuffering];
    }
}

#pragma mark WhitePlayerEventDelegate
- (void)phaseChanged:(WhitePlayerPhase)phase {
    [self updateWhitePlayerPhase:phase];
}
- (void)stoppedWithError:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(whiteReplayerError:)]) {
        [self.delegate whiteReplayerError: error];
    }
}
- (void)errorWhenAppendFrame:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(whiteReplayerError:)]) {
        [self.delegate whiteReplayerError: error];
    }
}
- (void)errorWhenRender:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(whiteReplayerError:)]) {
        [self.delegate whiteReplayerError: error];
    }
}

#pragma mark WhiteCommonCallbackDelegate
- (void)throwError:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(whiteReplayerError:)]) {
        [self.delegate whiteReplayerError: error];
    }
}

- (void)dealloc {
    if(self.whitePlayer != nil) {
        [self.whitePlayer stop];
    }
    self.whitePlayer = nil;
    self.whiteSDK = nil;
}
@end
