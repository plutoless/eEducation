//
//  SkinCoverWindow.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/9/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "SkinCoverWindow.h"
#import "SkinCoverLayer.h"

@implementation SkinCoverWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (self = [super initWithFrame:frame]) {
            [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
            SkinCoverLayer *skinCoverLayer = [SkinCoverLayer layer];
            skinCoverLayer.frame = CGRectMake(0, 0, MIN(frame.size.height, frame.size.width), MAX(frame.size.height, frame.size.width));
            skinCoverLayer.backgroundColor = [UIColor colorWithHexString:@"FF9900" alpha:0.1].CGColor;
            [self.layer addSublayer:skinCoverLayer];
        }
    }
    return self;
}



@end
