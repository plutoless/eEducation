//
//  EEWhiteboardTool.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EEWhiteboardToolDelegate <NSObject>
- (void)selectWhiteboardToolIndex:(NSInteger)index;
@end
NS_ASSUME_NONNULL_BEGIN

@interface EEWhiteboardTool : UIView
@property (weak, nonatomic) UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (strong, nonatomic) IBOutlet UIView *whiteboardTool;
@property (nonatomic, weak) id <EEWhiteboardToolDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
