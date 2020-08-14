//
//  EduConfigModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EduConfigModel.h"
#import "KeyCenter.h"

static EduConfigModel *manager = nil;

@implementation EduConfigModel

+ (instancetype)shareInstance {
    if(!manager){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [EduConfigModel new];
        });
    }
    return manager;
}

// 防止使用alloc开辟空间
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if(!manager){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [super allocWithZone:zone];
        });
    }
    return manager;
}

- (instancetype)init{
    @synchronized(self) {
        if(self = [super init]) {
            self.appId = [KeyCenter agoraAppid];
        }
    }
    return self;
}

+ (NSString *)generateHttpErrorMessageWithDescribe:(NSString *)des errorCode:(NSInteger)errorCode {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray<NSString*> *allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [allLanguages objectAtIndex:0];
    NSString *msg = @"";
    if([preferredLang containsString:@"zh-Hans"]) {
        msg = [EduConfigModel.shareInstance.multiLanguage.cn valueForKey:@(errorCode).stringValue];
    } else {
        msg = [EduConfigModel.shareInstance.multiLanguage.en valueForKey:@(errorCode).stringValue];
    }
    
    if(msg == nil || msg.length == 0) {
        msg = [NSString stringWithFormat:@"%@：%ld", des, (long)errorCode];
    }
    return msg;
}

@end
