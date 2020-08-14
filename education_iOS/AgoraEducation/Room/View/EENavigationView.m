//
//  OneToOneNavigationView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/12.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EENavigationView.h"
#import "LogManager.h"
#import "UIView+Toast.h"
#import "AlertViewUtil.h"

@interface EENavigationView ()
{
    dispatch_source_t timer;
}
@property (strong, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic) BOOL isStart;
@property (nonatomic) BOOL isPause;
@property (nonatomic) BOOL isCreat;
@property (nonatomic,assign) NSInteger timeCount;
@property (weak, nonatomic) IBOutlet UIImageView *wifiSignalView;
@property (weak, nonatomic) IBOutlet UIButton *uploadLogBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@end

@implementation EENavigationView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.navigationView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.navigationView.frame = self.bounds;
    self.loadingView.hidden = YES;
}

- (void)initTimerCount:(NSInteger)timeCount {
    self.timeCount = timeCount;
}

- (void)startTimer {
//    self.timeCount = 0;
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalQueue);
    _isCreat = YES;
    
     WEAK(self);
    //每秒执行一次
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        int hours = weakself.timeCount / 3600;
        int minutes = (weakself.timeCount - (3600*hours)) / 60;
        int seconds = weakself.timeCount % 60;
        NSString *strTime = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",hours,minutes,seconds];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.timeLabel.text = strTime;
        });
        self.timeCount++;
    });
    dispatch_resume(timer);
}

- (void)stopTimer {
    if (timer) {
        dispatch_source_cancel(timer);
    }
}

- (void)updateClassName:(NSString *)name {
    [self.roomNameLabel setText:name];
}

- (void)updateSignalImageName:(NSString *)name {
    [self.wifiSignalView setImage:[UIImage imageNamed:name]];
}

- (IBAction)closeRoom:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeRoom)]) {
        [self.delegate closeRoom];
    }
}
- (IBAction)onUploadLog:(id)sender {
    self.uploadLogBtn.hidden = YES;
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
    
    WEAK(self);
    [LogManager uploadLogWithCompleteSuccessBlock:^(NSString * _Nonnull uploadSerialNumber) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.uploadLogBtn.hidden = NO;
            weakself.loadingView.hidden = YES;
            [weakself.loadingView stopAnimating];

            UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
            UINavigationController *nvc = (UINavigationController*)window.rootViewController;
            if (nvc != nil) {
                 [AlertViewUtil showAlertWithController:nvc.visibleViewController title:NSLocalizedString(@"UploadLogSuccessText", nil) message:uploadSerialNumber cancelText:nil sureText:NSLocalizedString(@"OKText", nil) cancelHandler:nil sureHandler:nil];
            }
        });
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.uploadLogBtn.hidden = NO;
            weakself.loadingView.hidden = YES;
            [weakself.loadingView stopAnimating];
            [UIApplication.sharedApplication.keyWindow makeToast:errMessage];
            
        });
    }];
}

- (void)dealloc
{
   if (timer) {
        dispatch_source_cancel(timer);
    }
}

@end
