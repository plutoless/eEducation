//
//  MCTeacherVideoView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCTeacherVideoView : UIView
@property (weak, nonatomic) IBOutlet UIView *videoRenderView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;
- (void)updateUserName:(NSString *)userName;
- (void)updateSpeakerImageName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
