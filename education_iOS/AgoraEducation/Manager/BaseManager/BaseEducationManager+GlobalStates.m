//
//  BaseEducationManager+GlobalStates.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager+GlobalStates.h"
#import "HttpManager.h"
#import "ConfigModel.h"
#import "EnterRoomAllModel.h"
#import "CommonModel.h"
#import "URL.h"
#import "KeyCenter.h"

@implementation BaseEducationManager (GlobalStates)

+ (void)getConfigWithSuccessBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {

    [HttpManager getAppConfigWithSuccess:^(id responseObj) {
        
        ConfigModel *model = [ConfigModel yy_modelWithDictionary:responseObj];
        if(model.code == 0) {
            
            EduConfigModel.shareInstance.multiLanguage = model.multiLanguage;
            
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil) {
                NSString *errMsg = [EduConfigModel generateHttpErrorMessageWithDescribe:NSLocalizedString(@"RequestFailedText", nil) errorCode:model.code];
                failBlock(errMsg);
            }
        }
    } failure:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error.description);
        }
    }];
}

+ (void)enterRoomWithUserName:(NSString *)userName roomName:(NSString *)roomName sceneType:(SceneType)sceneType successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {

    NSString *url = [NSString stringWithFormat:HTTP_ENTER_ROOM, HTTP_BASE_URL, EduConfigModel.shareInstance.appId];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userName"] = userName;
    params[@"roomName"] = roomName;
    params[@"type"] = @(sceneType);
    // student
    params[@"role"] = @(2);
    
#warning userUuid：If you have your own user system, you need to align with the user system of our back-end service. Here you need to use the unique user ID of your own user system, the same userUuid will be considered as the same user.
    params[@"userUuid"] = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
#warning roomUuid:The unique classroom identifier of the customer scheduling system, users with the same roomUuid will be assigned to the same classroom. We do not have a schedule system, so this is set to empty.
    params[@"roomUuid"] = @"";

    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"Authorization"] = [HttpManager authorization];
    [HttpManager post:url params:params headers:headers success:^(id responseObj) {
        
        EnterRoomAllModel *model = [EnterRoomAllModel yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            
            EduConfigModel.shareInstance.userToken = model.data.userToken;
            EduConfigModel.shareInstance.roomId = model.data.roomId;
                    
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil) {
                NSString *errMsg = [EduConfigModel generateHttpErrorMessageWithDescribe:NSLocalizedString(@"EnterRoomFailedText", nil) errorCode:model.code];
                failBlock(errMsg);
            }
        }
        
    } failure:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error.description);
        }
    }];
}

+ (void)sendMessageWithType:(MessageType)messageType message:(NSString *)message successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSString *url = [NSString stringWithFormat:HTTP_USER_INSTANT_MESSAGE, HTTP_BASE_URL, EduConfigModel.shareInstance.appId, EduConfigModel.shareInstance.roomId];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = @(messageType);
    params[@"message"] = message;
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = EduConfigModel.shareInstance.userToken;
    headers[@"Authorization"] = [HttpManager authorization];
    
    [HttpManager post:url params:params headers:headers success:^(id responseObj) {
        
        CommonModel *model = [CommonModel yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil) {
                NSString *errMsg = [EduConfigModel generateHttpErrorMessageWithDescribe:NSLocalizedString(@"SendMessageFailedText", nil) errorCode:model.code];
                failBlock(errMsg);
            }
        }
        
    } failure:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error.description);
        }
    }];
}

+ (void)sendCoVideoWithType:(SignalLinkState)linkState successBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    if(linkState == SignalLinkStateIdle) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:HTTP_USER_COVIDEO, HTTP_BASE_URL, EduConfigModel.shareInstance.appId, EduConfigModel.shareInstance.roomId];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = @(linkState);

    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = EduConfigModel.shareInstance.userToken;
    headers[@"Authorization"] = [HttpManager authorization];
    
    [HttpManager post:url params:params headers:headers success:^(id responseObj) {
        
        CommonModel *model = [CommonModel yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil) {
                NSString *errMsg = [EduConfigModel generateHttpErrorMessageWithDescribe:NSLocalizedString(@"UpdateCoVideoFailedText", nil) errorCode:model.code];
                failBlock(errMsg);
            }
        }
        
    } failure:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error.description);
        }
    }];
}

+ (void)leftRoomWithSuccessBolck:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    if(EduConfigModel.shareInstance.appId == nil || EduConfigModel.shareInstance.roomId == nil) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:HTTP_LEFT_ROOM, HTTP_BASE_URL, EduConfigModel.shareInstance.appId, EduConfigModel.shareInstance.roomId];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = EduConfigModel.shareInstance.userToken;
    headers[@"Authorization"] = [HttpManager authorization];
    
    [HttpManager post:url params:nil headers:headers success:^(id responseObj) {
        
        CommonModel *model = [CommonModel yy_modelWithDictionary:responseObj];
        if(model.code == 0){
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil) {
                NSString *errMsg = [EduConfigModel generateHttpErrorMessageWithDescribe:NSLocalizedString(@"LeftRoomFailedText", nil) errorCode:model.code];
                failBlock(errMsg);
            }
        }
        
    } failure:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error.description);
        }
    }];
}

- (void)updateEnableChatWithValue:(BOOL)enableChat completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enableChat"] = @(enableChat ? 1 : 0);
    
    [self updateUserInfoWithParams:params completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)updateEnableVideoWithValue:(BOOL)enableVideo completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enableVideo"] = @(enableVideo ? 1 : 0);
    
    [self updateUserInfoWithParams:params completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)updateEnableAudioWithValue:(BOOL)enableAudio completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enableAudio"] = @(enableAudio ? 1 : 0);
    [self updateUserInfoWithParams:params completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)getRoomInfoCompleteSuccessBlock:(void (^ _Nullable) (RoomInfoModel * roomInfoModel))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
 
    NSString *url = [NSString stringWithFormat:HTTP_ROOM_INFO, HTTP_BASE_URL, EduConfigModel.shareInstance.appId, EduConfigModel.shareInstance.roomId];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = EduConfigModel.shareInstance.userToken;
    headers[@"Authorization"] = [HttpManager authorization];
    
    [HttpManager get:url params:nil headers:headers success:^(id responseObj) {
        
        RoomAllModel *model = [RoomAllModel yy_modelWithDictionary:responseObj];
        if(model.code == 0) {
            
            EduConfigModel.shareInstance.uid = model.data.localUser.uid;
            EduConfigModel.shareInstance.userId = model.data.localUser.userId;
            EduConfigModel.shareInstance.channelName = model.data.room.channelName;
            
            EduConfigModel.shareInstance.rtcToken = model.data.localUser.rtcToken;
            EduConfigModel.shareInstance.rtmToken = model.data.localUser.rtmToken;
            
            if(successBlock != nil) {
                successBlock(model.data);
            }
        } else {
            if(failBlock != nil) {
                NSString *errMsg = [EduConfigModel generateHttpErrorMessageWithDescribe:NSLocalizedString(@"GetRoomInfoFailedText", nil) errorCode:model.code];
                failBlock(errMsg);
            }
        }
        
    } failure:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error.description);
        }
    }];
}

- (void)getWhiteInfoCompleteSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    [HttpManager getWhiteInfoWithUserToken:EduConfigModel.shareInstance.userToken appid:EduConfigModel.shareInstance.appId roomId:EduConfigModel.shareInstance.roomId completeSuccessBlock:^(id responseObj) {
        
        WhiteModel *model = [WhiteModel yy_modelWithDictionary:responseObj];
        if(model.code == 0) {
        
            EduConfigModel.shareInstance.boardId = model.data.boardId;
            EduConfigModel.shareInstance.boardToken = model.data.boardToken;
            
            if(successBlock != nil) {
                successBlock();
            }
        } else {
            if(failBlock != nil) {
                NSString *errMsg = [EduConfigModel generateHttpErrorMessageWithDescribe:NSLocalizedString(@"GetWhiteInfoFailedText", nil) errorCode:model.code];
                failBlock(errMsg);
            }
        }
        
    } completeFailBlock:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error.description);
        }
    }];
}

- (void)updateUserInfoWithParams:(NSDictionary*)params completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    NSString *url = [NSString stringWithFormat:HTTP_UPDATE_USER_INFO, HTTP_BASE_URL, EduConfigModel.shareInstance.appId, EduConfigModel.shareInstance.roomId, EduConfigModel.shareInstance.userId];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"token"] = EduConfigModel.shareInstance.userToken;
    headers[@"Authorization"] = [HttpManager authorization];
    
    [HttpManager post:url params:params headers:headers success:^(id responseObj) {
        
        CommonModel *model = [CommonModel yy_modelWithDictionary:responseObj];
        if(model.code == 0) {
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil) {
                NSString *errMsg = [EduConfigModel generateHttpErrorMessageWithDescribe:NSLocalizedString(@"UpdateRoomInfoFailedText", nil) errorCode:model.code];
                failBlock(errMsg);
            }
        }
        
    } failure:^(NSError *error) {
        if(failBlock != nil) {
            failBlock(error.description);
        }
    }];
}

@end
