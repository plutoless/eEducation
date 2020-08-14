//
//  SignalManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/6.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "SignalManager.h"

@interface SignalManager()<AgoraRtmDelegate, AgoraRtmChannelDelegate>

@property (nonatomic, strong) AgoraRtmKit *agoraRtmKit;
@property (nonatomic, strong) AgoraRtmChannel *agoraRtmChannel;

@end

@implementation SignalManager

- (void)initWithMessageModel:(SignalModel*)model completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {

    self.agoraRtmKit = [[AgoraRtmKit alloc] initWithAppId:model.appId delegate:self];
    NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/AgoraEducation/agoraRTM.log"];
    [self.agoraRtmKit setLogFile:logFilePath];
    [self.agoraRtmKit setLogFileSize:512];
    [self.agoraRtmKit setLogFilters:AgoraRtmLogFilterInfo];
    [self.agoraRtmKit loginByToken:model.token user:model.uid completion:^(AgoraRtmLoginErrorCode errorCode) {
        if (errorCode == AgoraRtmLoginErrorOk) {
            AgoraLogInfo(@"rtm login success");
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil){
                failBlock(errorCode);
            }
        }
    }];
}

- (void)joinChannelWithName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (NSInteger errorCode))failBlock {
    
    self.channelName = channelName;
    
    self.agoraRtmChannel = [self.agoraRtmKit createChannelWithId:channelName delegate:self];
    [self.agoraRtmChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
        
        if(errorCode == AgoraRtmJoinChannelErrorOk || errorCode == AgoraRtmJoinChannelErrorAlreadyJoined){
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil){
                failBlock(errorCode);
            }
        }
    }];
}

- (void)getChannelAllAttributes:(NSString *)channelName completeBlock:(void (^) (NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes))block {
    
    [self.agoraRtmKit getChannelAllAttributes:channelName completion:^(NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes, AgoraRtmProcessAttributeErrorCode errorCode) {
        
        if (errorCode == AgoraRtmAttributeOperationErrorOk) {
            
            if(block != nil){
                block(attributes);
                return;
            }
            
        } else {
            AgoraLogError(@"SignalManager get channel attributes error");
        }
        
        if(block != nil){
            block(nil);
        }
    }];
}

- (void)updateChannelAttributesWithChannelName:(NSString *)channelName channelAttribute:(AgoraRtmChannelAttribute *)attribute completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (void))failBlock {

    AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
    options.enableNotificationToChannelMembers = YES;
    NSArray *attrArray = [NSArray arrayWithObjects:attribute, nil];
    
    [self.agoraRtmKit addOrUpdateChannel:channelName Attributes:attrArray Options:options completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
        if (errorCode == AgoraRtmAttributeOperationErrorOk) {

            if(successBlock != nil){
                successBlock();
            }
        } else {
            
            if(failBlock != nil){
                failBlock();
            }
        }
    }];
}

- (void)queryPeersOnlineStatus:(NSArray<NSString*> *_Nonnull)peerIds completion:(AgoraRtmQueryPeersOnlineBlock _Nullable)completionBlock {

    [self.agoraRtmKit queryPeersOnlineStatus:peerIds completion:completionBlock];
}

- (void)sendMessage:(NSString *)value completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (NSInteger errorCode))failBlock {

    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:value];
    [self.agoraRtmChannel sendMessage:rtmMessage completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
        
        if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
            
            if(successBlock != nil){
                successBlock();
            }
            
        } else {
            if(failBlock != nil){
                failBlock(errorCode);
            }
        }
    }];
}

- (void)sendMessage:(NSString *)value toPeer:(NSString *)peerId completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (NSInteger errorCode))failBlock {
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:value];
    [self.agoraRtmKit sendMessage:rtmMessage toPeer:peerId completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendPeerMessageErrorOk) {
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil){
                failBlock(errorCode);
            }
        }
    }];
    
}

-(void)releaseResources {

    if(self.channelName != nil){
        AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
        options.enableNotificationToChannelMembers = YES;
        [self.agoraRtmKit deleteChannel:self.channelName AttributesByKeys:@[self.messageModel.uid] Options:options completion:nil];
        
        [self.agoraRtmChannel leaveWithCompletion:nil];
        self.channelName = nil;
    }
    
    [self.agoraRtmKit logoutWithCompletion:nil];
}

- (void)dealloc {
    self.agoraRtmKit = nil;
    [self releaseResources];
}

#pragma mark AgoraRtmDelegate
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {

    if([self.rtmDelegate respondsToSelector:@selector(rtmKit:connectionStateChanged:reason:)]){
        [self.rtmDelegate rtmKit:kit connectionStateChanged:state reason:reason];
    }
}

#pragma mark AgoraRtmChannelDelegate
- (void)rtmKit:(AgoraRtmKit *)kit messageReceived:(AgoraRtmMessage *)message fromPeer:(NSString *)peerId {
    
    if([self.rtmDelegate respondsToSelector:@selector(rtmKit:messageReceived:fromPeer:)]){
        [self.rtmDelegate rtmKit:kit messageReceived:message fromPeer:peerId];
    }
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {
    
    if([self.rtmDelegate respondsToSelector:@selector(channel:messageReceived:fromMember:)]){
        [self.rtmDelegate channel:channel messageReceived:message fromMember:member];
    }
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel attributeUpdate:(NSArray< AgoraRtmChannelAttribute *> * _Nonnull)attributes {

    if([self.rtmDelegate respondsToSelector:@selector(channel:attributeUpdate:)]){
        [self.rtmDelegate channel:channel attributeUpdate:attributes];
    }
}

@end
