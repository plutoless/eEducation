//
//  MultiLanguageModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/3/10.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "MultiLanguageModel.h"

@implementation MultiLanguageModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"cn": @"zh-cn",
             @"en": @"en-us",};
}
@end

