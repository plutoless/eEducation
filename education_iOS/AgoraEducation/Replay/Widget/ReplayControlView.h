//
//  ReplayControlView.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderView.h"

@protocol ReplayControlViewDelegate <NSObject>

@optional
// 滑块滑动开始
- (void)sliderTouchBegan:(float)value;
// 滑块滑动中
- (void)sliderValueChanged:(float)value;
// 滑块滑动结束
- (void)sliderTouchEnded:(float)value;
// 滑杆点击
- (void)sliderTapped:(float)value;
// 播放暂停按钮点击
- (void)playPauseButtonClicked:(BOOL)play;
@end


NS_ASSUME_NONNULL_BEGIN

@interface ReplayControlView : UIView

@property (nonatomic, weak) id<ReplayControlViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;
@property (weak, nonatomic) IBOutlet SliderView *sliderView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

NS_ASSUME_NONNULL_END
