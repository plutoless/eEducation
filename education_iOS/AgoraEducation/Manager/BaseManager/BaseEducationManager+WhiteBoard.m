//
//  BaseEducationManager+WhiteBoard.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager+WhiteBoard.h"

@implementation BaseEducationManager (WhiteBoard)

- (void)initWhiteSDK:(WhiteBoardView *)boardView dataSourceDelegate:(id<WhitePlayDelegate> _Nullable)whitePlayerDelegate {
    
    AgoraLogInfo(@"init whiteSDK");
    
    self.whitePlayerDelegate = whitePlayerDelegate;
    
    self.whiteManager = [[WhiteManager alloc] init];
    self.whiteManager.whiteManagerDelegate = self;
    [self.whiteManager initWhiteSDKWithBoardView:boardView config:[WhiteSdkConfiguration defaultConfig]];
}

- (void)joinWhiteRoomWithBoardId:(NSString*)boardId boardToken:(NSString*)boardToken whiteWriteModel:(BOOL)isWritable  completeSuccessBlock:(void (^) (WhiteRoom * _Nullable room))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock {
    
    AgoraLogInfo(@"join whiteRoom boardId:%@ boardToken:%@", boardId, boardToken);
    
    WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:boardId roomToken:boardToken];
    roomConfig.isWritable = isWritable;

    [self.whiteManager joinWhiteRoomWithWhiteRoomConfig:roomConfig completeSuccessBlock:^(WhiteRoom * _Nullable room) {
        AgoraLogInfo(@"join whiteRoom success");
        if(successBlock != nil){
            successBlock(room);
        }
        
    } completeFailBlock:^(NSError * _Nullable error) {
        AgoraLogInfo(@"join whiteRoom fail:%@", error);
        if(failBlock != nil){
            failBlock(error);
        }
    }];
}


- (void)disableCameraTransform:(BOOL)disableCameraTransform {
    AgoraLogInfo(@"disable cameraTransform disableCameraTransform:%d", disableCameraTransform);
    [self.whiteManager disableCameraTransform:disableCameraTransform];
}

- (void)disableWhiteDeviceInputs:(BOOL)disable {
    AgoraLogInfo(@"disable whiteDeviceInputs disable:%d", disable);
    [self.whiteManager disableDeviceInputs:disable];
}

- (void)setWhiteStrokeColor:(NSArray<NSNumber *>*)strokeColor {
    AgoraLogInfo(@"set whiteStrokeColor");
    self.whiteManager.whiteMemberState.strokeColor = strokeColor;
    [self.whiteManager setMemberState:self.whiteManager.whiteMemberState];
}

- (void)setWhiteApplianceName:(NSString *)applianceName {
    AgoraLogInfo(@"set whiteApplianceName");
    self.whiteManager.whiteMemberState.currentApplianceName = applianceName;
    [self.whiteManager setMemberState:self.whiteManager.whiteMemberState];
}

- (void)setWhiteMemberInput:(nonnull WhiteMemberState *)memberState {
    AgoraLogInfo(@"set whiteMemberInput");
    [self.whiteManager setMemberState:memberState];
}
- (void)refreshWhiteViewSize {
    AgoraLogInfo(@"refresh whiteViewSize");
    [self.whiteManager refreshViewSize];
}
- (void)moveWhiteToContainer:(NSInteger)sceneIndex {
    AgoraLogInfo(@"move whiteToContainer sceneIndex:%ld", (long)sceneIndex);
    WhiteSceneState *sceneState = self.whiteManager.room.sceneState;
    NSArray<WhiteScene *> *scenes = sceneState.scenes;
    WhiteScene *scene = scenes[sceneIndex];
    if (scene.ppt) {
        CGSize size = CGSizeMake(scene.ppt.width, scene.ppt.height);
        [self.whiteManager moveCameraToContainer:size];
    }
}

- (void)setWhiteSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler {
    AgoraLogInfo(@"set whiteScene");
    [self.whiteManager setSceneIndex:index completionHandler:completionHandler];
}

- (void)currentWhiteScene:(void (^)(NSInteger sceneCount, NSInteger sceneIndex))completionBlock {
    AgoraLogInfo(@"get current whiteScene");
    WhiteSceneState *sceneState = self.whiteManager.room.sceneState;
    NSArray<WhiteScene *> *scenes = sceneState.scenes;
    NSInteger sceneIndex = sceneState.index;
    if(completionBlock != nil){
        completionBlock(scenes.count, sceneIndex);
    }
}

- (void)releaseWhiteResources {
    AgoraLogInfo(@"releaseWhiteResources");
    [self.whiteManager releaseResources];
}

#pragma mark WhiteManagerDelegate
- (void)phaseChanged:(WhitePlayerPhase)phase {
    
    AgoraLogInfo(@"phaseChanged:%ld", (long)phase);
    if(phase == WhitePlayerPhaseWaitingFirstFrame || phase == WhitePlayerPhaseBuffering){
        if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerStartBuffering)]) {
            [self.whitePlayerDelegate whitePlayerStartBuffering];
        }
    } else if (phase == WhitePlayerPhasePlaying || phase == WhitePlayerPhasePause) {
        if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerEndBuffering)]) {
            [self.whitePlayerDelegate whitePlayerEndBuffering];
        }
    } else if(phase == WhitePlayerPhaseEnded) {
        if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerDidFinish)]) {
            [self.whitePlayerDelegate whitePlayerDidFinish];
        }
    }
}

- (void)stoppedWithError:(NSError *)error {
    
    AgoraLogInfo(@"stoppedWithError:%@", error);
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerError:)]) {
        [self.whitePlayerDelegate whitePlayerError: error];
    }
}

- (void)scheduleTimeChanged:(NSTimeInterval)time {
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerTimeChanged:)]) {
        [self.whitePlayerDelegate whitePlayerTimeChanged: time];
    }
}

/**
The RoomState property in the room will trigger this callback when it changes.
*/
- (void)fireRoomStateChanged:(WhiteRoomState *_Nullable)modifyState {
    if (modifyState.sceneState) {
        if([self.whitePlayerDelegate respondsToSelector:@selector(whiteRoomStateChanged)]) {
            [self.whitePlayerDelegate whiteRoomStateChanged];
        }
    }
}

@end
