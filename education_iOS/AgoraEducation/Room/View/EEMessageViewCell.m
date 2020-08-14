//
//  EEMessageViewCell.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EEMessageViewCell.h"

@interface EEMessageViewCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftViewWidthCon;
@property (weak, nonatomic) IBOutlet UILabel *leftContentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewWidthCon;
@property (weak, nonatomic) IBOutlet UILabel *rightContentLabel;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation EEMessageViewCell
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.leftView.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    self.leftView.layer.borderWidth = 1.f;
    self.leftView.layer.masksToBounds = YES;
    self.leftView.layer.cornerRadius = 4.f;

    self.rightView.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    self.rightView.layer.borderWidth = 1.f;
    self.rightView.layer.masksToBounds = YES;
    self.rightView.layer.cornerRadius = 4.f;
    self.rightView.backgroundColor = [UIColor colorWithHexString:@"E7F6FF"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setMessageModel:(MessageInfoModel *)messageModel {
    _messageModel = messageModel;

    NSMutableAttributedString *contentString;

    if(messageModel.recordId != nil && messageModel.recordId.length > 0) {
        contentString = [[NSMutableAttributedString alloc] initWithString:messageModel.message attributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
       
    } else {
        contentString = [[NSMutableAttributedString alloc] initWithString:messageModel.message];
    }

    if (messageModel.isSelfSend) {
        CGSize size =  [self sizeWithContent:messageModel.message];
        self.rightViewWidthCon.constant = (size.width + 25) > self.cellWidth ? self.cellWidth : size.width + 25;
        [self.rightContentLabel setAttributedText:contentString];
        self.rightView.hidden = NO;
        self.rightContentLabel.hidden = NO;
        self.leftView.hidden = YES;
        self.leftContentLabel.hidden = YES;
        self.nameLabel.textAlignment = NSTextAlignmentRight;
    } else {
        CGSize size =  [self sizeWithContent: messageModel.message];
        self.leftViewWidthCon.constant = size.width + 25 > self.cellWidth ? self.cellWidth : size.width +25;
        [self.leftContentLabel setAttributedText:contentString];
        self.rightView.hidden = YES;
        self.rightContentLabel.hidden = YES;
        self.leftView.hidden = NO;
        self.leftContentLabel.hidden = NO;
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    [self.nameLabel setText:messageModel.userName];
}

- (CGSize)sizeWithContent:(NSString *)string {
    CGSize labelSize = [string boundingRectWithSize:CGSizeMake(self.cellWidth - 38, 1000) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.f]} context:nil].size;
    return labelSize;
}
@end
