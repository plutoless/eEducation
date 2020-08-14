//
//  MinEducationManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/31.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MinEducationManager.h"
#import "JsonParseUtil.h"
#import "NSArray+Copy.h"

@interface MinEducationManager()

@end

@implementation MinEducationManager

- (instancetype)init {
    if(self = [super init]) {
        self.rtcVideoSessionModels = [NSMutableArray array];
        self.studentTotleListArray = [NSArray array];
    }
    return self;
}

- (void)addObserver:(UserModel *)model {
    [model addObserver:self forKeyPath:@"price" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

- (void)compareUserModelsFrom:(NSArray<UserModel *>*)fromArray to:(NSArray<UserModel *>*)toArray {
    
    SignalInfoModel *signalInfoModel = [SignalInfoModel new];
    
    NSPredicate *filterPredicate1 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", toArray];
    NSArray *filter1 = [fromArray filteredArrayUsingPredicate:filterPredicate1];
    
    for(UserModel *changedModel in filter1) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", changedModel.uid];
        NSArray<UserModel *> *filteredArray = [toArray filteredArrayUsingPredicate:predicate];
        if(filteredArray == 0) {
            // fromArray == originalStudentModels 下麦
            // fromArray == currentStudentModels 上麦
            signalInfoModel.signalType = SignalValueCoVideo;
            signalInfoModel.uid = changedModel.uid;
            [self.signalDelegate didReceivedSignal:signalInfoModel];
        } else {
            UserModel *filterUserModel = filteredArray.firstObject;
            if (filterUserModel.enableAudio != changedModel.enableAudio) {
                filterUserModel.enableAudio = changedModel.enableAudio;
                
                signalInfoModel.signalType = SignalValueAudio;
                signalInfoModel.uid = filterUserModel.uid;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            }
            if (filterUserModel.enableVideo != changedModel.enableVideo) {
                filterUserModel.enableVideo = changedModel.enableVideo;
                
                signalInfoModel.signalType = SignalValueVideo;
                signalInfoModel.uid = filterUserModel.uid;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            }
        }
    }
}

- (void)handleRTMMessage:(NSString *)messageText {
    
    NSDictionary *dict = [JsonParseUtil dictionaryWithJsonString:messageText];
    NSInteger cmd = [dict[@"cmd"] integerValue];
    
    if(cmd == MessageCmdTypeChat) {
        
        if([self.signalDelegate respondsToSelector:@selector(didReceivedMessage:)]) {
            MessageInfoModel *model = [MessageModel yy_modelWithDictionary:dict].data;
            
            if(![model.userId isEqualToString:self.studentModel.userId]) {
                model.isSelfSend = NO;
                [self.signalDelegate didReceivedMessage:model];
            }
        }
        
    } else if(cmd == MessageCmdTypeRoomInfo) {
        
        if([self.signalDelegate respondsToSelector:@selector(didReceivedSignal:)]) {
            
            SignalRoomInfoModel *model = [SignalRoomModel yy_modelWithDictionary:dict].data;
            
            SignalInfoModel *signalInfoModel = [SignalInfoModel new];
            
            RoomModel *originalModel = self.roomModel;
            if (originalModel.muteAllChat != model.muteAllChat) {
                originalModel.muteAllChat = model.muteAllChat;
                
                signalInfoModel.signalType = SignalValueAllChat;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            }
            if (originalModel.lockBoard != model.lockBoard) {
                originalModel.lockBoard = model.lockBoard;
                
                signalInfoModel.signalType = SignalValueFollow;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            }
            if (originalModel.courseState != model.courseState) {
                originalModel.courseState = model.courseState;
                originalModel.startTime = model.startTime;
                
                signalInfoModel.signalType = SignalValueCourse;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            }
        }
        
    } else if(cmd == MessageCmdTypeUserInfo) {
        
        if([self.signalDelegate respondsToSelector:@selector(didReceivedSignal:)]) {
            NSArray<UserModel*> *userModels = [SignalUserModel yy_modelWithDictionary:dict].data;
            
            SignalInfoModel *signalInfoModel = [SignalInfoModel new];
            
            UserModel *originalTeacherModel = self.teacherModel;
            UserModel *originalStudentModel = self.studentModel;
            NSMutableArray<UserModel *> *originalStudentModels = [NSMutableArray arrayWithArray:self.studentTotleListArray];
            
            UserModel *currentTeacherModel;
            UserModel *currentStudentModel;
            NSMutableArray<UserModel *> *currentStudentModels = [NSMutableArray array];
            for(UserModel *userModel in userModels) {
                if(userModel.role == UserRoleTypeTeacher) {
                    currentTeacherModel = userModel;
                } else if(userModel.role == UserRoleTypeStudent) {
                    if(userModel.uid == originalStudentModel.uid) {
                        currentStudentModel = userModel;
                    }
                    [currentStudentModels addObject:userModel];
                }
            }
            
            // tea co
            if ((originalTeacherModel == nil && currentTeacherModel != nil)
                || (originalTeacherModel != nil && currentTeacherModel == nil)) {
                self.teacherModel = currentTeacherModel.yy_modelCopy;
                originalTeacherModel = self.teacherModel;
                
                signalInfoModel.signalType = SignalValueCoVideo;
                signalInfoModel.uid = originalTeacherModel.uid;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            }
            // tea mute & unmute
            if (originalTeacherModel.enableAudio != currentTeacherModel.enableAudio) {
                originalTeacherModel.enableAudio = currentTeacherModel.enableAudio;
                
                signalInfoModel.signalType = SignalValueAudio;
                signalInfoModel.uid = originalTeacherModel.uid;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            }
            if (originalTeacherModel.enableVideo != currentTeacherModel.enableVideo) {
                originalTeacherModel.enableVideo = currentTeacherModel.enableVideo;
                
                signalInfoModel.signalType = SignalValueVideo;
                signalInfoModel.uid = originalTeacherModel.uid;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            }
            
            // board permission
            if(originalStudentModel.grantBoard != currentStudentModel.grantBoard){
                originalStudentModel.grantBoard = currentStudentModel.grantBoard;
                for (UserModel *model in self.studentTotleListArray){
                    if(model.uid == originalStudentModel.uid){
                        model.grantBoard = currentStudentModel.grantBoard;
                    }
                }
                
                signalInfoModel.signalType = SignalValueGrantBoard;
                signalInfoModel.uid = originalStudentModel.uid;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            }
            
            // chat & unchat
            if (originalStudentModel.enableChat != currentStudentModel.enableChat) {
                originalStudentModel.enableChat = currentStudentModel.enableChat;
                
                signalInfoModel.signalType = SignalValueChat;
                signalInfoModel.uid = originalStudentModel.uid;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            }
            
            // stu check
            self.studentTotleListArray = [currentStudentModels deepCopy];
            self.studentModel = currentStudentModel.yy_modelCopy;
            originalStudentModel = self.studentModel;
            [self compareUserModelsFrom:originalStudentModels to:currentStudentModels];
            [self compareUserModelsFrom:currentStudentModels to:originalStudentModels];

            if (originalStudentModels.count != currentStudentModels.count ) {
                signalInfoModel.signalType = SignalValueCoVideo;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            } else {
                // stu mute & unmute
                for(UserModel *currentModel in currentStudentModels) {
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", currentModel.uid];
                    NSArray<UserModel *> *filteredArray = [originalStudentModels filteredArrayUsingPredicate:predicate];
                    if(filteredArray == 0) {
                        signalInfoModel.signalType = SignalValueCoVideo;
                        signalInfoModel.uid = currentModel.uid;
                        [self.signalDelegate didReceivedSignal:signalInfoModel];
                    } else {
                        UserModel *filterUserModel = filteredArray.firstObject;
                        if (filterUserModel.enableAudio != currentModel.enableAudio) {
                            filterUserModel.enableAudio = currentModel.enableAudio;
                            
                            signalInfoModel.signalType = SignalValueAudio;
                            signalInfoModel.uid = filterUserModel.uid;
                            [self.signalDelegate didReceivedSignal:signalInfoModel];
                        }
                        if (filterUserModel.enableVideo != currentModel.enableVideo) {
                            filterUserModel.enableVideo = currentModel.enableVideo;
                            
                            signalInfoModel.signalType = SignalValueVideo;
                            signalInfoModel.uid = filterUserModel.uid;
                            [self.signalDelegate didReceivedSignal:signalInfoModel];
                        }
                        [originalStudentModels removeObjectsInArray:filteredArray];
                    }
                }
            }
        }
        
    } else if(cmd == MessageCmdTypeReplay) {
        
        if([self.signalDelegate respondsToSelector:@selector(didReceivedMessage:)]) {
            SignalReplayModel *model = [SignalReplayModel yy_modelWithDictionary:dict];
            
            MessageInfoModel *messageModel = [MessageInfoModel new];
            messageModel.userName = self.teacherModel.userName;
            messageModel.message = NSLocalizedString(@"ReplayRecordingText", nil);
            messageModel.recordId = model.data.recordId;
            messageModel.isSelfSend = NO;
            [self.signalDelegate didReceivedMessage:messageModel];
        }
    } else if(cmd == MessageCmdTypeShareScreen) {
        
        if([self.signalDelegate respondsToSelector:@selector(didReceivedSignal:)]) {
            self.shareScreenInfoModel = [SignalShareScreenModel yy_modelWithDictionary:dict].data;
            
            SignalInfoModel *signalInfoModel = [SignalInfoModel new];
            signalInfoModel.signalType = SignalValueShareScreen;
            [self.signalDelegate didReceivedSignal:signalInfoModel];
        }
    }
}

#pragma mark GlobalStates
- (void)getRoomInfoCompleteSuccessBlock:(void (^ _Nullable) (RoomInfoModel * roomInfoModel))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {
        
        NSMutableArray<UserModel*> *studentTotleListArray = [NSMutableArray array];
        
        weakself.roomModel = roomInfoModel.room;
        weakself.studentModel = roomInfoModel.localUser;
        
        if(weakself.roomModel != nil && weakself.roomModel.coVideoUsers != nil) {
            for(UserModel *userModel in weakself.roomModel.coVideoUsers) {
                if(userModel.role == UserRoleTypeTeacher) {
                    weakself.teacherModel = userModel;
                } else if(userModel.role == UserRoleTypeStudent) {
                    [studentTotleListArray addObject:userModel];
                }
            }
        }
        weakself.studentTotleListArray = [NSArray arrayWithArray:studentTotleListArray];
        
        if(successBlock != nil) {
            successBlock(roomInfoModel);
        }
    } completeFailBlock:failBlock];
}
- (void)updateEnableChatWithValue:(BOOL)enableChat completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super updateEnableChatWithValue:enableChat completeSuccessBlock:^{
        weakself.studentModel.enableChat = enableChat;
        for (UserModel *model in weakself.studentTotleListArray) {
            if(model.uid == weakself.studentModel.uid){
                model.enableChat = enableChat;
                break;
            }
        }
        
        if(successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:failBlock];
}
- (void)updateEnableVideoWithValue:(BOOL)enableVideo completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super updateEnableVideoWithValue:enableVideo completeSuccessBlock:^{
        weakself.studentModel.enableVideo = enableVideo;
        for (UserModel *model in weakself.studentTotleListArray) {
            if(model.uid == weakself.studentModel.uid){
                model.enableVideo = enableVideo;
                break;
            }
        }
        
        if(successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:failBlock];
}
- (void)updateEnableAudioWithValue:(BOOL)enableAudio completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super updateEnableAudioWithValue:enableAudio completeSuccessBlock:^{
        weakself.studentModel.enableAudio = enableAudio;
        for (UserModel *model in weakself.studentTotleListArray) {
            if(model.uid == weakself.studentModel.uid){
                model.enableAudio = enableAudio;
                break;
            }
        }
        
        if(successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:failBlock];
}

#pragma mark RTCManager
- (int)setRTCRemoteStreamWithUid:(NSUInteger)uid type:(RTCVideoStreamType)streamType {
    if(streamType == RTCVideoStreamTypeLow){
        return [self.rtcManager setRemoteVideoStream:uid type:AgoraVideoStreamTypeLow];
    } else if(streamType == RTCVideoStreamTypeHigh){
        return [self.rtcManager setRemoteVideoStream:uid type:AgoraVideoStreamTypeHigh];
    }
    return -1;
}

- (void)setupRTCVideoCanvas:(RTCVideoCanvasModel *)model completeBlock:(void(^ _Nullable)(AgoraRtcVideoCanvas *videoCanvas))block {

    RTCVideoSessionModel *currentSessionModel;
    RTCVideoSessionModel *removeSessionModel;
    for (RTCVideoSessionModel *videoSessionModel in self.rtcVideoSessionModels) {
        // view rerender
        if(videoSessionModel.videoCanvas.view == model.videoView){
            videoSessionModel.videoCanvas.view = nil;
            if(videoSessionModel.uid == self.signalManager.messageModel.uid.integerValue) {
                [self.rtcManager setupLocalVideo:videoSessionModel.videoCanvas];
            } else {
                [self.rtcManager setupRemoteVideo:videoSessionModel.videoCanvas];
            }
            removeSessionModel = videoSessionModel;

        } else if(videoSessionModel.uid == model.uid){
            videoSessionModel.videoCanvas.view = nil;
            if(videoSessionModel.uid == self.signalManager.messageModel.uid.integerValue) {
                [self.rtcManager setupLocalVideo:videoSessionModel.videoCanvas];
            } else {
                [self.rtcManager setupRemoteVideo:videoSessionModel.videoCanvas];
            }
            currentSessionModel = videoSessionModel;
        }
    }

    WEAK(self);
    [super setupRTCVideoCanvas:model completeBlock:^(AgoraRtcVideoCanvas *videoCanvas) {
        
        if(removeSessionModel != nil){
            AgoraLogInfo(@"VideoSessionModels remove repeat view uid:%lu", (unsigned long)removeSessionModel.uid);
            [weakself.rtcVideoSessionModels removeObject:removeSessionModel];
        }
        if(currentSessionModel != nil){
            AgoraLogInfo(@"VideoSessionModels remove repeat uid:%lu", (unsigned long)currentSessionModel.uid);
            [weakself.rtcVideoSessionModels removeObject:currentSessionModel];
        }
        
        AgoraLogInfo(@"VideoSessionModels add:%lu", (unsigned long)model.uid);
        
        RTCVideoSessionModel *videoSessionModel = [RTCVideoSessionModel new];
        videoSessionModel.uid = model.uid;
        videoSessionModel.videoCanvas = videoCanvas;
        [weakself.rtcVideoSessionModels addObject:videoSessionModel];
        
        if(block != nil){
            block(videoCanvas);
        }
    }];
}

- (void)removeRTCVideoCanvas:(NSUInteger) uid {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", uid];
    NSArray<RTCVideoSessionModel *> *filteredArray = [self.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
    if(filteredArray.count > 0) {
        RTCVideoSessionModel *model = filteredArray.firstObject;
        model.videoCanvas.view = nil;
        if(uid == self.signalManager.messageModel.uid.integerValue) {
            [self.rtcManager setupLocalVideo:model.videoCanvas];
        } else {
            [self.rtcManager setupRemoteVideo:model.videoCanvas];
        }
        [self.rtcVideoSessionModels removeObject:model];
        
        AgoraLogInfo(@"VideoSessionModels remove given uid:%lu", (unsigned long)model.uid);
    }
}

- (void)releaseResources {

    for (RTCVideoSessionModel *model in self.rtcVideoSessionModels){
        model.videoCanvas.view = nil;
        
        if(model.uid == self.signalManager.messageModel.uid.integerValue) {
            [self.rtcManager setupLocalVideo:model.videoCanvas];
        } else {
            [self.rtcManager setupRemoteVideo:model.videoCanvas];
        }
    }
    [self.rtcVideoSessionModels removeAllObjects];

    // release rtc
    [self releaseRTCResources];
    
    // release white
    [self releaseWhiteResources];
    
    // release signal
    [self releaseSignalResources];
    
    [BaseEducationManager leftRoomWithSuccessBolck:nil completeFailBlock:nil];
}

@end
