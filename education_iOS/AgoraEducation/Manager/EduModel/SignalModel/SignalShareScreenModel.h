//
//  SignalShareScreenModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/23.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface SignalShareScreenInfoModel : NSObject
@property (nonatomic, assign) NSInteger type;//1=start 0=end
@property (nonatomic, assign) NSInteger screenId;
@property (nonatomic, strong) NSString *userId;
@end

@interface SignalShareScreenModel : NSObject
// MessageCmdTypeShareScreen
@property (nonatomic, assign) MessageCmdType cmd;
@property (nonatomic, strong) SignalShareScreenInfoModel *data;
@end

NS_ASSUME_NONNULL_END
