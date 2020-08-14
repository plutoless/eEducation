//
//  OneToOneEducationManager.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/31.
//  Copyright © 2019 Agora. All rights reserved.
//


#import "BaseEducationManager+GlobalStates.h"
#import "BaseEducationManager+Signal.h"
#import "BaseEducationManager+WhiteBoard.h"
#import "BaseEducationManager+RTC.h"

NS_ASSUME_NONNULL_BEGIN

@interface OneToOneEducationManager : BaseEducationManager

/* ==================================>Session Model<================================ */
@property (nonatomic, strong) UserModel * _Nullable teacherModel;
@property (nonatomic, strong) UserModel * _Nullable studentModel;
@property (nonatomic, strong) RoomModel * _Nullable roomModel;
@property (nonatomic, strong) SignalShareScreenInfoModel * _Nullable shareScreenInfoModel;

@property (nonatomic, strong) NSMutableArray<RTCVideoSessionModel*> *rtcVideoSessionModels;

- (void)releaseResources;

@end

NS_ASSUME_NONNULL_END
