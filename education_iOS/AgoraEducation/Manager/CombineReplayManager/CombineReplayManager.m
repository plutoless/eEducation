//
//  CombineReplayManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/2/24.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "CombineReplayManager.h"
#import "RTCReplayManager.h"
#import "WhiteReplayManager.h"

@interface CombineReplayManager ()<RTCReplayProtocol, WhiteReplayProtocol> {
    CADisplayLink *_displayLink;
    NSInteger _frameInterval;
    NSTimeInterval _displayDurationTime;
}

@property (nonatomic, assign, readwrite) NSUInteger pauseReason;

@property (nonatomic, strong) RTCReplayManager *rtcReplayManager;
@property (nonatomic, strong) WhiteReplayManager *whiteReplayManager;

@property (nonatomic, copy) NSString *classStartTime;
@property (nonatomic, copy) NSString *classEndTime;

@end

@implementation CombineReplayManager

- (instancetype)init {
    if(self = [super init]){

        _frameInterval = 60;
        _displayDurationTime = 0;
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
        _displayLink.preferredFramesPerSecond =_frameInterval;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
        
        _pauseReason = CombineSyncManagerPauseReasonInit;
        
        [self registerNotification];
    }
    return self;
}

#pragma mark - Notification
- (void)registerNotification {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
}

- (void)applicationWillResignActive {
    if(!_displayLink.paused) {
        [self pause];
        if ([self.delegate respondsToSelector:@selector(combinePlayPause)]) {
            [self.delegate combinePlayPause];
        }
    }
}

- (AVPlayer *)setupRTCReplayWithURL:(NSURL *)mediaUrl {
    self.rtcReplayManager = [[RTCReplayManager alloc] initWithMediaUrl:mediaUrl];
    self.rtcReplayManager.delegate = self;
    return self.rtcReplayManager.nativePlayer;
}

- (void)setupWhiteReplayWithValue:(ReplayManagerModel *)model completeSuccessBlock:(void (^) (void)) successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock {
    
    self.classStartTime = model.startTime;
    self.classEndTime = model.endTime;

    self.whiteReplayManager = [WhiteReplayManager new];
    self.whiteReplayManager.delegate = self;
    [self.whiteReplayManager setupWithValue:model completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)onDisplayLink: (CADisplayLink *)displayLink {
    
    NSTimeInterval classDurationTime = self.classEndTime.integerValue - self.classStartTime.integerValue;
    
    _displayDurationTime += displayLink.duration;

    if(_displayDurationTime * 1000 > classDurationTime) {
        [self finish];
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(combinePlayTimeChanged:)]) {
        [_delegate combinePlayTimeChanged:_displayDurationTime];
    }
}

- (void)updateWhitePlayerPhase:(WhitePlayerPhase)phase {
    [self.whiteReplayManager updateWhitePlayerPhase:phase];
}

- (void)stopDisplayLink {
    if (_displayLink){
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

#pragma mark - Play Control
- (void)setPlaybackSpeed:(CGFloat)playbackSpeed {
    _playbackSpeed = playbackSpeed;
    [self.rtcReplayManager setPlaybackSpeed:playbackSpeed];
    [self.whiteReplayManager setPlaybackSpeed:playbackSpeed];
}

#pragma mark - Public Methods
- (void)play {
    
    self.pauseReason = self.pauseReason & ~CombineSyncManagerWaitingPauseReasonPlayerPause;
    [self.rtcReplayManager play];
    
    // video 将直接播放，whitePlayer 也直接播放
    if ([self.rtcReplayManager hasEnoughBuffer]) {
        AgoraLogInfo(@"play directly");
        [self.whiteReplayManager play];
        
        _displayLink.paused = NO;
    }
}

- (void)pause {
    self.pauseReason = self.pauseReason | CombineSyncManagerWaitingPauseReasonPlayerPause;
    
    _displayLink.paused = YES;
    [self.rtcReplayManager pause];
    [self.whiteReplayManager pause];
}

- (void)finish {
    _displayLink.paused = YES;
    if ([self.delegate respondsToSelector:@selector(combinePlayDidFinish)]) {
        [self.delegate combinePlayDidFinish];
    }
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler {
        
    NSTimeInterval seekTime = CMTimeGetSeconds(time);
    [self.whiteReplayManager seekToScheduleTime:seekTime];
    [self setDisplayDurationTime:seekTime];
    AgoraLogInfo(@"seekTime: %f", seekTime);

    // 如果seek超出视频长度，finished为false，并且默认seek到最后一帧
    [self.rtcReplayManager seekToTime:time completionHandler:^(NSTimeInterval realTime, BOOL finished) {
        completionHandler(finished);
    }];
}

- (void)setDisplayDurationTime:(NSTimeInterval)time {
    _displayDurationTime = time;
}

#pragma mark RTCReplayProtocol
- (void)rtcReplayStartBuffering {
    if ([self.delegate respondsToSelector:@selector(combinePlayStartBuffering)]) {
        [self.delegate combinePlayStartBuffering];
    }
    
    AgoraLogInfo(@"startNativeBuffering");
    
    //加上 native 缓冲标识
    self.pauseReason = self.pauseReason | CombineSyncManagerPauseReasonWaitingRTCPlayerBuffering;
    
    //whitePlayer 加载 buffering 的行为，一旦开始，不会停止。所以直接暂停播放即可。
    [self.whiteReplayManager pause];
    _displayLink.paused = YES;
}

- (void)rtcReplayEndBuffering {
    BOOL isBuffering = !(self.pauseReason & CombineSyncManagerPauseReasonWaitingWhitePlayerBuffering) || (self.pauseReason & CombineSyncManagerPauseReasonWaitingRTCPlayerBuffering);

    self.pauseReason = self.pauseReason & ~CombineSyncManagerPauseReasonWaitingRTCPlayerBuffering;
    
    AgoraLogInfo(@"nativeEndBuffering %lu", (unsigned long)self.pauseReason);
    
    /**
     1. WhitePlayer 还在缓冲(01)，暂停
     2. WhitePlayer 不在缓冲(00)，结束缓冲
     */
    if (self.pauseReason & CombineSyncManagerPauseReasonWaitingWhitePlayerBuffering) {
        [self.rtcReplayManager pause];
    } else if (!isBuffering && [self.delegate respondsToSelector:@selector(combinePlayEndBuffering)]) {
        [self.delegate combinePlayEndBuffering];
    }
    
    /**
     1. 目前是播放状态（100），没有任何一个播放器，处于缓冲，调用两端播放API
     2. 目前是主动暂停（000），暂停白板
     3. whitePlayer 还在缓存（101、110），已经在处理缓冲回调的位置，处理完毕
     */
    if (self.pauseReason == CombineSyncManagerPauseReasonNone) {
        [self.rtcReplayManager play];
        [self.whiteReplayManager play];
        _displayLink.paused = NO;
    } else if (self.pauseReason & CombineSyncManagerWaitingPauseReasonPlayerPause) {
        [self.rtcReplayManager pause];
        [self.whiteReplayManager pause];
    }
}
- (void)rtcReplayDidFinish {
    if ([self.delegate respondsToSelector:@selector(rtcPlayDidFinish)]) {
        [self.delegate rtcPlayDidFinish];
    }
}

- (void)rtcReplayPause {
    if(!_displayLink.paused) {
        [self pause];
        if ([self.delegate respondsToSelector:@selector(combinePlayPause)]) {
            [self.delegate combinePlayPause];
        }
    }
}

- (void)rtcReplayError:(NSError * _Nullable)error {
    
    [self pause];
    if ([self.delegate respondsToSelector:@selector(combinePlayError:)]) {
        [self.delegate combinePlayError:error];
    }
}

#pragma mark WhiteReplayProtocol
- (void)whiteReplayerStartBuffering {
    if ([self.delegate respondsToSelector:@selector(combinePlayStartBuffering)]) {
        [self.delegate combinePlayStartBuffering];
    }
    
    self.pauseReason = self.pauseReason | CombineSyncManagerPauseReasonWaitingWhitePlayerBuffering;
    
    [self.rtcReplayManager pause];
    
    _displayLink.paused = YES;
}
- (void)whiteReplayerEndBuffering {
    
    BOOL isBuffering = !(self.pauseReason & CombineSyncManagerPauseReasonWaitingWhitePlayerBuffering) || (self.pauseReason & CombineSyncManagerPauseReasonWaitingRTCPlayerBuffering);
    
    self.pauseReason = self.pauseReason & ~CombineSyncManagerPauseReasonWaitingWhitePlayerBuffering;
    
    AgoraLogInfo(@"playerEndBuffering %lu", (unsigned long)self.pauseReason);
    
    /**
     1. native 还在缓存(10)，主动暂停 whitePlayer
     2. native 不在缓存(00)，缓冲结束
     */
    if (self.pauseReason & CombineSyncManagerPauseReasonWaitingRTCPlayerBuffering) {
        [self.whiteReplayManager pause];
    } else if (!isBuffering && [self.delegate respondsToSelector:@selector(combinePlayEndBuffering)]) {
        [self.delegate combinePlayEndBuffering];
    }
    
    /**
     1. 目前是播放状态（100），没有任何一个播放器，处于缓冲，调用两端播放API
     2. 目前是主动暂停（000），暂停白板
     3. native 还在缓存（110、010），已经在处理缓冲回调的位置，处理完毕
     */
    if (self.pauseReason == CombineSyncManagerPauseReasonNone) {
        [self.rtcReplayManager play];
        [self.whiteReplayManager play];
        _displayLink.paused = NO;
    } else if (self.pauseReason & CombineSyncManagerWaitingPauseReasonPlayerPause) {
        [self.rtcReplayManager pause];
        [self.whiteReplayManager pause];
    }
}
- (void)whiteReplayerDidFinish {
    if ([self.delegate respondsToSelector:@selector(whitePlayDidFinish)]) {
        [self.delegate whitePlayDidFinish];
    }
}
- (void)whiteReplayerError:(NSError * _Nullable)error {
    [self pause];
    if ([self.delegate respondsToSelector:@selector(combinePlayError:)]) {
        [self.delegate combinePlayError:error];
    }
}

- (void)releaseResource {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self stopDisplayLink];
}

- (void)dealloc {
    [self releaseResource];
}
@end

