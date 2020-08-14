//
//  UIView+EEBadge.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/6.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "UIView+EEBadge.h"


static char badgeViewKey;

// The width and height of the small red dot
static NSInteger const pointWidth = 18;

// Distance to the right of the control
static NSInteger const rightRange = 0;

@implementation UIView (EEBadge)
- (void)showBadgeWithTopMagin:(CGFloat)magin
{
    if (self.badge == nil) {
        CGRect frame = CGRectMake(CGRectGetWidth(self.frame) + rightRange, magin, pointWidth, 12);
        self.badge = [[UILabel alloc] initWithFrame:frame];
        self.badge.backgroundColor = [UIColor colorWithHexString:@"FF3B30"];
        self.badge.layer.cornerRadius = 7;
        [self.badge setTextAlignment:NSTextAlignmentCenter];
        self.badge.layer.masksToBounds = YES;
        [self addSubview:self.badge];
        [self bringSubviewToFront:self.badge];
    }
}

- (void)setBadgeCount:(NSInteger)count {
    self.badge.hidden = NO;
    [self.badge setText:[NSString stringWithFormat:@"%zi",count]];
    [self.badge setTextColor:[UIColor colorWithHexString:@"FFFFFF"]];
    [self.badge setFont:[UIFont fontWithName:@"Helvetica Neue" size:10.f]];
    [self.badge setFont:[UIFont systemFontOfSize:12 weight:(UIFontWeightMedium)]];
    self.badge.adjustsFontSizeToFitWidth = YES;
}

- (void)hidenBadge
{
    self.badge.hidden = YES;
}

#pragma mark - GetterAndSetter

- (UILabel *)badge
{
    return objc_getAssociatedObject(self, &badgeViewKey);
}

- (void)setBadge:(UILabel *)badge
{
    objc_setAssociatedObject(self, &badgeViewKey, badge, OBJC_ASSOCIATION_RETAIN);
}
@end
