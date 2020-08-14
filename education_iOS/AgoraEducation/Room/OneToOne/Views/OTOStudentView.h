//
//  OTOStudentView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/13.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface OTOStudentView : UIView
@property (nonatomic, weak) id <RoomProtocol> delegate;
@property (weak, nonatomic) IBOutlet UIView *videoRenderView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;

- (void)updateUserName:(NSString *)name;
- (void)updateVideoImageWithMuted:(BOOL)muted;
- (void)updateAudioImageWithMuted:(BOOL)muted;
@end

NS_ASSUME_NONNULL_END
