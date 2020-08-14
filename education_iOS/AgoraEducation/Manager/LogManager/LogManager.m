//
//  LogManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/3/24.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "LogManager.h"
#import "SSZipArchive.h"
#import "HttpManager.h"
#import "URL.h"
#import "OSSManager.h"
#import "EduConfigModel.h"
#import "LogParamsModel.h"

typedef NS_ENUM(NSInteger, ZipStateType) {
    ZipStateTypeOK              = 0,
    ZipStateTypeOnNotFound      = 1,
    ZipStateTypeOnRemoveError   = 2,
    ZipStateTypeOnZipError      = 3,
};


@implementation LogManager

+ (void)setupLog {
    
    [DDLog addLogger:[DDOSLogger sharedInstance] withLevel:DDLogLevelVerbose];

    NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/AgoraEducation"];
    NSLog(@"logFilePath==>%@", logFilePath);
    DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logFilePath];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.maximumFileSize = 1024 * 1024;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
    [DDLog addLogger:fileLogger withLevel:ddLogLevel];
}

+ (void)uploadLogWithCompleteSuccessBlock:(void (^ _Nullable) (NSString *uploadSerialNumber))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSString *logDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/AgoraEducation"];
    NSString *zipName = [LogManager generateZipName];
    NSString *zipPath = [NSString stringWithFormat:@"%@/%@", logDirectoryPath, zipName];
    NSInteger zipCode = [LogManager zipFilesWithSourceDirectory:logDirectoryPath toPath:zipPath];
    switch (zipCode) {
        case ZipStateTypeOnNotFound:
            if(failBlock != nil) {
                failBlock(NSLocalizedString(@"LogNotFoundText", nil));
            }
            break;
        case ZipStateTypeOnRemoveError:
            if(failBlock != nil) {
                failBlock(NSLocalizedString(@"LogClearErrorText", nil));
            }
            break;
        case ZipStateTypeOnZipError:
            if(failBlock != nil) {
                failBlock(NSLocalizedString(@"LogZipErrorText", nil));
            }
            break;
        default:
            break;
    }
    if (zipCode != ZipStateTypeOK){
        if(failBlock != nil) {
            failBlock(NSLocalizedString(@"LogZipErrorText", nil));
        }
        return;
    }
    
    NSString *url = [NSString stringWithFormat:HTTP_LOG_PARAMS, HTTP_BASE_URL];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"appCode"] = @"edu-saas";
    params[@"osType"] = @(1);// ios
    
    NSInteger deviceType = 1;
    if (UIUserInterfaceIdiomPhone == [UIDevice currentDevice].userInterfaceIdiom) {
        deviceType = 1;
    } else if(UIUserInterfaceIdiomPad == [UIDevice currentDevice].userInterfaceIdiom) {
        deviceType = 2;
    }
    params[@"terminalType"] = @(deviceType);
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    params[@"appVersion"] = app_Version;
    
    NSString *roomId = EduConfigModel.shareInstance.roomId;
    if(roomId == nil){
        roomId = @"0";
    }
    params[@"roomId"] = roomId;
    params[@"appId"] = EduConfigModel.shareInstance.appId;
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = EduConfigModel.shareInstance.userToken;
    
    [HttpManager get:url params:params headers:headers success:^(id responseObj) {
        LogParamsModel *model = [LogParamsModel yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            LogParamsInfoModel *infoModel = model.data;
            [OSSManager uploadOSSWithBucketName:infoModel.bucketName objectKey:infoModel.ossKey callbackBody:infoModel.callbackBody callbackBodyType:infoModel.callbackContentType endpoint:infoModel.ossEndpoint fileURL:[NSURL URLWithString:zipPath] completeSuccessBlock:^(NSString * _Nonnull uploadSerialNumber) {
                if(successBlock != nil) {
                    successBlock(uploadSerialNumber);
                }
            } completeFailBlock:^(NSString * _Nonnull errMessage) {
                if(failBlock != nil) {
                    failBlock(errMessage);
                }
            }];
        } else {
            if(failBlock != nil) {
                NSString *errMsg = [EduConfigModel generateHttpErrorMessageWithDescribe:NSLocalizedString(@"GetLogParamsErrorText", nil) errorCode:model.code];
                failBlock(errMsg);
            }
        }
    } failure:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error.description);
        }
    }];
}

+ (NSInteger)zipFilesWithSourceDirectory:(NSString *)directoryPath toPath:(NSString *)zipPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectoryExist = [fileManager fileExistsAtPath:directoryPath];
    if(!isDirectoryExist) {
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSDirectoryEnumerator *direnum = [fileManager enumeratorAtPath:directoryPath];
    NSString *filename;
    while (filename = [direnum nextObject]) {
        if ([[filename pathExtension] isEqualToString:@"zip"]) {
            
            NSString *logZipPath = [NSString stringWithFormat:@"%@/%@", directoryPath, filename];
            
            NSError *error;
            BOOL rmvSuccess = [fileManager removeItemAtPath:logZipPath error:&error];
            if (error || !rmvSuccess) {
                return ZipStateTypeOnRemoveError;
            }
            
            break;
        }
    }
    
    BOOL zipSuccess = [SSZipArchive createZipFileAtPath:zipPath withContentsOfDirectory:directoryPath];
    if(zipSuccess){
        return ZipStateTypeOK;
    }
    return ZipStateTypeOnZipError;
}

+ (NSString *)generateZipName {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSString *zipName = [NSString stringWithFormat:@"%@.zip", currentTimeString];
    return zipName;
}

@end
