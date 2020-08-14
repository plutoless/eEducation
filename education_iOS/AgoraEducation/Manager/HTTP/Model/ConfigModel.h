//
//  ConfigModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/6.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiLanguageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfigModel : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString* msg;
@property (nonatomic, strong) MultiLanguageModel* multiLanguage;

@end

NS_ASSUME_NONNULL_END
