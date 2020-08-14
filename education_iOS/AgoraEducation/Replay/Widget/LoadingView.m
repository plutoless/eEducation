//
//  LoadingView.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/17.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView()

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@end


@implementation LoadingView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self.loadingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.loadingView];
        
        NSLayoutConstraint *viewTopConstraint = [NSLayoutConstraint constraintWithItem:self.loadingView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *viewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.loadingView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *viewRightConstraint = [NSLayoutConstraint constraintWithItem:self.loadingView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *viewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.loadingView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self addConstraints:@[viewTopConstraint, viewLeftConstraint, viewRightConstraint, viewBottomConstraint]];
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
    self.loadingLabel.text = NSLocalizedString(@"LoadingText", nil);
}

-(void)showLoading {
    if(!self.hidden) {
        return;
    }
    
    self.hidden = NO;
    [self startAnimation];
}

-(void)hiddenLoading {
    if(self.hidden) {
        return;
    }
    
    self.hidden = YES;
    [self stopAnimation];
}

-(void)startAnimation {
    
    [self.imageView.layer removeAllAnimations];
    
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
    rotationAnimation.duration = 2;
    rotationAnimation.repeatCount = HUGE_VALF;
    [self.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)stopAnimation {
    [self.imageView.layer removeAllAnimations];
}

@end
