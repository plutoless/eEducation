//
//  SettingUploadViewCell.m
//  AgoraEducation
//
//  Created by SRS on 2020/3/30.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "SettingUploadViewCell.h"
#import "LogManager.h"
#import "UIView+Toast.h"
#import "AlertViewUtil.h"

@interface SettingUploadViewCell ()
@property (nonatomic, assign) BOOL isUploading;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UIActivityIndicatorView *loadingView;
@end

@implementation SettingUploadViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpView];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    
    self.isUploading = NO;
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.frame = CGRectMake(15, 16, 150, 24);
    contentLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:contentLabel];
    self.contentLabel = contentLabel;
    contentLabel.text = NSLocalizedString(@"UploadLogText", nil);

    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] init];
    loadingView.frame = CGRectMake(kScreenWidth - 65, 13, 30, 30);
    loadingView.hidden = YES;
    [self addSubview:loadingView];
    self.loadingView = loadingView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)uploadLog {
    if(self.isUploading) {
        return;
    }
    
    self.isUploading = YES;
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
    
    WEAK(self);
    [LogManager uploadLogWithCompleteSuccessBlock:^(NSString * _Nonnull uploadSerialNumber) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.loadingView.hidden = YES;
            [weakself.loadingView stopAnimating];
            weakself.isUploading = NO;

            UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
            UINavigationController *nvc = (UINavigationController*)window.rootViewController;
            if (nvc != nil) {
                 [AlertViewUtil showAlertWithController:nvc.visibleViewController title:NSLocalizedString(@"UploadLogSuccessText", nil) message:uploadSerialNumber cancelText:nil sureText:NSLocalizedString(@"OKText", nil) cancelHandler:nil sureHandler:nil];
            }
        });
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.loadingView.hidden = YES;
            [weakself.loadingView stopAnimating];
            weakself.isUploading = NO;
            [UIApplication.sharedApplication.keyWindow makeToast:errMessage];
        });
    }];
}

@end
