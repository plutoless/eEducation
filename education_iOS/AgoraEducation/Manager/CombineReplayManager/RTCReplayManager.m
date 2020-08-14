//
//  RTCReplayManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/2/24.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "RTCReplayManager.h"

#pragma mark - KVO
static NSString * const kRateKey = @"rate";
static NSString * const kCurrentItemKey = @"currentItem";
static NSString * const kStatusKey = @"status";
static NSString * const kPlaybackLikelyToKeepUpKey = @"playbackLikelyToKeepUp";
static NSString * const kPlaybackBufferFullKey = @"playbackBufferFull";
static NSString * const kPlaybackBufferEmptyKey = @"playbackBufferEmpty";
static NSString * const kLoadedTimeRangesKey = @"loadedTimeRanges";

@interface RTCReplayManager ()
@property (nonatomic, assign, getter=isRouteChangedWhilePlaying) BOOL routeChangedWhilePlaying;
@property (nonatomic, assign, getter=isInterruptedWhilePlaying) BOOL interruptedWhilePlaying;
@end

@implementation RTCReplayManager
- (instancetype)initWithMediaUrl:(NSURL *)mediaUrl {
    AVPlayer *videoPlayer = [AVPlayer playerWithURL:mediaUrl];
    return [self initWithVideoPlayer:videoPlayer];
}

- (instancetype)initWithVideoPlayer:(AVPlayer *)nativePlayer {
    if (self = [super init]) {
        _nativePlayer = nativePlayer;
        _playbackSpeed = 1;
    }
    [self registerNotificationAndKVO];
    return self;
}

- (void)registerNotificationAndKVO {
    [self registerAudioSessionNotification];
    [self.nativePlayer addObserver:self forKeyPath:kRateKey options:0 context:nil];
    [self.nativePlayer addObserver:self forKeyPath:kCurrentItemKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

// 推荐使用 KVOController 做 KVO 监听
- (void)addObserverWithPlayItem:(AVPlayerItem *)item
{
    [item addObserver:self forKeyPath:kStatusKey options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:kLoadedTimeRangesKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
    [item addObserver:self forKeyPath:kPlaybackLikelyToKeepUpKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
    [item addObserver:self forKeyPath:kPlaybackBufferFullKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
    [item addObserver:self forKeyPath:kPlaybackBufferEmptyKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
}

- (void)removeObserverWithPlayItem:(AVPlayerItem *)item
{
    [item removeObserver:self forKeyPath:kStatusKey];
    [item removeObserver:self forKeyPath:kLoadedTimeRangesKey];
    [item removeObserver:self forKeyPath:kPlaybackLikelyToKeepUpKey];
    [item removeObserver:self forKeyPath:kPlaybackBufferFullKey];
    [item removeObserver:self forKeyPath:kPlaybackBufferEmptyKey];
}

#pragma mark - Notification
- (void)registerAudioSessionNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
#if TARGET_OS_IPHONE
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(interruption:)
//                                                 name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
#endif
}

#pragma mark - Notification
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    if (notification.object == self.nativePlayer.currentItem && [self.delegate respondsToSelector:@selector(rtcReplayDidFinish)]) {
        [self.delegate rtcReplayDidFinish];
    }
}

//- (void)interruption:(NSNotification *)notification {
//    NSDictionary *interuptionDict = notification.userInfo;
//    NSInteger interruptionType = [interuptionDict[AVAudioSessionInterruptionTypeKey] integerValue];
//
//    if (interruptionType == AVAudioSessionInterruptionTypeBegan && [self videoDesireToPlay]) {
//        self.interruptedWhilePlaying = YES;
//        [self pause];
//    } else if (interruptionType == AVAudioSessionInterruptionTypeEnded && self.isInterruptedWhilePlaying) {
//        self.interruptedWhilePlaying = NO;
//        NSInteger resume = [interuptionDict[AVAudioSessionInterruptionOptionKey] integerValue];
//        if (resume == AVAudioSessionInterruptionOptionShouldResume) {
//            [self play];
//        }
//    }
//}

- (void)routeChange:(NSNotification *)notification {
    NSDictionary *routeChangeDict = notification.userInfo;
    NSInteger routeChangeType = [routeChangeDict[AVAudioSessionRouteChangeReasonKey] integerValue];
    
    if (routeChangeType == AVAudioSessionRouteChangeReasonOldDeviceUnavailable && [self videoDesireToPlay]) {
        self.routeChangedWhilePlaying = YES;
        [self pause];
    } else if (routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable && self.isRouteChangedWhilePlaying) {
        self.routeChangedWhilePlaying = NO;
        [self play];
    }
}

#pragma mark - Public Methods
- (void)play {
    self.nativePlayer.rate = self.playbackSpeed;
    self.interruptedWhilePlaying = NO;
    self.routeChangedWhilePlaying = NO;
}

- (void)pause {
    [self.nativePlayer pause];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(NSTimeInterval realTime, BOOL finished))completionHandler {
    
    __weak typeof(self)weakSelf = self;
    [self.nativePlayer seekToTime:time completionHandler:^(BOOL finished) {
        NSTimeInterval realTime = CMTimeGetSeconds(weakSelf.nativePlayer.currentItem.currentTime);
        completionHandler(realTime, finished);
    }];
}

- (BOOL)hasEnoughBuffer {
    return self.nativePlayer.currentItem.isPlaybackLikelyToKeepUp;
}

- (void)setPlaybackSpeed:(CGFloat)playbackSpeed {
    _playbackSpeed = playbackSpeed;
    if ([self videoDesireToPlay]) {
        [self play];
    }
}

#pragma mark - NativePlayer Buffering
- (void)nativeStartBuffering {
    if ([self.delegate respondsToSelector:@selector(rtcReplayStartBuffering)]) {
        [self.delegate rtcReplayStartBuffering];
    }
}

- (void)nativeEndBuffering {
    if ([self.delegate respondsToSelector:@selector(rtcReplayEndBuffering)]) {
        [self.delegate rtcReplayEndBuffering];
    }
}

#pragma mark - Private Methods
/**
 并非真正播放，包含缓冲可能性

 @return video 是否处于想要播放的状态
 */
- (BOOL)videoDesireToPlay {
    return self.nativePlayer.rate != 0;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {

    if (object != self.nativePlayer.currentItem && object != self.nativePlayer) {
        return;
    }
    
    if (object == self.nativePlayer && [keyPath isEqualToString:kCurrentItemKey]) {
        // 防止主动替换 CurrentItem，理论上单个Video 不会进行替换
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        AVPlayerItem *lastPlayerItem = [change objectForKey:NSKeyValueChangeOldKey];
        if (lastPlayerItem != (id)[NSNull null]) {
            @try {
                [self removeObserverWithPlayItem:lastPlayerItem];
            } @catch(id anException) {
                //do nothing, obviously it wasn't attached because an exception was thrown
            }
        }
        if (newPlayerItem != (id)[NSNull null]) {
            [self addObserverWithPlayItem:newPlayerItem];
        }

    } else if ([keyPath isEqualToString:kRateKey]) {
        if ([self.delegate respondsToSelector:@selector(rtcReplayStateChange:)]) {
            [self.delegate rtcReplayStateChange:[self videoDesireToPlay]];
        }
    } else if ([keyPath isEqualToString:kStatusKey]) {
        
        if (self.nativePlayer.status == AVPlayerStatusFailed) {
            [self pause];
            if ([self.delegate respondsToSelector:@selector(rtcReplayError:)]) {
                [self.delegate rtcReplayError:self.nativePlayer.error];
            }
        }
    } else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUpKey]) {
        AgoraLogInfo(@"isPlaybackLikelyToKeepUp %d", self.nativePlayer.currentItem.isPlaybackLikelyToKeepUp);
        if (self.nativePlayer.currentItem.isPlaybackLikelyToKeepUp) {
            [self nativeEndBuffering];
        }
    } else if ([keyPath isEqualToString:kPlaybackBufferFullKey]) {
        AgoraLogInfo(@"isPlaybackBufferFull %d", self.nativePlayer.currentItem.isPlaybackBufferFull);
        if (self.nativePlayer.currentItem.isPlaybackBufferFull) {
            [self nativeEndBuffering];
        }
    } else if ([keyPath isEqualToString:kPlaybackBufferEmptyKey]) {
        AgoraLogInfo(@"isPlaybackBufferEmpty %d", self.nativePlayer.currentItem.isPlaybackBufferEmpty);
        if (self.nativePlayer.currentItem.isPlaybackBufferEmpty) {
            [self nativeStartBuffering];
        }
    } else if ([keyPath isEqualToString:kLoadedTimeRangesKey]) {
        NSArray *timeRanges = (NSArray *)change[NSKeyValueChangeNewKey];
        if ([self.delegate respondsToSelector:@selector(rtcReplayLoadedTimeRangeChange:)]) {
            [self.delegate rtcReplayLoadedTimeRangeChange:timeRanges];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserverWithPlayItem:self.nativePlayer.currentItem];
    [self removeNativePlayerKVO];
}

- (void)removeNativePlayerKVO {
    [self.nativePlayer removeObserver:self forKeyPath:kRateKey];
    [self.nativePlayer removeObserver:self forKeyPath:kCurrentItemKey];
}
@end
