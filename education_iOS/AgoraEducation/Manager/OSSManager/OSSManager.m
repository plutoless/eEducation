//
//  OSSManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/3/30.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "OSSManager.h"
#import <AliyunOSSiOS/AliyunOSSiOS.h>
#import "HttpManager.h"
#import "CommonModel.h"
#import "EduConfigModel.h"
#import "URL.h"

static OSSManager *manager = nil;

@interface OSSManager()
@property(nonatomic, strong)OSSClient *ossClient;
@property(nonatomic, strong)NSString *endpoint;
@property(nonatomic, assign)BOOL initOSSAuthClient;

@end

@implementation OSSManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.initOSSAuthClient = NO;
    });
    return manager;
}

+ (void)initOSSAuthClientWithSTSURL:(NSString *)stsURL endpoint:(NSString*)endpoint {
    
    OSSAuthCredentialProvider *credentialProvider = [[OSSAuthCredentialProvider alloc] initWithAuthServerUrl:stsURL];
    OSSClientConfiguration *cfg = [[OSSClientConfiguration alloc] init];
    
    [OSSManager shareManager].ossClient = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credentialProvider clientConfiguration:cfg];
}

+ (void)uploadOSSWithBucketName:(NSString *)bucketName objectKey:(NSString *)objectKey callbackBody:(NSString *)callbackBody callbackBodyType:(NSString *)callbackBodyType endpoint:(NSString*)endpoint fileURL:(NSURL *)fileURL completeSuccessBlock:(void (^ _Nullable) (NSString *uploadSerialNumber))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    if(!OSSManager.shareManager.initOSSAuthClient){
        OSSManager.shareManager.initOSSAuthClient = YES;
        NSString *stsURL = [NSString stringWithFormat:HTTP_OSS_STS, HTTP_BASE_URL];
        [OSSManager initOSSAuthClientWithSTSURL:stsURL endpoint:endpoint];
    }
    
    OSSPutObjectRequest * request = [OSSPutObjectRequest new];
    request.bucketName = bucketName;
    request.objectKey = objectKey;
    request.uploadingFileURL = fileURL;
    NSString *callbackURL = [NSString stringWithFormat:HTTP_OSS_STS_CALLBACK, HTTP_BASE_URL];
    request.callbackParam = @{
        @"callbackUrl": callbackURL,
        @"callbackBody": callbackBody,
        @"callbackBodyType": callbackBodyType};
    
    OSSTask *putTask = [[OSSManager shareManager].ossClient putObject:request];
    [putTask continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {

        if (!task.error) {

            OSSPutObjectResult *uploadResult = task.result;
            CommonModel *model = [CommonModel yy_modelWithJSON:uploadResult.serverReturnJsonString];
            if(model.code == 0){
                if(successBlock != nil) {
                    successBlock(model.data);
                }
            } else {
                if(failBlock != nil) {
                    NSString *errMsg = [EduConfigModel generateHttpErrorMessageWithDescribe:NSLocalizedString(@"UploadOSSErrorText", nil) errorCode:model.code];
                    failBlock(errMsg);
                }
            }

        } else {
            if(failBlock != nil) {
                failBlock(task.error.description);
            }
        }
        return nil;
    }];
}
@end
