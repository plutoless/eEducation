//
//  SettingViewCell.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/18.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingCellDelegate <NSObject>
- (void)settingSwitchCallBack:(UISwitch *_Nullable)sender;
@end


NS_ASSUME_NONNULL_BEGIN

@interface SettingViewCell : UITableViewCell
@property (nonatomic, weak) id <SettingCellDelegate> delegate;
- (void)switchOn:(BOOL)on;
@end

NS_ASSUME_NONNULL_END
