//
//  EnterRoomAllModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/7.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EnterRoomInfoModel :NSObject

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userToken;

@end


@interface EnterRoomAllModel :NSObject
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) EnterRoomInfoModel *data;

@end


NS_ASSUME_NONNULL_END
