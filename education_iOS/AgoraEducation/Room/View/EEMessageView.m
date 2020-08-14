//
//  EEMessageView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EEMessageView.h"
#import "EEMessageViewCell.h"
#import "ReplayViewController.h"

@interface EEMessageView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) UITableView *messageTableView;
@property (nonatomic, strong) NSMutableArray *messageArray;

@end

@implementation EEMessageView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UITableView *messageTableView = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
    messageTableView.delegate = self;
    messageTableView.dataSource =self;
    [self addSubview:messageTableView];
    self.messageTableView = messageTableView;
    messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.messageArray = [NSMutableArray array];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.messageTableView.frame = self.bounds;
}

- (void)updateTableView {
    [self.messageTableView reloadData];
}

- (void)addMessageModel:(MessageInfoModel *)model {

    [self.messageArray addObject:model];

    [self.messageTableView reloadData];
    if (self.messageArray.count > 0) {
         [self.messageTableView scrollToRowAtIndexPath:
          [NSIndexPath indexPathForRow:[self.messageArray count] - 1 inSection:0] atScrollPosition: UITableViewScrollPositionBottom animated:NO];
     }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EEMessageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EEMessageViewCell" owner:self options:nil] firstObject];
    }
    cell.cellWidth = self.bounds.size.width;
    cell.messageModel = self.messageArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageInfoModel *messageModel = self.messageArray[indexPath.row];
    if(messageModel.cellHeight > 0){
        return messageModel.cellHeight;
    }
    NSString *str = messageModel.message;
    if(str == nil){
        str = @"";
    }
    CGSize labelSize = [str boundingRectWithSize:CGSizeMake(self.messageTableView.frame.size.width - 38, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.f]} context:nil].size;
    messageModel.cellHeight = labelSize.height + 60;
    return labelSize.height + 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MessageInfoModel *messageModel = self.messageArray[indexPath.row];
    if(messageModel.recordId == nil || messageModel.recordId.length == 0){
        return;
    }
    
    [ReplayViewController enterReplayViewController:messageModel.recordId];
}
@end
