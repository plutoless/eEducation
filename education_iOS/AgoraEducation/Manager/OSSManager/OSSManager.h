//
//  OSSManager.h
//  AgoraEducation
//
//  Created by SRS on 2020/3/30.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSManager : NSObject

+ (void)initOSSAuthClientWithSTSURL:(NSString *)stsURL endpoint:(NSString*)endpoint;

+ (void)uploadOSSWithBucketName:(NSString *)bucketName objectKey:(NSString *)objectKey callbackBody:(NSString *)callbackBody callbackBodyType:(NSString *)callbackBodyType endpoint:(NSString*)endpoint fileURL:(NSURL *)fileURL completeSuccessBlock:(void (^ _Nullable) (NSString *uploadSerialNumber))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock;

@end

NS_ASSUME_NONNULL_END
