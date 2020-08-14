//
//  RoomProtocol.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RoomProtocol <NSObject>
@optional
- (void)muteVideoStream:(BOOL)stream;
- (void)muteAudioStream:(BOOL)stream;
- (void)closeRoom;
@end

NS_ASSUME_NONNULL_END
