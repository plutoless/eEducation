//
//  SliderView.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "SliderView.h"

/** slider button size */
static const CGFloat kSliderBtnWH = 19.0;
/** progress height */
static const CGFloat kProgressH = 1.0;
/** draging slider animate time*/
static const CGFloat kAnimate = 0.3;

@implementation SliderButton

// expand click range
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -20, -20);
    return CGRectContainsPoint(bounds, point);
}

@end

@interface SliderView ()

@property (nonatomic, strong) UIImageView *bgProgressView;

@property (nonatomic, strong) UIImageView *bufferProgressView;

@property (nonatomic, strong) UIImageView *sliderProgressView;

@property (nonatomic, strong) SliderButton *sliderBtn;

@property (nonatomic, strong) UIView *loadingBarView;

@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation SliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.allowTapped = YES;
        self.animate = YES;
        [self addSubViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.allowTapped = YES;
    self.animate = YES;
    [self addSubViews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.bounds.size.width;
    CGFloat min_view_h = self.bounds.size.height;
    
    min_x = 0;
    min_w = min_view_w;
    min_y = 0;
    min_h = self.sliderHeight;
    self.bgProgressView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = 0;
    min_w = self.thumbSize.width;
    min_h = self.thumbSize.height;
    self.sliderBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    CGPoint sliderCenter = self.sliderBtn.center;
    sliderCenter.x = CGRectGetWidth(self.bgProgressView.bounds) * self.value;
    self.sliderBtn.center = sliderCenter;
    
    min_x = 0;
    min_y = 0;
    if (self.sliderBtn.hidden) {
        min_w = CGRectGetWidth(self.bgProgressView.bounds) * self.value;
    } else {
        min_w = self.sliderBtn.center.x;
    }
    min_h = self.sliderHeight;
    self.sliderProgressView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = 0;
    min_w = CGRectGetWidth(self.bgProgressView.bounds) * self.bufferValue;
    min_h = self.sliderHeight;
    self.bufferProgressView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_w = 0.1;
    min_h = self.sliderHeight;
    min_x = (min_view_w - min_w)/2;
    min_y = (min_view_h - min_h)/2;
    self.loadingBarView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    CGPoint bgProgressCenter = self.bgProgressView.center;
    bgProgressCenter.y = min_view_h * 0.5;
    self.bgProgressView.center = bgProgressCenter;
    
    CGPoint bufferProgressCenter = self.bufferProgressView.center;
    bufferProgressCenter.y = min_view_h * 0.5;
    self.bufferProgressView.center = bufferProgressCenter;
    
    CGPoint sliderProgressCenter = self.sliderProgressView.center;
    sliderProgressCenter.y = min_view_h * 0.5;
    self.sliderProgressView.center = sliderProgressCenter;
    
    CGPoint sliderBtnCenter = self.sliderBtn.center;
    sliderBtnCenter.y = min_view_h * 0.5;
    self.sliderBtn.center = sliderBtnCenter;
}

- (void)addSubViews {
    
    self.sliderBtn.userInteractionEnabled = NO;
    
    self.thumbSize = CGSizeMake(kSliderBtnWH, kSliderBtnWH);
    self.sliderHeight = kProgressH;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bgProgressView];
    [self addSubview:self.bufferProgressView];
    [self addSubview:self.sliderProgressView];
    [self addSubview:self.sliderBtn];
    [self addSubview:self.loadingBarView];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:self.tapGesture];
    
    UIPanGestureRecognizer *sliderGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderGesture:)];
    [self addGestureRecognizer:sliderGesture];
}

#pragma mark - Setter

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _maximumTrackTintColor = maximumTrackTintColor;
    self.bgProgressView.backgroundColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    _minimumTrackTintColor = minimumTrackTintColor;
    self.sliderProgressView.backgroundColor = minimumTrackTintColor;
}

- (void)setBufferTrackTintColor:(UIColor *)bufferTrackTintColor {
    _bufferTrackTintColor = bufferTrackTintColor;
    self.bufferProgressView.backgroundColor = bufferTrackTintColor;
}

- (void)setLoadingTintColor:(UIColor *)loadingTintColor {
    _loadingTintColor = loadingTintColor;
    self.loadingBarView.backgroundColor = loadingTintColor;
}

- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage {
    _maximumTrackImage = maximumTrackImage;
    self.bgProgressView.image = maximumTrackImage;
    self.maximumTrackTintColor = [UIColor clearColor];
}

- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage {
    _minimumTrackImage = minimumTrackImage;
    self.sliderProgressView.image = minimumTrackImage;
    self.minimumTrackTintColor = [UIColor clearColor];
}

- (void)setBufferTrackImage:(UIImage *)bufferTrackImage {
    _bufferTrackImage = bufferTrackImage;
    self.bufferProgressView.image = bufferTrackImage;
    self.bufferTrackTintColor = [UIColor clearColor];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setBackgroundImage:image forState:state];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setImage:image forState:state];
}

- (void)setValue:(float)value {
    if (isnan(value)) return;
    value = MIN(1.0, value);
    _value = value;
    if (self.sliderBtn.hidden) {
        
        CGRect sliderProgressFrame = self.sliderProgressView.frame;
        sliderProgressFrame.size.width = CGRectGetWidth(self.bgProgressView.bounds) * value;
        self.sliderProgressView.frame = sliderProgressFrame;
        
    } else {
        
        CGPoint sliderBtnCenter = self.sliderBtn.center;
        sliderBtnCenter.x = CGRectGetWidth(self.bgProgressView.bounds) * value;
        self.sliderBtn.center = sliderBtnCenter;

        CGRect sliderProgressFrame = self.sliderProgressView.frame;
        sliderProgressFrame.size.width = self.sliderBtn.center.x;
        self.sliderProgressView.frame = sliderProgressFrame;
    }
}

- (void)setBufferValue:(float)bufferValue {
    if (isnan(bufferValue)) return;
    bufferValue = MIN(1.0, bufferValue);
    _bufferValue = bufferValue;
    
    CGRect bufferProgressFrame = self.bufferProgressView.frame;
    bufferProgressFrame.size.width = CGRectGetWidth(self.bgProgressView.bounds) * bufferValue;
    self.bufferProgressView.frame = bufferProgressFrame;
}

- (void)setAllowTapped:(BOOL)allowTapped {
    _allowTapped = allowTapped;
    if (!allowTapped) {
        [self removeGestureRecognizer:self.tapGesture];
    }
}

- (void)setSliderHeight:(CGFloat)sliderHeight {
    if (isnan(sliderHeight)) return;
    _sliderHeight = sliderHeight;
    
    CGRect bgProgressFrame = self.bgProgressView.frame;
    bgProgressFrame.size.height = sliderHeight;
    self.bgProgressView.frame = bgProgressFrame;
    
    CGRect bufferProgressFrame = self.bufferProgressView.frame;
    bufferProgressFrame.size.height = sliderHeight;
    self.bufferProgressView.frame = bufferProgressFrame;
    
    CGRect sliderProgressFrame = self.sliderProgressView.frame;
    sliderProgressFrame.size.height = sliderHeight;
    self.sliderProgressView.frame = sliderProgressFrame;
}

- (void)setIsHideSliderBlock:(BOOL)isHideSliderBlock {
    _isHideSliderBlock = isHideSliderBlock;
    // Hide Slider
    if (isHideSliderBlock) {
        self.sliderBtn.hidden = YES;
        
        CGRect bgProgressFrame = self.bgProgressView.frame;
        bgProgressFrame.size.height = 0;
        self.bgProgressView.frame = bgProgressFrame;
        
        CGRect bufferProgressFrame = self.bufferProgressView.frame;
        bufferProgressFrame.size.height = 0;
        self.bufferProgressView.frame = bufferProgressFrame;
        
        CGRect sliderProgressFrame = self.sliderProgressView.frame;
        sliderProgressFrame.size.height = 0;
        self.sliderProgressView.frame = sliderProgressFrame;

        self.allowTapped = NO;
    }
}

/**
 *  Starts animation of the spinner.
 */
- (void)startAnimating {
    if (self.isLoading) return;
    self.isLoading = YES;
    self.bufferProgressView.hidden = YES;
    self.sliderProgressView.hidden = YES;
    self.sliderBtn.hidden = YES;
    self.loadingBarView.hidden = NO;
    
    [self.loadingBarView.layer removeAllAnimations];
    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    animationGroup.duration = 0.4;
    animationGroup.beginTime = CACurrentMediaTime() + 0.4;
    animationGroup.repeatCount = MAXFLOAT;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animation];
    scaleAnimation.keyPath = @"transform.scale.x";
    scaleAnimation.fromValue = @(1000.0f);
    scaleAnimation.toValue = @(CGRectGetWidth(self.bounds) * 10);
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animation];
    alphaAnimation.keyPath = @"opacity";
    alphaAnimation.fromValue = @(1.0f);
    alphaAnimation.toValue = @(0.0f);
    
    [animationGroup setAnimations:@[scaleAnimation, alphaAnimation]];
    [self.loadingBarView.layer addAnimation:animationGroup forKey:@"loading"];
}

/**
 *  Stops animation of the spinnner.
 */
- (void)stopAnimating {
    self.isLoading = NO;
    self.bufferProgressView.hidden = NO;
    self.sliderProgressView.hidden = NO;
    self.sliderBtn.hidden = self.isHideSliderBlock;
    self.loadingBarView.hidden = YES;
    [self.loadingBarView.layer removeAllAnimations];
}

#pragma mark - User Action

- (void)sliderGesture:(UIGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self sliderBtnTouchBegin:self.sliderBtn];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            [self sliderBtnDragMoving:self.sliderBtn point:[gesture locationInView:self.bgProgressView]];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            [self sliderBtnTouchEnded:self.sliderBtn];
        }
            break;
        default:
            break;
    }
}

- (void)sliderBtnTouchBegin:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(sliderTouchBegan:)]) {
        [self.delegate sliderTouchBegan:self.value];
    }
    if (self.animate) {
        [UIView animateWithDuration:kAnimate animations:^{
            btn.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
    }
}

- (void)sliderBtnTouchEnded:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(sliderTouchEnded:)]) {
        [self.delegate sliderTouchEnded:self.value];
    }
    if (self.animate) {
        [UIView animateWithDuration:kAnimate animations:^{
            btn.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)sliderBtnDragMoving:(UIButton *)btn point:(CGPoint)touchPoint {
    // touch point
    CGPoint point = touchPoint;
    // get process value
    CGFloat value = (point.x - CGRectGetWidth(btn.bounds) * 0.5) / CGRectGetWidth(self.bgProgressView.bounds);
    // value between 0-1
    value = value >= 1.0 ? 1.0 : value <= 0.0 ? 0.0 : value;
    if (self.value == value) return;
    self.isForward = self.value < value;
    self.value = value;
    if ([self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:value];
    }
}

- (void)tapped:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self.bgProgressView];
    // get process
    CGFloat value = point.x * 1.0 / CGRectGetWidth(self.bgProgressView.bounds);
    value = value >= 1.0 ? 1.0 : value <= 0 ? 0 : value;
    self.value = value;
    if ([self.delegate respondsToSelector:@selector(sliderTapped:)]) {
        [self.delegate sliderTapped:value];
    }
}

#pragma mark - getter

- (UIView *)bgProgressView {
    if (!_bgProgressView) {
        _bgProgressView = [UIImageView new];
        _bgProgressView.backgroundColor = [UIColor grayColor];
        _bgProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _bgProgressView.clipsToBounds = YES;
    }
    return _bgProgressView;
}

- (UIView *)bufferProgressView {
    if (!_bufferProgressView) {
        _bufferProgressView = [UIImageView new];
        _bufferProgressView.backgroundColor = [UIColor whiteColor];
        _bufferProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _bufferProgressView.clipsToBounds = YES;
    }
    return _bufferProgressView;
}

- (UIView *)sliderProgressView {
    if (!_sliderProgressView) {
        _sliderProgressView = [UIImageView new];
        _sliderProgressView.backgroundColor = [UIColor redColor];
        _sliderProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _sliderProgressView.clipsToBounds = YES;
    }
    return _sliderProgressView;
}

- (SliderButton *)sliderBtn {
    if (!_sliderBtn) {
        _sliderBtn = [SliderButton buttonWithType:UIButtonTypeCustom];
        [_sliderBtn setAdjustsImageWhenHighlighted:NO];
    }
    return _sliderBtn;
}

- (UIView *)loadingBarView {
    if (!_loadingBarView) {
        _loadingBarView = [[UIView alloc] init];
        _loadingBarView.backgroundColor = [UIColor whiteColor];
        _loadingBarView.hidden = YES;
    }
    return _loadingBarView;
}


-(void)dealloc {
    [self removeGestureRecognizer:self.tapGesture];
}

@end
