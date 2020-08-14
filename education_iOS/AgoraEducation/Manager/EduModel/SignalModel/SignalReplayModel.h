//
//  SignalReplayModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/23.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalEnum.h"

NS_ASSUME_NONNULL_BEGIN
@interface SignalReplayInfoModel : NSObject
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *recordId;
@end

@interface SignalReplayModel : NSObject
// MessageCmdTypeReplay
@property (nonatomic, assign) MessageCmdType cmd;
@property (nonatomic, strong) SignalReplayInfoModel *data;
@end

NS_ASSUME_NONNULL_END
