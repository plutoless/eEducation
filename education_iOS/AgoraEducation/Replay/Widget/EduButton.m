//
//  EduButton.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/17.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EduButton.h"

@implementation EduButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -20, -20);
    return CGRectContainsPoint(bounds, point);
}

@end
