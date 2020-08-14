//
//  BaseEducationManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager.h"
#import "AppDelegate.h"

@implementation BaseEducationManager

- (instancetype)init {
    if (self = [super init]){
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWillTerminate) name:NOTICE_KEY_ON_WILL_TERMINATE object:nil];
    }
    return self;
}

- (void)onWillTerminate {
    [self releaseResources];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseResources];
}

- (void)releaseResources {
    NSAssert(1 == 0, @"subclass must overwrite releaseResources");
}
@end
