//
//  EEClassRoomTypeView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/28.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EEClassRoomTypeView.h"


@interface EEClassRoomTypeView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *typeTableView;
@property (nonatomic, strong) NSMutableArray *roomNameArray;
@end

@implementation EEClassRoomTypeView

+ (instancetype)initWithXib:(CGRect)frame {
    EEClassRoomTypeView *classRoomTypeView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].firstObject;

    classRoomTypeView.frame = frame;
    [classRoomTypeView awakeFromNib];
    return classRoomTypeView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.roomNameArray = [NSMutableArray arrayWithObjects:NSLocalizedString(@"OneToOneText", nil), NSLocalizedString(@"SmallClassText", nil), NSLocalizedString(@"LargeClassText", nil), nil];

    [self addSubview:self.typeTableView];
    self.typeTableView.layer.borderWidth = 1.f;
    self.typeTableView.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0].CGColor;
    self.typeTableView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    self.typeTableView.layer.cornerRadius = 4;
    self.typeTableView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.15].CGColor;
    self.typeTableView.layer.shadowOffset = CGSizeMake(0,2);
    self.typeTableView.layer.shadowOpacity = 2;
    self.typeTableView.layer.shadowRadius = 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"typeCell"];
    if (!tableViewCell) {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"typeCell"];
    }
    [tableViewCell.textLabel setText:self.roomNameArray[indexPath.row]];
    return tableViewCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectRoomTypeName:)]) {
        [self.delegate selectRoomTypeName:self.roomNameArray[indexPath.row]];
    }
}

- (UITableView *)typeTableView {
    if (!_typeTableView) {
        _typeTableView =  [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 60, 150) style:(UITableViewStylePlain)];
        _typeTableView.delegate = self;
        _typeTableView.dataSource = self;
        _typeTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 9.f)];
        _typeTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 9.f)];
        _typeTableView.rowHeight = 44;
        _typeTableView.scrollEnabled = NO;
    }
    return _typeTableView;
}

@end
