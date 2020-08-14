//
//  EERemoteVideoView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EETeacherVideoView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;
@property (weak, nonatomic) IBOutlet UIView *teacherRenderView;
- (void)updateAndsetTeacherName:(NSString * _Nullable)name;
- (void)updateSpeakerImageWithMuted:(BOOL)muted;
@end

NS_ASSUME_NONNULL_END
