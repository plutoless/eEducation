//
//  MCStudentViewCell.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MCStudentViewCell.h"


@interface MCStudentViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *micButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@end

@implementation MCStudentViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization cod
    self.muteVideoButton.selected = YES;
    self.muteAudioButton.selected = YES;
    self.muteWhiteButton.selected = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)muteAction:(UIButton *)sender {
    
}

- (void)setStudentModel:(UserModel *)studentModel {
    _studentModel = studentModel;
    [self.nameLabel setText:studentModel.userName];
    NSString *audioImageName = studentModel.enableAudio ? @"icon-speaker3-max" : @"icon-speakeroff-dark";
    [self.muteAudioButton setImage:[UIImage imageNamed:audioImageName] forState:(UIControlStateNormal)];
    self.muteAudioButton.selected = studentModel.enableAudio ? YES : NO;

    NSString *videoImageName = studentModel.enableVideo ? @"roomCameraOn" : @"roomCameraOff";
    [self.muteVideoButton setImage:[UIImage imageNamed:videoImageName] forState:(UIControlStateNormal)];

    self.muteVideoButton.selected = studentModel.enableVideo ? YES : NO;
    
    self.muteVideoButton.hidden = studentModel.uid != self.uid ? YES : NO;
    self.muteAudioButton.hidden = studentModel.uid != self.uid ? YES : NO;
    
    self.muteWhiteButton.selected = studentModel.grantBoard ? YES : NO;
    self.muteWhiteButton.hidden = studentModel.uid != self.uid ? YES : NO;
}

@end
