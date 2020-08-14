//
//  MCStudentListView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomProtocol.h"
#import "RoomAllModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCStudentListView : UIView
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, weak)id<RoomProtocol> delegate;
- (void)updateStudentArray:(NSArray<UserModel*> *)array;
@end

NS_ASSUME_NONNULL_END
