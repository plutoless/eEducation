//
//  WhiteManager.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/18.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Whiteboard/Whiteboard.h>
#import "WhiteManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface WhiteManager : NSObject

@property (nonatomic, weak) id<WhiteManagerDelegate> whiteManagerDelegate;

@property (nonatomic, strong) WhiteSDK * _Nullable whiteSDK;
@property (nonatomic, strong) WhiteRoom * _Nullable room;

@property (nonatomic, strong) WhiteMemberState * _Nullable whiteMemberState;

- (void)initWhiteSDKWithBoardView:(WhiteBoardView *)boardView config:(WhiteSdkConfiguration *)config;
- (void)joinWhiteRoomWithWhiteRoomConfig:(WhiteRoomConfig*)roomConfig completeSuccessBlock:(void (^) (WhiteRoom * _Nullable room))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;

- (void)disableDeviceInputs:(BOOL)disable;
- (void)setMemberState:(nonnull WhiteMemberState *)memberState;
- (void)refreshViewSize;
- (void)moveCameraToContainer:(CGSize)size;
- (void)setSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler;

- (void)disableCameraTransform:(BOOL)disableCameraTransform;


- (void)releaseResources;

@end

NS_ASSUME_NONNULL_END
