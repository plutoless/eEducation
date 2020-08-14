//
//  EyeCareModeUtil.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/9/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EyeCareModeUtil.h"
#import "SkinCoverWindow.h"

static EyeCareModeUtil *eyeCareUtil = nil;
/// NSUserDefaults存的key
static NSString * const kEyeCareModeStatus = @"kEyeCareModeStatus";
static NSInteger const kWeSkinCoverWindowLevel = 2099;

@interface EyeCareModeUtil ()
@property (nonatomic, strong) SkinCoverWindow *skinCoverWindow;
@end


@implementation EyeCareModeUtil
+ (instancetype)sharedUtil {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eyeCareUtil = [[self alloc] init];
    });
    return eyeCareUtil;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eyeCareUtil = [super allocWithZone:zone];
    });
    return eyeCareUtil;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return eyeCareUtil;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    return eyeCareUtil;
}

- (BOOL)queryEyeCareModeStatus {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kEyeCareModeStatus];
}

- (void)switchEyeCareMode:(BOOL)on {
    if (on) {
        if ([UIApplication sharedApplication].keyWindow != nil) {
            self.skinCoverWindow.hidden = NO;
        }
    }else {
        if ([[UIApplication sharedApplication].windows containsObject:self.skinCoverWindow]) {
            self.skinCoverWindow.hidden = YES;
        }
    }
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:kEyeCareModeStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (SkinCoverWindow *)skinCoverWindow {
    if (!_skinCoverWindow) {
        _skinCoverWindow = [[SkinCoverWindow alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _skinCoverWindow.windowLevel = kWeSkinCoverWindowLevel;
        _skinCoverWindow.userInteractionEnabled = NO;
        [_skinCoverWindow makeKeyWindow];
    }
    return _skinCoverWindow;
}


@end
