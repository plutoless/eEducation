//
//  EEStudentVideoView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BCStudentVideoView.h"

@interface BCStudentVideoView ()
@property (strong, nonatomic) IBOutlet UIView *studentVideoView;
@property (weak, nonatomic) IBOutlet UIButton *videoMuteButton;
@property (weak, nonatomic) IBOutlet UIButton *audioMuteButton;

@end

@implementation BCStudentVideoView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.studentVideoView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.studentVideoView.frame = self.bounds;

}

- (IBAction)muteAudio:(UIButton *)sender {
    
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

- (void)updateVideoImageWithMuted:(BOOL)muted {
    NSString *imageName = muted ? @"icon-video-off-min" : @"icon-video-on-min";
    self.defaultImageView.hidden = !muted;
    [self.videoMuteButton setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
}

- (void)updateAudioImageWithMuted:(BOOL)muted {
    NSString *imageName = muted ? @"icon-speakeroff-dark" : @"icon-speaker3";
    [self.audioMuteButton setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
}

- (void)setButtonEnabled:(BOOL)enabled {
    [self.videoMuteButton setEnabled:enabled];
    [self.audioMuteButton setEnabled:enabled];
}
@end
