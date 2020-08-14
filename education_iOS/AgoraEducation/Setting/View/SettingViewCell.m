//
//  SettingViewCell.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/18.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "SettingViewCell.h"

@interface SettingViewCell ()
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UISwitch *switchButton;
@end


@implementation SettingViewCell

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
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.frame = CGRectMake(15, 16, 150, 24);
    contentLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:contentLabel];
    self.contentLabel = contentLabel;
    contentLabel.text = NSLocalizedString(@"EyeProtectionText", nil);

    UISwitch *switchButton = [[UISwitch alloc] init];
    switchButton.frame = CGRectMake(kScreenWidth - 65, 13, 50, 32);
    [self addSubview:switchButton];
    self.switchButton = switchButton;
    [switchButton addTarget:self action:@selector(switchClick:) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)switchClick:(UISwitch *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingSwitchCallBack:)]) {
        [self.delegate settingSwitchCallBack:sender];
    }
}

- (void)switchOn:(BOOL)on {
    [self.switchButton setOn:on animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
