//
//  MCSegmentedView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MCSegmentedView.h"
#import "UIView+EEBadge.h"

@interface MCSegmentedView ()
@property (nonatomic, copy) NSArray *items;
@end
@implementation MCSegmentedView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.items = [NSArray arrayWithObjects:NSLocalizedString(@"ChatroomText", nil), NSLocalizedString(@"StudentText", nil), nil];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView *bottomLineView = [[UIView alloc] init];
    bottomLineView.backgroundColor = [UIColor colorWithHex:0xDBE2E5];
    [self addSubview:bottomLineView];
    bottomLineView.frame = CGRectMake(0, 39, self.bounds.size.width, 1);

//    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
//    self.layer.shadowColor = [UIColor colorWithHexString:@"000000" alpha:0.15].CGColor;
//    self.layer.shadowOffset = CGSizeMake(0,2);
//    self.layer.shadowOpacity = 2;
//    self.layer.shadowRadius = 4;
    for (NSInteger i = 0; i < self.items.count; i++) {
        UIButton *itemButton = [[UIButton alloc] init];
        [itemButton setTitle:self.items[i] forState:(UIControlStateNormal)];
        [itemButton setFrame:CGRectMake(i * self.bounds.size.width / 2, 0, self.bounds.size.width/2, self.frame.size.height)];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((i * self.bounds.size.width / 2) + 14, 38, self.bounds.size.width/2 - 28, 3.f)];
        lineView.backgroundColor = [UIColor colorWithHexString:@"44A2FC"];
        [self addSubview:lineView];
        lineView.tag = i + 100;
        itemButton.tag = i + 1000;
        if (i == 0) {
            [itemButton setSelected:YES];
        }else {
            lineView.hidden = YES;
        }
        [self setSelectedButton:itemButton];
        [self addSubview:itemButton];
        [itemButton addTarget:self action:@selector(selectItem:) forControlEvents:(UIControlEventTouchUpInside)];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)selectItem:(UIButton *)sender {
    for (NSInteger i = 0; i < self.items.count; i++) {
        UIView *lineView = (UIView *)[self viewWithTag:i+100];
        if ((sender.tag - 1000) == i) {
            [sender setSelected:YES];
            [self setSelectedButton:sender];
            lineView.hidden = NO;
        }else {
            UIButton *tempButton = (UIButton *)[self viewWithTag:i+1000];
            [tempButton setSelected:NO];
            [self setSelectedButton:tempButton];
            lineView.hidden = YES;
        }
    }
    if (self.selectIndex) {
        self.selectIndex(sender.tag - 1000);
    }
}

- (void)setSelectedButton:(UIButton *)button {
    if (button.selected) {
        [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16.f]];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16.f weight:(UIFontWeightMedium)]];
        [button setTitleColor:[UIColor colorWithHexString:@"44A2FC"] forState:(UIControlStateNormal)];
    }else {
        [button.titleLabel setFont:[UIFont systemFontOfSize:16.f weight:(UIFontWeightRegular)]];
        [button setTitleColor:[UIColor colorWithHexString:@"666666"] forState:(UIControlStateNormal)];
    }
}

- (void)showBadgeWithCount:(NSInteger)count {
    UIButton *tempButton = (UIButton *)[self viewWithTag:1001];
    [tempButton.titleLabel showBadgeWithTopMagin:0];
    [tempButton.titleLabel setBadgeCount:count];

}
- (void)hiddeBadge {
    UIButton *tempButton = (UIButton *)[self viewWithTag:1001];
    [tempButton.titleLabel hidenBadge];
}
@end
