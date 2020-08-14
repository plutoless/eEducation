//
//  EEColorShowView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/1.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EEColorShowView.h"
#import "EEColorViewCell.h"

@interface EEColorShowView ()
@property (nonatomic,strong) NSMutableArray *colorArray;

@property (nonatomic, weak) EEColorViewCell *temCell;
@property (weak, nonatomic) IBOutlet UILabel *pickerLabel;
@end

@implementation EEColorShowView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.colorShowView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.colorArray = [NSMutableArray arrayWithObjects:@"FF0D19",@"FF8F00",@"FFCA00",@"00DD52",@"007CFF",@"C455DF",@"FFFFFF",@"EEEEEE",@"CCCCCC",@"666666",@"333333",@"000000", nil];
    self.colorShowView.frame =self.bounds;
    self.colorShowView.layer.borderWidth = 1.f;
    self.colorShowView.layer.borderColor = [UIColor colorWithRed:219/255.0 green:226/255.0 blue:229/255.0 alpha:1.0].CGColor;

    self.colorShowView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    self.colorShowView.layer.cornerRadius = 6;
    self.colorShowView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    self.colorShowView.layer.shadowOffset = CGSizeMake(0,2);
    self.colorShowView.layer.shadowOpacity = 2;
    self.colorShowView.layer.shadowRadius = 4;
    self.colorCollectionView.delegate = self;
    self.colorCollectionView.dataSource =self;
    [self.colorCollectionView registerClass:[EEColorViewCell class] forCellWithReuseIdentifier:@"ColorCell"];
    
    self.pickerLabel.text = NSLocalizedString(@"ColorPickerText", nil);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colorArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EEColorViewCell *Cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell" forIndexPath:indexPath];
    Cell.outColorView.hidden = YES;
    Cell.colorView.backgroundColor = [UIColor colorWithHexString:self.colorArray[indexPath.row]];
    return Cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    EEColorViewCell *cell = (EEColorViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.temCell) {
        self.temCell.outColorView.hidden = YES;
    }
    cell.outColorView.hidden = NO;
    self.temCell = cell;
    if (self.selectColor) {
        self.selectColor(self.colorArray[indexPath.row]);
    }
}
@end
