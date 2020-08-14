//
//  OTOStudentView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/13.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "OTOStudentView.h"

@interface OTOStudentView ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIView *studentView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *micButton;

@end


@implementation OTOStudentView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.studentView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.studentView.frame = self.bounds;
}

- (IBAction)muteMic:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self updateAudioImageWithMuted:sender.selected];
    if (self.delegate && [self.delegate respondsToSelector:@selector(muteAudioStream:)]) {
        [self.delegate muteAudioStream:sender.selected];
    }
}

- (IBAction)muteVideo:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self updateVideoImageWithMuted:sender.selected];
    if (self.delegate && [self.delegate respondsToSelector:@selector(muteVideoStream:)]) {
         [self.delegate muteVideoStream:sender.selected];
     }
}

- (void)updateUserName:(NSString *)name {
    [self.nameLabel setText:name];
}

- (void)updateVideoImageWithMuted:(BOOL)mute {
    self.defaultImageView.hidden = mute ? NO : YES;
    
    self.cameraButton.selected = mute;
    NSString *imageName = mute ? @"icon-video-off-min" : @"icon-video-on-min";
    [self.cameraButton setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
}

- (void)updateAudioImageWithMuted:(BOOL)mute {
    self.micButton.selected = mute;
    NSString *imageName = mute ? @"icon-speaker-off-min" : @"icon-speaker3-min";
    [self.micButton setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
}

@end
