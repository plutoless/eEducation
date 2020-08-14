//
//  StudentVideoViewCell.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/8/13.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MCStudentVideoCell.h"

@interface MCStudentVideoCell ()
@property (nonatomic, weak) UIImageView *backImageView;
@property (nonatomic, weak) UILabel *nameLable;
@property (nonatomic, weak) UIImageView *volumeImageView;
@end

@implementation MCStudentVideoCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUserModel:(UserModel *)userModel {
    _userModel = userModel;
    self.nameLable.text = userModel.userName;
    self.backImageView.hidden = userModel.enableVideo ? YES : NO;
    NSString *audioImageName = userModel.enableAudio ? @"icon-speaker3-min" : @"icon-speaker-off-min";
    [self.volumeImageView setImage:[UIImage imageNamed:audioImageName]];
}

- (void)setUpView {
    UIView *videoCanvasView = [[UIView alloc] init];
    videoCanvasView.frame = self.contentView.bounds;
    [self.contentView addSubview:videoCanvasView];
    self.videoCanvasView = videoCanvasView;

    UIImageView *backImageView = [[UIImageView alloc] init];
    backImageView.frame = self.contentView.bounds;
    [self.contentView addSubview:backImageView];
    backImageView.image = [UIImage imageNamed:@"icon-student"];
    backImageView.contentMode = UIViewContentModeScaleAspectFit;
    backImageView.backgroundColor = [UIColor colorWithHexString:@"DBE2E5"];
    self.backImageView = backImageView;

    UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 95, 20)];
    if(IsPad){
        labelView.frame = CGRectMake(0, 88, 146, 20);
    }
    
    labelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self.contentView addSubview:labelView];
    
    UILabel *nameLable = [self addNameLabel];
    [self.contentView addSubview:nameLable];
    [self bringSubviewToFront:nameLable];
    self.nameLable = nameLable;

    UIImageView *volumeImageView = [[UIImageView alloc] init];
    volumeImageView.frame = CGRectMake(75, 50, 20, 20);
    if(IsPad){
        volumeImageView.frame = CGRectMake(126, 88, 20, 20);
    }
    
    [self.contentView addSubview:volumeImageView];
    [volumeImageView setImage:[UIImage imageNamed:@"icon-speaker3-min"]];
    self.volumeImageView = volumeImageView;
}

- (UILabel *)addNameLabel {
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(5, 50, 65, 20);
    if(IsPad){
        nameLabel.frame = CGRectMake(5, 88, 145, 20);
    }
    
    nameLabel.backgroundColor = UIColor.clearColor;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:10.f];
    nameLabel.layer.cornerRadius = 2;
    return nameLabel;
}
@end
