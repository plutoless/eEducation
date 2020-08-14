//
//  SignalModel.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/6.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SignalModel : NSObject

@property(nonatomic, strong) NSString *appId;
@property(nonatomic, strong) NSString *token;
@property(nonatomic, strong) NSString *uid;

@end

NS_ASSUME_NONNULL_END
