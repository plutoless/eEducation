//
//  EEMessageViewCell.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EEMessageViewCell : UITableViewCell
- (CGSize)sizeWithContent:(NSString *)string;
@property (nonatomic, copy) MessageInfoModel *messageModel;
@property (nonatomic, assign) CGFloat cellWidth;
@end

NS_ASSUME_NONNULL_END
