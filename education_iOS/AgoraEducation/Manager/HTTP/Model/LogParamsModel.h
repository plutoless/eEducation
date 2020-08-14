//
//  LogParamsModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/8.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogParamsInfoModel : NSObject
@property (nonatomic, strong) NSString *bucketName;
@property (nonatomic, strong) NSString *callbackBody;
@property (nonatomic, strong) NSString *callbackContentType;
@property (nonatomic, strong) NSString *ossKey;
@property (nonatomic, strong) NSString *accessKeyId;
@property (nonatomic, strong) NSString *accessKeySecret;
@property (nonatomic, strong) NSString *securityToken;
@property (nonatomic, strong) NSString *ossEndpoint;
@end

@interface LogParamsModel : NSObject
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) LogParamsInfoModel *data;
@end

NS_ASSUME_NONNULL_END
