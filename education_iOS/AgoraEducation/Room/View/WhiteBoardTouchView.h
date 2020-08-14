//
//  WhiteBoardTouchView.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/20.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WhiteBoardTouchView : UIView

- (void)setupInView:(UIView *)superView onTouchBlock:(void (^ _Nullable) (void))touchBlock;

@end

NS_ASSUME_NONNULL_END
