//
//  OneToOneNavigationView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/12.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EENavigationView : UIView
@property (nonatomic, weak) id <RoomProtocol> delegate;
- (void)initTimerCount:(NSInteger)timeCount;
- (void)startTimer;
- (void)stopTimer;
- (void)updateClassName:(NSString *)name;
- (void)updateSignalImageName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
