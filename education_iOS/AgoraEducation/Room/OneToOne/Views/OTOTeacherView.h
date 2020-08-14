//
//  OTOTeacherView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/13.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OTOTeacherView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;
@property (weak, nonatomic) IBOutlet UIView *videoRenderView;

- (void)updateSpeakerEnabled:(BOOL)enable;
- (void)updateUserName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
