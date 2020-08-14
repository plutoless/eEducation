//
//  BaseEducationManager+Signal.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/29.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseEducationManager+Signal.h"
#import "SignalModel.h"
#import "JsonParseUtil.h"

@implementation BaseEducationManager (Signal)

- (void)initSignalWithAppid:(NSString *)appid appToken:(NSString *)token userId:(NSString *)uid dataSourceDelegate:(id<SignalDelegate> _Nullable)signalDelegate completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    
    AgoraLogInfo(@"init signal appid:%@ token:%@ uid:%@", appid, token, uid);
    
    self.signalDelegate = signalDelegate;
    
    SignalModel *model = [SignalModel new];
    model.appId = appid;
    model.token = token;
    model.uid = uid;

    self.signalManager = [[SignalManager alloc] init];
    self.signalManager.rtmDelegate = self;
    self.signalManager.messageModel = model;
    [self.signalManager initWithMessageModel:model completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)joinSignalWithChannelName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    AgoraLogInfo(@"join signal channelName:%@", channelName);
    [self.signalManager joinChannelWithName:channelName completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)handleRTMMessage:(NSString *)messageText {
    NSAssert(1 == 0, @"subclass must overwrite handleRTMMessage");
}

- (void)releaseSignalResources {
    AgoraLogInfo(@"releaseSignalResources");
    [self.signalManager releaseResources];
}

#pragma mark SignalManagerDelegate
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    
    AgoraLogInfo(@"connectionStateChanged state:%ld reason:%d", (long)state, reason);
    
    if([self.signalDelegate respondsToSelector:@selector(didReceivedConnectionStateChanged:)]) {
        [self.signalDelegate didReceivedConnectionStateChanged:state];
    }
}

- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId {
    
    AgoraLogInfo(@"messageReceived:%@ fromPeer:%@", message.text, peerId);
    
    NSDictionary *dict = [JsonParseUtil dictionaryWithJsonString:message.text];
    SignalP2PInfoModel *model = [SignalP2PModel yy_modelWithDictionary:dict].data;

    if([self.signalDelegate respondsToSelector:@selector(didReceivedPeerSignal:)]) {
        [self.signalDelegate didReceivedPeerSignal:model];
    }
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {

    AgoraLogInfo(@"messageReceived:%@", message.text);
    [self handleRTMMessage:message.text];
}

@end
