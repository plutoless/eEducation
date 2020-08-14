//
//  EESegmentedView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/22.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BCSegmentedDelegate <NSObject>
- (void)selectedItemIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_BEGIN

@interface BCSegmentedView : UIView
@property (nonatomic, weak) id<BCSegmentedDelegate> delegate;
- (void)showBadgeWithCount:(NSInteger)count;
- (void)hiddeBadge;
@end

NS_ASSUME_NONNULL_END
