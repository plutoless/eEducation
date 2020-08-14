//
//  WhitePlayDelegate.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WhitePlayDelegate <NSObject>

@optional

- (void)whitePlayerTimeChanged:(NSTimeInterval)time;
- (void)whitePlayerStartBuffering;
- (void)whitePlayerEndBuffering;
- (void)whitePlayerDidFinish;
- (void)whitePlayerError:(NSError * _Nullable)error;

/**
The RoomState property in the room will trigger this callback when it changes.
*/
- (void)whiteRoomStateChanged;

@end

NS_ASSUME_NONNULL_END
