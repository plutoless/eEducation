//
//  MultiLanguageModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/3/10.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MultiLanguageModel : NSObject

@property (nonatomic, strong) NSDictionary<NSString*, NSString*> *cn;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*> *en;

@end

NS_ASSUME_NONNULL_END
