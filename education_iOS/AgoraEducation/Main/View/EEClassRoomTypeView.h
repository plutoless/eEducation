//
//  EEClassRoomTypeView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/28.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EEClassRoomTypeDelegate <NSObject>
@optional
- (void)selectRoomTypeName:(NSString *_Nullable)name;
@end
NS_ASSUME_NONNULL_BEGIN

@interface EEClassRoomTypeView : UIView
+ (instancetype)initWithXib:(CGRect)frame;
@property (nonatomic, weak) id <EEClassRoomTypeDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
