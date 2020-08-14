//
//  WhiteManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/18.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "WhiteManager.h"

@interface WhiteManager()<WhiteCommonCallbackDelegate, WhiteRoomCallbackDelegate, WhitePlayerEventDelegate>

@end

@implementation WhiteManager

- (void)initWhiteSDKWithBoardView:(WhiteBoardView *)boardView config:(WhiteSdkConfiguration *)config {
    self.whiteSDK = [[WhiteSDK alloc] initWithWhiteBoardView: boardView config:config commonCallbackDelegate:self];
}

- (void)joinWhiteRoomWithWhiteRoomConfig:(WhiteRoomConfig*)roomConfig completeSuccessBlock:(void (^) (WhiteRoom * _Nullable room))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock {
    
    WEAK(self);
    [self.whiteSDK joinRoomWithConfig:roomConfig callbacks:self completionHandler:^(BOOL success, WhiteRoom * _Nullable room, NSError * _Nullable error) {
        
        if(success) {
            weakself.room = room;
            weakself.whiteMemberState = [WhiteMemberState new];
            [weakself.room setMemberState:weakself.whiteMemberState];
            
            if(successBlock != nil){
                successBlock(room);
            }
        } else {
            if(failBlock != nil){
                failBlock(error);
            }
        }
    }];
}

- (void)disableCameraTransform:(BOOL)disableCameraTransform {
    [self.room disableCameraTransform:disableCameraTransform];
}

- (void)disableDeviceInputs:(BOOL)disable {
    [self.room disableDeviceInputs:disable];
}

- (void)setMemberState:(nonnull WhiteMemberState *)memberState {
    [self.room setMemberState: memberState];
}

- (void)refreshViewSize {
    [self.room refreshViewSize];
}

- (void)moveCameraToContainer:(CGSize)size {
    WhiteRectangleConfig *config = [[WhiteRectangleConfig alloc] initWithInitialPosition:size.width height:size.height];
    [self.room moveCameraToContainer:config];
}

- (void)setSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler {
    [self.room setSceneIndex:index completionHandler:completionHandler];
}

- (void)releaseResources {
    
    if(self.room != nil) {
        [self.room disconnect:nil];
    }

    self.room = nil;
    self.whiteSDK = nil;
}

- (void)dealloc {
    [self releaseResources];
}

#pragma mark WhitePlayerEventDelegate
/**
Playback status switching callback
*/
- (void)phaseChanged:(WhitePlayerPhase)phase {
    if([self.whiteManagerDelegate respondsToSelector:@selector(phaseChanged:)]) {
        [self.whiteManagerDelegate phaseChanged: phase];
    }
}

/**
Pause on error
*/
- (void)stoppedWithError:(NSError *)error {
    if([self.whiteManagerDelegate respondsToSelector:@selector(stoppedWithError:)]) {
        [self.whiteManagerDelegate stoppedWithError: error];
    }
}
/**
Progress time change
*/
- (void)scheduleTimeChanged:(NSTimeInterval)time {
    if([self.whiteManagerDelegate respondsToSelector:@selector(scheduleTimeChanged:)]) {
        [self.whiteManagerDelegate scheduleTimeChanged: time];
    }
}

#pragma mark WhiteRoomCallbackDelegate
/**
The RoomState property in the room will trigger this callback when it changes.
*/
- (void)fireRoomStateChanged:(WhiteRoomState *)modifyState {
    if([self.whiteManagerDelegate respondsToSelector:@selector(fireRoomStateChanged:)]) {
        [self.whiteManagerDelegate fireRoomStateChanged: modifyState];
    }
}

@end
