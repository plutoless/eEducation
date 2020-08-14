//
//  CYXHttpRequest.h
//  TenMinDemo
//
//  Created by apple开发 on 16/5/31.
//  Copyright © 2016年 CYXiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpManager : NSObject
// common
+ (void)get:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id))success failure:(void (^)(NSError *))failure;
+ (void)post:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;

// service
+ (void)getAppConfigWithSuccess:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;
+ (void)getReplayInfoWithUserToken:(NSString *)userToken appId:(NSString *)appId roomId:(NSString *)roomId recordId:(NSString *)recordId success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;
+ (void)getWhiteInfoWithUserToken:(NSString *)userToken appid:(NSString *)appid roomId:(NSString *)roomId completeSuccessBlock:(void (^ _Nullable) (id responseObj))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock;

+ (NSString *)authorization;
@end
