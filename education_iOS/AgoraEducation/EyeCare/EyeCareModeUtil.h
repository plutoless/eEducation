//
//  EyeCareModeUtil.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/9/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EyeCareModeUtil : NSObject
+ (instancetype)sharedUtil;
- (void)switchEyeCareMode:(BOOL)on;
- (BOOL)queryEyeCareModeStatus;
@end

NS_ASSUME_NONNULL_END
