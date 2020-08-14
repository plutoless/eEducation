//
//  MinEducationManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/31.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BigEducationManager.h"
#import "JsonParseUtil.h"

@interface BigEducationManager()


@end

@implementation BigEducationManager

- (instancetype)init {
    if(self = [super init]) {
        self.rtcVideoSessionModels = [NSMutableArray array];
    }
    return self;
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
        }
        
    } else if(cmd == MessageCmdTypeUserInfo) {
        
        if([self.signalDelegate respondsToSelector:@selector(didReceivedSignal:)]) {
            NSArray<UserModel*> *userModels = [SignalUserModel yy_modelWithDictionary:dict].data;
            
            SignalInfoModel *signalInfoModel = [SignalInfoModel new];
            
            UserModel *originalTeacherModel = self.teacherModel;
            UserModel *originalStudentModel = self.studentModel;
            UserModel *originalRenderModel = self.renderStudentModel;
            
            UserModel *currentTeacherModel;
            UserModel *currentStudentModel = self.studentModel;
            UserModel *currentRenderModel;
            for(UserModel *userModel in userModels) {
                if(userModel.role == UserRoleTypeTeacher) {
                    currentTeacherModel = userModel;
                } else if(userModel.role == UserRoleTypeStudent) {
                    currentRenderModel = userModel;
                    if(userModel.uid == originalStudentModel.uid) {
                        currentStudentModel = userModel;
                    }
                }
            }
            
            // co
            if ((originalTeacherModel == nil && currentTeacherModel != nil)
                || (originalTeacherModel != nil && currentTeacherModel == nil)) {
                self.teacherModel = currentTeacherModel.yy_modelCopy;
                originalTeacherModel = self.teacherModel;
                
                signalInfoModel.signalType = SignalValueCoVideo;
                signalInfoModel.uid = originalTeacherModel.uid;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            }
            if ((originalRenderModel == nil && currentRenderModel != nil)
                || (originalRenderModel != nil && currentRenderModel == nil)) {
                
                if(currentRenderModel == nil) {
                    signalInfoModel.signalType = SignalValueCoVideo;
                    signalInfoModel.uid = originalRenderModel.uid;
                } else {
                    signalInfoModel.signalType = SignalValueCoVideo;
                    signalInfoModel.uid = currentRenderModel.uid;
                }
                self.renderStudentModel = currentRenderModel.yy_modelCopy;
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
            
            // stu mute & unmute
            if (originalRenderModel.enableAudio != currentRenderModel.enableAudio) {
                originalRenderModel.enableAudio = currentRenderModel.enableAudio;
                if(originalStudentModel.uid == originalRenderModel.uid){
                    currentStudentModel.enableAudio = originalRenderModel.enableAudio;
                }
                
                signalInfoModel.signalType = SignalValueAudio;
                signalInfoModel.uid = originalStudentModel.uid;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            }
            if (originalRenderModel.enableVideo != currentRenderModel.enableVideo) {
                originalRenderModel.enableVideo = currentRenderModel.enableVideo;
                if(originalStudentModel.uid == originalRenderModel.uid){
                    currentStudentModel.enableVideo = originalRenderModel.enableVideo;
                }
                
                signalInfoModel.signalType = SignalValueVideo;
                signalInfoModel.uid = originalStudentModel.uid;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
            }

            // chat & unchat
            if (originalStudentModel.enableChat != currentStudentModel.enableChat) {
                originalStudentModel.enableChat = currentStudentModel.enableChat;
                if(originalStudentModel.uid == originalRenderModel.uid){
                    originalRenderModel.enableChat = currentStudentModel.enableChat;
                }
                
                signalInfoModel.signalType = SignalValueChat;
                signalInfoModel.uid = originalStudentModel.uid;
                [self.signalDelegate didReceivedSignal:signalInfoModel];
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

        weakself.roomModel = roomInfoModel.room;
        weakself.studentModel = roomInfoModel.localUser;
        
        if(weakself.roomModel != nil && weakself.roomModel.coVideoUsers != nil) {
            for(UserModel *userModel in weakself.roomModel.coVideoUsers) {
               if(userModel.role == UserRoleTypeTeacher) {
                   weakself.teacherModel = userModel;
               } else if(userModel.role == UserRoleTypeStudent) {
                   weakself.renderStudentModel = userModel;
               }
            }
        }

        if(successBlock != nil) {
            successBlock(roomInfoModel);
        }
    } completeFailBlock:failBlock];
}
- (void)updateEnableChatWithValue:(BOOL)enableChat completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super updateEnableChatWithValue:enableChat completeSuccessBlock:^{
        weakself.studentModel.enableChat = enableChat;
        if(weakself.renderStudentModel.uid == weakself.studentModel.uid){
            weakself.renderStudentModel.enableChat = enableChat;
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
        weakself.renderStudentModel.enableVideo = enableVideo;
        
        if(successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:failBlock];
}
- (void)updateEnableAudioWithValue:(BOOL)enableAudio completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSString *errMessage))failBlock {
    
    WEAK(self);
    [super updateEnableAudioWithValue:enableAudio completeSuccessBlock:^{
        weakself.studentModel.enableAudio = enableAudio;
        weakself.renderStudentModel.enableAudio = enableAudio;

        if(successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:failBlock];
}

#pragma mark RTC
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
