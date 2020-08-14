//
//  ReplayNoVideoViewController.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/10.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "ReplayViewController.h"
#import <AVKit/AVKit.h>

#import "CombineReplayManager.h"

#import "ReplayControlView.h"
#import "HttpManager.h"
#import "EduButton.h"
#import "LoadingView.h"

#import "UIView+Toast.h"
#import "ReplayModel.h"
#import "EduConfigModel.h"

typedef NS_ENUM(NSInteger, RecordState) {
    RecordStateRecording = 1,
    RecordStateFinished = 2,
    RecordStateWaitDownload = 3,
    RecordStateWaitConvert = 4,
    RecordStateWaitUpload = 5,
};

@interface ReplayViewController ()<ReplayControlViewDelegate, CombineReplayDelegate>

@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (weak, nonatomic) IBOutlet ReplayControlView *controlView;
@property (weak, nonatomic) IBOutlet EduButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *playBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet LoadingView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *teacherView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultTeacherImage;

@property (nonatomic, strong) CombineReplayManager *combineReplayManager;
@property (nonatomic, weak) WhiteBoardView *boardView;
@property (nonatomic, weak) WhiteVideoView *videoView;

@property (nonatomic, assign) BOOL playFinished;

// can seek when has buffer only for m3u8 video
@property (nonatomic, assign) BOOL canSeek;

@property (strong, nonatomic) NSString *recordId;

@property (strong, nonatomic) NSString *boardId;
@property (strong, nonatomic) NSString *boardToken;

@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;

@property (nonatomic, strong) ReplayInfoModel *replayInfoModel;

@end

@implementation ReplayViewController

+ (void)enterReplayViewController:(NSString *)recordId {

      [HttpManager getReplayInfoWithUserToken:EduConfigModel.shareInstance.userToken appId:EduConfigModel.shareInstance.appId roomId:EduConfigModel.shareInstance.roomId recordId:recordId success:^(id responseObj) {

          ReplayModel *model = [ReplayModel yy_modelWithDictionary:responseObj];
          if(model.code == 0) {
              NSInteger status = model.data.status;
              if(status == RecordStateRecording
                 || status == RecordStateFinished
                 || status == RecordStateWaitDownload
                 || status == RecordStateWaitConvert
                 || status == RecordStateWaitUpload) {
                  
                  if(status != RecordStateFinished) {
                      [UIApplication.sharedApplication.keyWindow makeToast:NSLocalizedString(@"QuaryReplayFailedText", nil)];
                      return;
                  }
              }
              
              
              ReplayViewController *vc = [[ReplayViewController alloc] initWithNibName:@"ReplayViewController" bundle:nil];
              vc.replayInfoModel = model.data;
              vc.recordId = recordId;
              vc.modalPresentationStyle = UIModalPresentationFullScreen;
              UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
              UINavigationController *nvc = (UINavigationController*)window.rootViewController;
              if(nvc != nil){
                  [nvc.visibleViewController presentViewController:vc animated:YES completion:nil];
              }

          } else {
              NSString *msg = [EduConfigModel generateHttpErrorMessageWithDescribe:@"RequestReplayFailedText" errorCode:model.code];
              [UIApplication.sharedApplication.keyWindow makeToast:msg];
    
          }
      } failure:^(NSError *error) {
          [UIApplication.sharedApplication.keyWindow makeToast:error.description];
      }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self initData];
}

- (void)initData {
    
    self.canSeek = NO;
    self.controlView.delegate = self;
    
    self.playFinished = NO;
    
    self.combineReplayManager = [CombineReplayManager new];
    self.combineReplayManager.delegate = self;
    
    self.boardId = EduConfigModel.shareInstance.boardId;
    self.boardToken = EduConfigModel.shareInstance.boardToken;

    self.startTime = self.replayInfoModel.startTime;
    self.endTime = self.replayInfoModel.endTime;

    for(RecordDetailsModel *detailModel in self.replayInfoModel.recordDetails) {
      // teacher
      if(detailModel.role == 1) {
          self.videoPath = detailModel.url;
          break;
      }
    }
    NSAssert(self.videoPath != nil, @"can't find record video");
    [self setupRTCReplay];
    [self setupWhiteReplay];
}

- (void)setupRTCReplay {
    
    AVPlayer *player = [self.combineReplayManager setupRTCReplayWithURL:[NSURL URLWithString:self.videoPath]];
    AVPlayerLayer *avplayerLayer = (AVPlayerLayer *)self.videoView.layer;
    dispatch_async(dispatch_get_main_queue(), ^{
        [avplayerLayer setPlayer:player];
        [avplayerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    });
}

- (void)setupWhiteReplay {
    
    ReplayManagerModel *replayManagerModel = [ReplayManagerModel new];
    replayManagerModel.uuid = self.boardId;
    replayManagerModel.uutoken = self.boardToken;
    replayManagerModel.videoPath = self.videoPath;
    replayManagerModel.startTime = @(self.startTime).stringValue;
    replayManagerModel.endTime = @(self.endTime).stringValue;
    replayManagerModel.boardView = self.boardView;
    
    WEAK(self);
    [self.combineReplayManager setupWhiteReplayWithValue:replayManagerModel completeSuccessBlock:^{
        
        [weakself seekToTimeInterval:0 completionHandler:^(BOOL finished) {
        }];
        
    } completeFailBlock:^(NSError * _Nullable error) {
        [weakself.view makeToast:error.description];
    }];
}

- (void)setupView {
    
    WhiteVideoView *videoView = [[WhiteVideoView alloc] initWithFrame:self.teacherView.bounds];
    videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.teacherView addSubview:videoView];
    self.videoView = videoView;
    
    WhiteBoardView *boardView = [[WhiteBoardView alloc] init];
    boardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.whiteboardBaseView insertSubview:boardView belowSubview:self.playBackgroundView];
    self.boardView = boardView;
    NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.whiteboardBaseView addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];
    
    self.backButton.layer.cornerRadius = 6;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)dealloc {
    [self.combineReplayManager releaseResource];
    self.combineReplayManager = nil;
}

#pragma mark Click Event
- (IBAction)onWhiteBoardClick:(id)sender {
    self.controlView.hidden = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
}

- (IBAction)onPlayClick:(id)sender {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
    
    [self setPlayViewsVisible:YES];
    
    WEAK(self);
    if(self.playFinished) {
        self.playFinished = NO;
        [self seekToTimeInterval:0 completionHandler:^(BOOL finished) {
            [weakself.combineReplayManager play];
        }];
    } else {
        [self.combineReplayManager play];
    }
}

- (IBAction)onBackClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setLoadingViewVisible:(BOOL)onPlay {
    onPlay ? [self.loadingView showLoading] : [self.loadingView hiddenLoading];
    onPlay ? (self.playBackgroundView.hidden = NO) : (self.playBackgroundView.hidden = YES);
}

- (void)setPlayViewsVisible:(BOOL)onPlay {
    self.playBackgroundView.hidden = onPlay;
    self.playButton.hidden = onPlay;
    self.controlView.playOrPauseBtn.selected = onPlay;
}

- (void)hideControlView {
    self.controlView.hidden = YES;
}

- (void)seekToTimeInterval:(NSTimeInterval)seconds completionHandler:(void (^)(BOOL finished))completionHandler {
    CMTime cmTime = CMTimeMakeWithSeconds(seconds, 100);
    [self.combineReplayManager seekToTime:cmTime completionHandler:completionHandler];
}

- (NSTimeInterval)timeTotleDuration {
    return (NSInteger)(self.endTime - self.startTime) * 0.001;
}

#pragma mark ReplayControlViewDelegate
- (void)sliderTouchBegan:(float)value {
    if(!self.canSeek) {
        return;
    }
    self.controlView.sliderView.isdragging = YES;
}

- (void)sliderValueChanged:(float)value {
    if(!self.canSeek) {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    if ([self timeTotleDuration] > 0) {
        Float64 seconds = [self timeTotleDuration] * value;
        [self seekToTimeInterval:seconds completionHandler:^(BOOL finished) {
        }];
    }
}

- (void)sliderTouchEnded:(float)value {
    if(!self.canSeek) {
        self.controlView.sliderView.isdragging = NO;
        return;
    }
    
    if ([self timeTotleDuration] == 0) {
        self.controlView.sliderView.value = 0;
        return;
    }
    self.controlView.sliderView.value = value;
    float currentTime = [self timeTotleDuration] * value;
    
    WEAK(self);
    [self seekToTimeInterval:currentTime completionHandler:^(BOOL finished) {
        NSString *currentTimeStr = [weakself convertTimeSecond: currentTime];
        NSString *totleTimeStr = [weakself convertTimeSecond: [weakself timeTotleDuration]];
        NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
        weakself.controlView.timeLabel.text = timeStr;

        weakself.controlView.sliderView.isdragging = NO;
    }];
}

- (NSString *)convertTimeSecond:(NSInteger)timeSecond {
    NSString *theLastTime = nil;
    long second = timeSecond;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%02zd", second];
    } else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd", second/60, second%60];
    } else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", second/3600, second%3600/60, second%60];
    }
    return theLastTime;
}

- (void)sliderTapped:(float)value {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    self.controlView.sliderView.isdragging = YES;
    
    if([self timeTotleDuration] > 0) {
        NSInteger currentTime = [self timeTotleDuration] * value;
        WEAK(self);
        [self seekToTimeInterval:currentTime completionHandler:^(BOOL finished) {
            NSString *currentTimeStr = [weakself convertTimeSecond: currentTime];
            NSString *totleTimeStr = [weakself convertTimeSecond: [weakself timeTotleDuration]];
            NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
            weakself.controlView.timeLabel.text = timeStr;
            
            weakself.controlView.sliderView.isdragging = NO;
        }];
    } else {
        
        self.controlView.sliderView.value = 0;
        self.controlView.sliderView.isdragging = NO;
    }
}

- (void)playPauseButtonClicked:(BOOL)play {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    [self setPlayViewsVisible:play];
    
    if(play) {
        [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
        
        WEAK(self);
        if(self.playFinished) {
            self.playFinished = NO;
            [self seekToTimeInterval:0 completionHandler:^(BOOL finished) {
                [weakself.combineReplayManager play];
            }];
        } else {
            [self.combineReplayManager play];
        }
        
    } else {
        [self.combineReplayManager pause];
    }
}

#pragma mark CombineReplayDelegate
- (void)combinePlayTimeChanged:(NSTimeInterval)time {
    if(self.controlView.sliderView.isdragging){
        return;
    }
    
    if([self timeTotleDuration] > 0){
        float value = time / [self timeTotleDuration];
        self.controlView.sliderView.value = value;
        NSString *totleTimeStr = [self convertTimeSecond: [self timeTotleDuration]];
        NSString *currentTimeStr = [self convertTimeSecond: time];
        NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
        self.controlView.timeLabel.text = timeStr;
    }
}
- (void)combinePlayStartBuffering {
    if(self.playButton.hidden){
        [self setLoadingViewVisible:YES];
    }
}
- (void)combinePlayEndBuffering {
    if(self.playButton.hidden){
        [self setLoadingViewVisible:NO];
    }
    self.canSeek = YES;
}
- (void)combinePlayDidFinish {
    [self.combineReplayManager pause];

    [self setLoadingViewVisible:NO];
    [self setPlayViewsVisible:NO];
    
    self.playFinished = YES;
    self.controlView.hidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
}
- (void)combinePlayPause {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    self.controlView.hidden = NO;
    [self setPlayViewsVisible:NO];
}
- (void)combinePlayError:(NSError * _Nullable)error {
    AgoraLogError(@"ReplayVideoViewController Stopped Err:%@", error);
}

@end
