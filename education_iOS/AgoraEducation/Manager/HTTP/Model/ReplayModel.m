//
//  ReplayModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/3/3.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "ReplayModel.h"

@implementation RecordDetailsModel

@end


@implementation ReplayInfoModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"recordDetails" : [RecordDetailsModel class]};
}
@end


@implementation ReplayModel

@end
