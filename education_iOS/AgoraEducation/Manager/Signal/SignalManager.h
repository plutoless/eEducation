//
//  SignalManager.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/6.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtmKit/AgoraRtmKit.h>
#import "SignalManagerDelegate.h"
#import "SignalModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SignalManager : NSObject

@property (nonatomic, weak) id<SignalManagerDelegate> _Nullable rtmDelegate;
@property (nonatomic, strong) SignalModel * _Nullable messageModel;
@property (nonatomic, strong) NSString * _Nullable channelName;

- (void)initWithMessageModel:(SignalModel*)model completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock;
- (void)joinChannelWithName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock;

- (void)getChannelAllAttributes:(NSString *)channelName completeBlock:(void (^) (NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes))block;
- (void)updateChannelAttributesWithChannelName:(NSString *)channelName channelAttribute:(AgoraRtmChannelAttribute *)attribute completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (void))failBlock;

- (void)queryPeersOnlineStatus:(NSArray<NSString*> *_Nonnull)peerIds completion:(AgoraRtmQueryPeersOnlineBlock _Nullable)completionBlock;

- (void)sendMessage:(NSString *)value completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (NSInteger errorCode))failBlock;
- (void)sendMessage:(NSString *)value toPeer:(NSString *)peerId completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (NSInteger errorCode))failBlock;

- (void)releaseResources;

@end

NS_ASSUME_NONNULL_END
