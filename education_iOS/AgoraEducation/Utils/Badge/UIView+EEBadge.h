//
//  UIView+EEBadge.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/6.
//  Copyright © 2019 Agora. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (EEBadge)
@property (nonatomic, strong) UILabel *badge;
- (void)showBadgeWithTopMagin:(CGFloat)magin;
- (void)hidenBadge;
- (void)setBadgeCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
