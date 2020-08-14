//
//  BaseEducationManager+WhiteBoard.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager.h"
#import "WhiteManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseEducationManager (WhiteBoard)<WhiteManagerDelegate>

- (void)initWhiteSDK:(WhiteBoardView *)boardView dataSourceDelegate:(id<WhitePlayDelegate> _Nullable)whitePlayerDelegate;
- (void)joinWhiteRoomWithBoardId:(NSString*)boardId boardToken:(NSString*)boardToken whiteWriteModel:(BOOL)isWritable  completeSuccessBlock:(void (^) (WhiteRoom * _Nullable room))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;

- (void)disableCameraTransform:(BOOL)disableCameraTransform;
- (void)disableWhiteDeviceInputs:(BOOL)disable;

- (void)setWhiteStrokeColor:(NSArray<NSNumber *>*)strokeColor;
- (void)setWhiteApplianceName:(NSString *)applianceName;

- (void)refreshWhiteViewSize;
- (void)moveWhiteToContainer:(NSInteger)sceneIndex;

- (void)setWhiteSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler;
- (void)currentWhiteScene:(void (^)(NSInteger sceneCount, NSInteger sceneIndex))completionBlock;

- (void)releaseWhiteResources;

@end

NS_ASSUME_NONNULL_END
