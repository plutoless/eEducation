//
//  WhiteBoardTouchView.m
//  AgoraEducation
//
//  Created by SRS on 2020/4/20.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "WhiteBoardTouchView.h"

@interface WhiteBoardTouchView ()

@property (nonatomic, copy) void (^touchBlock)(void);

@end

@implementation WhiteBoardTouchView

- (void)setupInView:(UIView *)superView onTouchBlock:(void (^ _Nullable) (void))touchBlock {
     
    self.touchBlock = touchBlock;
    
    self.hidden = YES;
    
    [superView addSubview:self];

    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    [superView addConstraints:@[topConstraint, leftConstraint, rightConstraint, bottomConstraint]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    
    if(self.touchBlock != nil){
        self.touchBlock();
    }
}

@end
