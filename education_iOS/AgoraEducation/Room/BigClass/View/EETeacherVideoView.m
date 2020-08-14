//
//  EERemoteVideoView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EETeacherVideoView.h"

@interface EETeacherVideoView ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIView *teacherVideoView;
@property (weak, nonatomic) IBOutlet UIImageView *speakerImage;
@end

@implementation EETeacherVideoView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    [self addSubview:self.teacherVideoView];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.teacherVideoView.frame = self.bounds;
}

- (void)updateAndsetTeacherName:(NSString * _Nullable)name {
    [self.nameLabel setText:name];
}

- (void)updateSpeakerImageWithMuted:(BOOL)muted {
    NSString *imageName = muted ? @"icon-speakeroff-dark" : @"icon-speaker3-max";
    [self.speakerImage setImage:[UIImage imageNamed:imageName]];
}
@end
