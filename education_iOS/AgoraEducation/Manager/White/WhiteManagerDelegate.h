//
//  WhiteManagerDelegate.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Whiteboard/Whiteboard.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WhiteManagerDelegate <NSObject>

@optional
/**
 Playback status switching callback
 */
- (void)phaseChanged:(WhitePlayerPhase)phase;

/**
 Pause on error
 */
- (void)stoppedWithError:(NSError * _Nullable)error;

/**
 Progress time change
 */
- (void)scheduleTimeChanged:(NSTimeInterval)time;

/**
The RoomState property in the room will trigger this callback when it changes.
*/
- (void)fireRoomStateChanged:(WhiteRoomState *_Nullable)modifyState;
@end

NS_ASSUME_NONNULL_END
