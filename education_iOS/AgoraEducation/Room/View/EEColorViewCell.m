//
//  EEColorViewCell.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/1.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EEColorViewCell.h"

@implementation EEColorViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *outColorView = [[UIView alloc] init];
        outColorView.frame = CGRectMake(0, 0, 26, 26);
        [self addSubview:outColorView];
        outColorView.backgroundColor = [UIColor colorWithHexString:@"DEEFFF"];
        outColorView.layer.borderWidth = 1.f;
        outColorView.layer.borderColor = [UIColor colorWithHexString:@"44A2FC"].CGColor;
        outColorView.layer.cornerRadius = 13.f;
        outColorView.layer.masksToBounds = YES;
        self.outColorView = outColorView;
        
        UIView *colorView = [[UIView alloc] init];
        colorView.frame = CGRectMake(3, 3, 20, 20);
        [self addSubview:colorView];
        colorView.layer.cornerRadius = 10.f;
        colorView.layer.masksToBounds = YES;
        self.colorView = colorView;

    }
    return self;
}

@end
