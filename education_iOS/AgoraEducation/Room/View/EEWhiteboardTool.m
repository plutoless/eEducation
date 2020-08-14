//
//  EEWhiteboardTool.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EEWhiteboardTool.h"

@implementation EEWhiteboardTool

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.whiteboardTool];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.whiteboardTool.frame = self.bounds;

    self.bgView.layer.cornerRadius = 8;
    self.bgView.layer.masksToBounds = YES;
    
    for(NSInteger i = 200; i < 205; i++){
        UIView *v = [self viewWithTag:i];
        [self setButtonCornerRadius:v];
    }
}

-(void)setButtonCornerRadius:(UIView *)view {
    if(view == nil){
        return;
    }
    view.layer.cornerRadius = 4;
    view.layer.masksToBounds = YES;
}

- (IBAction)clickEvent:(UIButton *)sender {
    
    if(self.selectButton != nil){
        self.selectButton.backgroundColor = [UIColor colorWithHex:0x565656];
    }
    if(sender.tag == 204 && self.selectButton.tag == 204){
        self.selectButton = nil;
    } else {
        sender.backgroundColor = [UIColor colorWithHex:0x141414];
        self.selectButton = sender;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectWhiteboardToolIndex:)]) {
        [self.delegate selectWhiteboardToolIndex:sender.tag - 200];
    }
}

@end
