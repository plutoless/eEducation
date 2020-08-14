//
//  RoomAllModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/8.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "RoomAllModel.h"

@implementation RoomModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"coVideoUsers" : [UserModel class]};
}
@end

@implementation RoomInfoModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"localUser": @"user"};
}
@end

@implementation RoomAllModel
@end
