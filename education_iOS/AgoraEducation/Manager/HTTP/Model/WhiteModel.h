//
//  WhiteModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/16.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WhiteInfoModel : NSObject

@property (nonatomic, strong) NSString *boardId;
@property (nonatomic, strong) NSString *boardToken;

@end


@interface WhiteModel : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) WhiteInfoModel *data;

@end

NS_ASSUME_NONNULL_END
