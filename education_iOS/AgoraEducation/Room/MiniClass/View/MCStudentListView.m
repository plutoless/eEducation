//
//  MCStudentListView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MCStudentListView.h"
#import "MCStudentViewCell.h"

@interface MCStudentListView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) UITableView *studentTableView;
@property (nonatomic, strong) NSArray<UserModel*> *studentArray;

@end

@implementation MCStudentListView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UITableView *studentTableView = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
    studentTableView.delegate = self;
    studentTableView.dataSource =self;
    [self addSubview:studentTableView];
    self.studentTableView = studentTableView;
    studentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.studentArray = [NSMutableArray array];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.studentTableView.frame = self.bounds;
}

- (void)updateStudentArray:(NSArray<UserModel*> *)array {
    
    self.studentArray = [NSArray arrayWithArray:array];
    [self.studentTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.studentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCStudentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"studentCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MCStudentViewCell" owner:self options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.muteAudioButton addTarget:self action:@selector(muteAudio:) forControlEvents:(UIControlEventTouchUpInside)];
        [cell.muteVideoButton addTarget:self action:@selector(muteVideo:) forControlEvents:(UIControlEventTouchUpInside)];
    }

    UserModel *infoModel = self.studentArray[indexPath.row];
    cell.uid = self.uid;
    cell.studentModel = infoModel;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)muteAudio:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(muteAudioStream:)]) {
        [self.delegate muteAudioStream:sender.selected];
    }
    sender.selected = !sender.selected;
    NSString *imageName = sender.selected ? @"icon-speaker3-max":@"speaker-close";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
}

- (void)muteVideo:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(muteVideoStream:)]) {
        [self.delegate muteVideoStream:sender.selected];
    }
    sender.selected = !sender.selected;
    NSString *imageName = sender.selected ? @"roomCameraOn":@"roomCameraOff";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
}


- (void)setUid:(NSInteger)uid {
    _uid = uid;
    [self.studentTableView reloadData];
}
@end
