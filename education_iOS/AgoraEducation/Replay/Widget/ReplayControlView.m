//
//  ReplayControlView.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "ReplayControlView.h"

@interface ReplayControlView()<SliderViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *playControlView;

@end

@implementation ReplayControlView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self.playControlView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.playControlView];
        
        NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.playControlView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.playControlView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.playControlView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.playControlView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

-(void)initView {
    self.layer.cornerRadius = 8;
    self.clipsToBounds = YES;
    
    self.sliderView.delegate = self;
    self.sliderView.thumbSize = CGSizeMake(50, 50);
    self.sliderView.maximumTrackTintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3];
    self.sliderView.bufferTrackTintColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    self.sliderView.minimumTrackTintColor = [UIColor colorWithRed:68/255.0 green:162/255.0 blue:252/255.0 alpha:1];
    [self.sliderView setThumbImage:[UIImage imageNamed:@"slider"]  forState:UIControlStateNormal];
    self.sliderView.sliderHeight = 5;
}

#pragma mark - action
- (IBAction)onPlayPauseButtonClick:(id)sender {
    self.playOrPauseBtn.selected = !self.playOrPauseBtn.isSelected;
    if ([self.delegate respondsToSelector:@selector(playPauseButtonClicked:)]) {
        [self.delegate playPauseButtonClicked:self.playOrPauseBtn.isSelected];
    }
}

#pragma mark SliderViewDelegate
- (void)sliderTouchBegan:(float)value {
     self.sliderView.isdragging = YES;
    
    if ([self.delegate respondsToSelector:@selector(sliderTouchBegan:)]) {
        [self.delegate sliderTouchBegan:value];
    }
}

- (void)sliderValueChanged:(float)value {
    
    if ([self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:value];
    }
}

- (void)sliderTouchEnded:(float)value {
    if ([self.delegate respondsToSelector:@selector(sliderTouchEnded:)]) {
        [self.delegate sliderTouchEnded:value];
    }
}

- (void)sliderTapped:(float)value {
    if ([self.delegate respondsToSelector:@selector(sliderTapped:)]) {
        [self.delegate sliderTapped:value];
    }
}

@end
