//
//  JsonParseUtil.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/6/27.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "JsonParseUtil.h"

@implementation JsonParseUtil
+ (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    json = [json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    json = [json stringByReplacingOccurrencesOfString:@" " withString:@""];
    return json;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        AgoraLogError(@"Json Parse Err：%@",err);
        return nil;
    }
    return dic;
}
@end
