//
//  EEPageControlView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  EEPageControlDelegate<NSObject>
- (void)previousPage;
- (void)nextPage;
- (void)lastPage;
- (void)firstPage;
@end

NS_ASSUME_NONNULL_BEGIN

@interface EEPageControlView : UIView
@property (strong, nonatomic) IBOutlet UIView *pageControlView;
@property (weak, nonatomic) IBOutlet UILabel *pageCountLabel;


@property (nonatomic, weak) id <EEPageControlDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
