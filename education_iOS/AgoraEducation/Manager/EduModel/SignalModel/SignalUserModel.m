//
//  SignalUserModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/4/22.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "SignalUserModel.h"

@implementation SignalUserModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"data" : [UserModel class]};
}
@end
