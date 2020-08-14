//
//  SignalP2PModel.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/22.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface SignalP2PInfoModel : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) SignalLinkState type;
@end

@interface SignalP2PModel : NSObject
@property (nonatomic, assign) NSInteger cmd;
@property (nonatomic, strong) SignalP2PInfoModel *data;
@end

NS_ASSUME_NONNULL_END
