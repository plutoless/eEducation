//
//  MessageModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/29.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageInfoModel : NSObject

// for message
@property (nonatomic, strong) NSString *userId; // from
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) BOOL isSelfSend;
@property (nonatomic, assign) CGFloat cellHeight;

// for replay
@property (nonatomic, strong) NSString *recordId;

@end

@interface MessageModel : NSObject
// MessageCmdTypeChat
@property (nonatomic, assign) MessageCmdType cmd;
@property (nonatomic, strong) MessageInfoModel *data;
@end

NS_ASSUME_NONNULL_END
