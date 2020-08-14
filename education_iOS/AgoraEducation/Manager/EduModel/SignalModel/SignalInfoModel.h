//
//  SignalInfoModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/25.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignalEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface SignalInfoModel : NSObject
@property (nonatomic, assign) NSInteger uid; // changed uid
@property (nonatomic, assign) SignalType signalType;
@end

NS_ASSUME_NONNULL_END
