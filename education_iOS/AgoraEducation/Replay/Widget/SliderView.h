//
//  SliderView.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SliderViewDelegate <NSObject>

@optional
- (void)sliderTouchBegan:(float)value;
- (void)sliderValueChanged:(float)value;
- (void)sliderTouchEnded:(float)value;
- (void)sliderTapped:(float)value;

@end

@interface SliderButton : UIButton

@end

NS_ASSUME_NONNULL_BEGIN

@interface SliderView : UIView

@property (nonatomic, weak) id<SliderViewDelegate> delegate;

/** slider */
@property (nonatomic, strong, readonly) SliderButton *sliderBtn;

/** default slider color */
@property (nonatomic, strong) UIColor *maximumTrackTintColor;

/** slider track color */
@property (nonatomic, strong) UIColor *minimumTrackTintColor;

/** buffer track color */
@property (nonatomic, strong) UIColor *bufferTrackTintColor;

/** loading color */
@property (nonatomic, strong) UIColor *loadingTintColor;

/** default track image */
@property (nonatomic, strong) UIImage *maximumTrackImage;

/** track progress image */
@property (nonatomic, strong) UIImage *minimumTrackImage;

/** buffer track image */
@property (nonatomic, strong) UIImage *bufferTrackImage;

/** progress */
@property (nonatomic, assign) float value;

/** buffer progress */
@property (nonatomic, assign) float bufferValue;

/** allow tapped，default: YES */
@property (nonatomic, assign) BOOL allowTapped;

/** allow animate，default: YES */
@property (nonatomic, assign) BOOL animate;

/** slider height */
@property (nonatomic, assign) CGFloat sliderHeight;

/** hide slider（default: NO） */
@property (nonatomic, assign) BOOL isHideSliderBlock;

@property (nonatomic, assign) BOOL isdragging;

/// dragging forward or back
@property (nonatomic, assign) BOOL isForward;

@property (nonatomic, assign) CGSize thumbSize;

/**
 *  Starts animation of the spinner.
 */
- (void)startAnimating;

/**
 *  Stops animation of the spinnner.
 */
- (void)stopAnimating;

// set slider background image
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;

// set slider image
- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
