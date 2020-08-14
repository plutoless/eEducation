//
//  EEStudentVideoView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCStudentVideoView : UIView
@property (weak, nonatomic) id<RoomProtocol> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;
@property (weak, nonatomic) IBOutlet UIView *studentRenderView;
- (void)setButtonEnabled:(BOOL)enabled;
- (void)updateVideoImageWithMuted:(BOOL)muted;
- (void)updateAudioImageWithMuted:(BOOL)muted;
@end

NS_ASSUME_NONNULL_END
