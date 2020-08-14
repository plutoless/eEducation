//
//  MCStudentVideoListView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/14.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomAllModel.h"
#import "MCStudentVideoCell.h"

typedef void(^ StudentVideoList)(MCStudentVideoCell * _Nonnull cell, NSInteger currentUid);

NS_ASSUME_NONNULL_BEGIN

@interface MCStudentVideoListView : UIView
@property (nonatomic, strong) StudentVideoList studentVideoList;
- (void)updateStudentArray:(NSArray<UserModel*> *)array;
@end

NS_ASSUME_NONNULL_END
