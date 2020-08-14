//
//  EEColorShowView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/1.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectColor)(NSString * _Nullable colorString);

NS_ASSUME_NONNULL_BEGIN

@interface EEColorShowView : UIView<UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UIView *colorShowView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *colorFlowLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *colorCollectionView;
@property (nonatomic, copy) SelectColor selectColor;


@end

NS_ASSUME_NONNULL_END
