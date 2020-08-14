//
//  CYXHttpRequest.m
//  TenMinDemo
//
//  Created by apple开发 on 16/5/31.
//  Copyright © 2016年 CYXiang. All rights reserved.
//

#import "HttpManager.h"
#import <AFNetworking/AFNetworking.h>
#import "URL.h"
#import "KeyCenter.h"

@interface HttpManager ()

@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;

@end

static HttpManager *manager = nil;

@implementation HttpManager
+ (instancetype)shareManager{
    @synchronized(self){
        if (!manager) {
            manager = [[self alloc]init];
            [manager initSessionManager];
        }
        return manager;
    }
}

- (void)initSessionManager {
    self.sessionManager = [AFHTTPSessionManager manager];
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.requestSerializer.timeoutInterval = 30;
}

+ (void)get:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    if(headers != nil && headers.allKeys.count > 0){
        NSArray<NSString*> *keys = headers.allKeys;
        for(NSString *key in keys){
            [HttpManager.shareManager.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    AgoraLogInfo(@"\n============>Get HTTP Start<============\n\
          \nurl==>\n%@\n\
          \nheaders==>\n%@\n\
          \nparams==>\n%@\n\
          ", url, headers, params);
    
    [HttpManager.shareManager.sessionManager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        AgoraLogInfo(@"\n============>Get HTTP Success<============\n\
              \nResult==>\n%@\n\
              ", responseObject);
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        AgoraLogInfo(@"\n============>Get HTTP Error<============\n\
              \nError==>\n%@\n\
              ", error.description);
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)post:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary<NSString*, NSString*> *)headers success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure {

    if(headers != nil && headers.allKeys.count > 0){
        NSArray<NSString*> *keys = headers.allKeys;
        for(NSString *key in keys){
            [HttpManager.shareManager.sessionManager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }

    AgoraLogInfo(@"\n============>Post HTTP Start<============\n\
          \nurl==>\n%@\n\
          \nheaders==>\n%@\n\
          \nparams==>\n%@\n\
          ", url, headers, params);
    
    [HttpManager.shareManager.sessionManager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        AgoraLogInfo(@"\n============>Post HTTP Success<============\n\
              \nResult==>\n%@\n\
              ", responseObject);
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        AgoraLogInfo(@"\n============>Post HTTP Error<============\n\
              \nError==>\n%@\n\
              ", error.description);
        if (failure) {
          failure(error);
        }
    }];
}

+ (void)getAppConfigWithSuccess:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure {
        
    NSString *url = [NSString stringWithFormat:HTTP_GET_LANGUAGE, HTTP_BASE_URL];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"Authorization"] = [HttpManager authorization];
    
    [HttpManager get:url params:nil headers:headers success:^(id responseObj) {
        
        if(success != nil){
            success(responseObj);
        }
    } failure:^(NSError *error) {
        
        if(failure != nil) {
            failure(error);
        }
    }];
}

+ (void)getReplayInfoWithUserToken:(NSString *)userToken appId:(NSString *)appId roomId:(NSString *)roomId recordId:(NSString *)recordId success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = userToken;
    headers[@"Authorization"] = [HttpManager authorization];

    NSString *url = [NSString stringWithFormat:HTTP_GET_REPLAY_INFO, HTTP_BASE_URL, appId, roomId, recordId];
    [HttpManager get:url params:nil headers:headers success:^(id responseObj) {
        
        if(success != nil){
            success(responseObj);
        }
    } failure:^(NSError *error) {
        
        if(failure != nil) {
            failure(error);
        }
    }];
}

+ (void)getWhiteInfoWithUserToken:(NSString *)userToken appid:(NSString *)appid roomId:(NSString *)roomId completeSuccessBlock:(void (^ _Nullable) (id responseObj))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {
    
    NSString *url = [NSString stringWithFormat:[KeyCenter boardInfoApiURL], HTTP_BASE_URL, appid, roomId];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = userToken;
    headers[@"Authorization"] = [HttpManager authorization];

    [HttpManager get:url params:nil headers:headers success:^(id responseObj) {
        
        if(successBlock != nil) {
            successBlock(responseObj);
        }
    } failure:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error);
        }
    }];
}
+ (NSString *)authorization {
    NSString *auth = [KeyCenter authorization];
    auth = [auth stringByReplacingOccurrencesOfString:@"Basic " withString:@""];
    auth = [NSString stringWithFormat:@"Basic %@", auth];
    return auth;
}
@end
