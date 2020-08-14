
//
//  BigClassViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/22.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BCViewController.h"
#import "BCSegmentedView.h"
#import "EEChatTextFiled.h"
#import "BCStudentVideoView.h"
#import "EETeacherVideoView.h"
#import "BCNavigationView.h"
#import "EEMessageView.h"
#import "UIView+Toast.h"
#import "WhiteBoardTouchView.h"

@interface BCViewController ()<BCSegmentedDelegate, UITextFieldDelegate, RoomProtocol, SignalDelegate, RTCDelegate, WhitePlayDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledRelativeTeacherViewLeftCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledBottomConstraint;

@property (weak, nonatomic) IBOutlet EETeacherVideoView *teactherVideoView;
@property (weak, nonatomic) IBOutlet BCStudentVideoView *studentVideoView;
@property (weak, nonatomic) IBOutlet BCSegmentedView *segmentedView;
@property (weak, nonatomic) IBOutlet BCNavigationView *navigationView;
@property (weak, nonatomic) IBOutlet UIButton *handUpButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageView;

// white
@property (weak, nonatomic) IBOutlet UIView *whiteboardView;
@property (nonatomic, weak) WhiteBoardView *boardView;
@property (nonatomic, assign) NSInteger segmentedIndex;
@property (nonatomic, assign) NSInteger unreadMessageCount;
@property (nonatomic, assign) SignalLinkState linkState;
@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, assign) BOOL isRenderShare;

@property (nonatomic, assign) BOOL hasSignalReconnect;

@end

@implementation BCViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self initData];
    [self addNotification];
    
    [self handleDeviceOrientationChange];
}

-(void)initData {
    
    self.isRenderShare = NO;
    self.hasSignalReconnect = NO;
    self.linkState = SignalLinkStateIdle;
    
    self.segmentedView.delegate = self;
    self.studentVideoView.delegate = self;
    self.navigationView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;

    [self.navigationView updateClassName: EduConfigModel.shareInstance.className];
    
    // init signal & rtc & white -> init ui
    {
        self.educationManager.signalDelegate = self;
        
        [self setupRTC];
        [self setupWhiteBoard];
        [self updateChatViews];
        
        // init role render
        [self checkNeedRenderWithRole:UserRoleTypeTeacher];
        [self checkNeedRenderWithRole:UserRoleTypeStudent];
    }
}

- (void)updateViewOnReconnected {
    WEAK(self);
    
    if(self.educationManager.renderStudentModel != nil){
        [self removeStudentCanvas:self.educationManager.renderStudentModel.uid];
    }
    
    [self.educationManager getRoomInfoCompleteSuccessBlock:^(RoomInfoModel * _Nonnull roomInfoModel) {
        
        [weakself updateChatViews];
        [weakself disableCameraTransform:roomInfoModel.room.lockBoard];

        [weakself checkNeedRenderWithRole:UserRoleTypeTeacher];
        [weakself checkNeedRenderWithRole:UserRoleTypeStudent];
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
 
    }];
}

- (void)disableCameraTransform:(BOOL)disableCameraTransform {
    [self.educationManager disableCameraTransform:disableCameraTransform];
}

- (void)setupRTC {
    
    EduConfigModel *configModel = EduConfigModel.shareInstance;
    
    [self.educationManager initRTCEngineKitWithAppid:configModel.appId clientRole:RTCClientRoleAudience dataSourceDelegate:self];
    
    WEAK(self);
    [self.educationManager joinRTCChannelByToken:configModel.rtcToken channelId:configModel.channelName info:nil uid:configModel.uid joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        [weakself checkNeedRenderWithRole:UserRoleTypeStudent];
    }];
}

- (void)muteVideoStream:(BOOL)mute {
    
    AgoraLogInfo(@"large muteVideoStream:%d", mute);
    
    if(self.educationManager.renderStudentModel == nil) {
        return;
    }
    
    WEAK(self);
    [self.educationManager updateEnableVideoWithValue:!mute completeSuccessBlock:^{
        
        UserModel *renderModel = weakself.educationManager.renderStudentModel;
        [weakself updateStudentViews:renderModel remoteVideo:NO];
        
    } completeFailBlock:^(NSString * _Nonnull errMessage) {
        
        [weakself showToast:errMessage];
        UserModel *renderModel = weakself.educationManager.renderStudentModel;
        [weakself updateStudentViews:renderModel remoteVideo:NO];
    }];
}

- (void)muteAudioStream:(BOOL)mute {

    AgoraLogInfo(@"large muteAudioStream:%d", mute);
    
   if(self.educationManager.renderStudentModel == nil) {
       return;
   }
   
   WEAK(self);
   [self.educationManager updateEnableAudioWithValue:!mute completeSuccessBlock:^{
       
       UserModel *renderModel = weakself.educationManager.renderStudentModel;
       [weakself updateStudentViews:renderModel remoteVideo:NO];

   } completeFailBlock:^(NSString * _Nonnull errMessage) {
       
       [weakself showToast:errMessage];
       UserModel *renderModel = weakself.educationManager.renderStudentModel;
       [weakself updateStudentViews:renderModel remoteVideo:NO];
   }];
}

- (void)checkNeedRenderWithRole:(UserRoleType)roleType {
    
    if(roleType == UserRoleTypeTeacher) {
        UserModel *teacherModel = self.educationManager.teacherModel;
        [self updateTeacherViews: teacherModel];
        if(teacherModel != nil) {
            [self renderTeacherCanvas:teacherModel.uid];
        }
    } else if(roleType == UserRoleTypeStudent) {
        UserModel *renderModel = self.educationManager.renderStudentModel;
        if(renderModel != nil) {
            if (renderModel.uid == self.educationManager.studentModel.uid) {
                [self renderStudentCanvas:renderModel.uid remoteVideo:NO];
                [self updateStudentViews:renderModel remoteVideo:NO];
            } else {
                [self renderStudentCanvas:renderModel.uid remoteVideo:YES];
                [self updateStudentViews:renderModel remoteVideo:YES];
            }
        }
    }
}

- (void)renderTeacherCanvas:(NSUInteger)uid {
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.teactherVideoView.teacherRenderView;
    model.renderMode = RTCVideoRenderModeHidden;
    model.canvasType = RTCVideoCanvasTypeRemote;
    [self.educationManager setupRTCVideoCanvas: model completeBlock:nil];
}

- (void)renderShareCanvas:(NSUInteger)uid {
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.shareScreenView;
    model.renderMode = RTCVideoRenderModeFit;
    model.canvasType = RTCVideoCanvasTypeRemote;
    [self.educationManager setupRTCVideoCanvas:model completeBlock:nil];
    
    self.shareScreenView.hidden = NO;
    self.isRenderShare = YES;
}

- (void)removeShareCanvas {
    self.shareScreenView.hidden = YES;
    self.isRenderShare = NO;
}

- (void)renderStudentCanvas:(NSUInteger)uid remoteVideo:(BOOL)remote {
    
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.studentVideoView.studentRenderView;
    model.renderMode = RTCVideoRenderModeHidden;
    model.canvasType = remote ? RTCVideoCanvasTypeRemote : RTCVideoCanvasTypeLocal;
    [self.educationManager setupRTCVideoCanvas:model completeBlock:nil];

    if(!remote){
        self.linkState = SignalLinkStateTeaAccept;
        [self.educationManager setRTCClientRole:RTCClientRoleBroadcaster];
    }
}

- (void)removeStudentCanvas:(NSUInteger)uid {
    
    if(self.educationManager.studentModel.uid == uid){
        [self.educationManager setRTCClientRole:RTCClientRoleAudience];
    }
    [self.educationManager removeRTCVideoCanvas: uid];
    self.studentVideoView.defaultImageView.hidden = NO;
    self.studentVideoView.hidden = YES;
    [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
}

- (void)updateTeacherViews:(UserModel*)teacherModel {
    
    if(teacherModel != nil){
        if (self.segmentedIndex == 0) {
            self.handUpButton.hidden = NO;
        }
        [self.teactherVideoView updateSpeakerImageWithMuted:!teacherModel.enableAudio];
        self.teactherVideoView.defaultImageView.hidden = teacherModel.enableVideo ? YES : NO;
        [self.teactherVideoView updateAndsetTeacherName: teacherModel.userName];
    } else {
        if (self.segmentedIndex == 0) {
            self.handUpButton.hidden = YES;
        }
        [self.teactherVideoView updateSpeakerImageWithMuted:YES];
        self.teactherVideoView.defaultImageView.hidden = NO;
        [self.teactherVideoView updateAndsetTeacherName:@""];
    }
}

- (void)updateChatViews {

    RoomModel *roomModel = self.educationManager.roomModel;
     BOOL muteChat = roomModel != nil ? roomModel.muteAllChat : NO;
     if(!muteChat) {
         UserModel *studentModel = self.educationManager.studentModel;
         muteChat = studentModel.enableChat == 0 ? YES : NO;
     }
     self.chatTextFiled.contentTextFiled.enabled = muteChat ? NO : YES;
     self.chatTextFiled.contentTextFiled.placeholder = muteChat ? NSLocalizedString(@"ProhibitedPostText", nil) : NSLocalizedString(@"InputMessageText", nil);
}

- (void)updateStudentViews:(UserModel *)studentModel remoteVideo:(BOOL)remote {
    
    if(studentModel == nil){
        return;
    }
    
    self.studentVideoView.hidden = NO;
    
    [self.studentVideoView setButtonEnabled:!remote];
    [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup-x"] forState:(UIControlStateNormal)];

    [self.studentVideoView updateVideoImageWithMuted:studentModel.enableVideo == 0 ? YES : NO];
    [self.studentVideoView updateAudioImageWithMuted:studentModel.enableAudio == 0 ? YES : NO];

    [self.educationManager muteRTCLocalVideo:studentModel.enableVideo == 0 ? YES : NO];
    [self.educationManager muteRTCLocalAudio:studentModel.enableAudio == 0 ? YES : NO];
}

- (void)showToast:(NSString *)title {
    [UIApplication.sharedApplication.keyWindow makeToast:title];
}

- (void)setupView {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (@available(iOS 11, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
        
    WhiteBoardView *boardView = [[WhiteBoardView alloc] init];
    [self.whiteboardView addSubview:boardView];
    self.boardView = boardView;
    boardView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.whiteboardView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.whiteboardView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.whiteboardView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.whiteboardView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.whiteboardView addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];

    self.handUpButton.layer.borderWidth = 1.f;
    self.handUpButton.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    self.handUpButton.layer.backgroundColor = [UIColor colorWithHexString:@"FFFFFF"].CGColor;
    self.handUpButton.layer.cornerRadius = 6;

    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;
    
    if(IsPad) {
        [self stateBarHidden:YES];
        self.chatTextFiled.hidden = NO;
        self.messageView.hidden = NO;
        self.handUpButton.hidden = NO;
    }
}

- (void)handleDeviceOrientationChange {

    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
        {
            [self verticalScreenConstraints];
            [self.view layoutIfNeeded];
            [self.educationManager refreshWhiteViewSize];
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            [self landscapeScreenConstraints];
            [self.view layoutIfNeeded];
            [self.educationManager refreshWhiteViewSize];
        }
            break;
        default:
            break;
    }
}

- (void)stateBarHidden:(BOOL)hidden {
    self.isLandscape = hidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)handUpEvent:(UIButton *)sender {
    
    UserModel *renderModel = self.educationManager.renderStudentModel;
    if(renderModel != nil && renderModel.uid != self.educationManager.studentModel.uid) {
        return;
    }
    
    switch (self.linkState) {
        case SignalLinkStateIdle:
        case SignalLinkStateTeaReject:
        case SignalLinkStateStuCancel:
        case SignalLinkStateStuClose:
        case SignalLinkStateTeaClose:
            [self coVideoStateChanged: SignalLinkStateApply];
            break;
        case SignalLinkStateApply:
            [self coVideoStateChanged: SignalLinkStateStuCancel];
            break;
        case SignalLinkStateTeaAccept:
            [self coVideoStateChanged: SignalLinkStateStuClose];
            break;
        default:
            break;
    }
}

- (void)coVideoStateChanged:(SignalLinkState) linkState {
    switch (linkState) {
        case SignalLinkStateApply:
        case SignalLinkStateStuCancel:
        case SignalLinkStateStuClose:{
            WEAK(self);
            [BaseEducationManager sendCoVideoWithType:linkState successBolck:^{
                weakself.linkState = linkState;
            } completeFailBlock:^(NSString * _Nonnull errMessage) {
                [weakself showToast:errMessage];
            }];
            if(linkState == SignalLinkStateStuCancel){
                self.linkState = linkState;
                [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
            } else if(linkState == SignalLinkStateStuClose){
                self.linkState = linkState;
                [self removeStudentCanvas:self.educationManager.renderStudentModel.uid];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)landscapeScreenConstraints {
    if(!IsPad) {
        [self stateBarHidden:YES];

        self.handUpButton.hidden = self.educationManager.teacherModel ? NO: YES;
        self.chatTextFiled.hidden = NO;
        self.messageView.hidden = NO;
    }
}

- (void)verticalScreenConstraints {
    if(!IsPad) {
        [self stateBarHidden:NO];
        self.chatTextFiled.hidden = self.segmentedIndex == 0 ? YES : NO;
        self.messageView.hidden = self.segmentedIndex == 0 ? YES : NO;
        self.handUpButton.hidden = self.educationManager.teacherModel ? NO: YES;
        
        if(self.isRenderShare) {
            self.shareScreenView.hidden = NO;
        }
    }
}

#pragma mark Notification
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        self.chatTextFiledRelativeTeacherViewLeftCon.active = NO;
        
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        self.textFiledBottomConstraint.constant = bottom;
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    self.chatTextFiledRelativeTeacherViewLeftCon.active = YES;
    self.textFiledBottomConstraint.constant = 0;
}

- (void)setupWhiteBoard {
    
    [self.educationManager initWhiteSDK:self.boardView dataSourceDelegate:self];

    RoomModel *roomModel = self.educationManager.roomModel;
    
    WEAK(self);
    [self.educationManager joinWhiteRoomWithBoardId:EduConfigModel.shareInstance.boardId boardToken:EduConfigModel.shareInstance.boardToken whiteWriteModel:NO completeSuccessBlock:^(WhiteRoom * _Nullable room) {

        [weakself disableCameraTransform:roomModel.lockBoard];
        
    } completeFailBlock:^(NSError * _Nullable error) {
        [weakself showToast:NSLocalizedString(@"JoinWhiteErrorText", nil)];
    }];
}

#pragma mark BCSegmentedDelegate
- (void)selectedItemIndex:(NSInteger)index {

    if (index == 0) {
        self.segmentedIndex = 0;
        self.messageView.hidden = YES;
        self.chatTextFiled.hidden = YES;
        self.handUpButton.hidden = self.educationManager.teacherModel ? NO: YES;
        if(self.isRenderShare) {
            self.shareScreenView.hidden = NO;
        }
    } else {
        self.segmentedIndex = 1;
        self.messageView.hidden = NO;
        self.chatTextFiled.hidden = NO;
        self.handUpButton.hidden = YES;
        self.unreadMessageCount = 0;
        [self.segmentedView hiddeBadge];
        self.shareScreenView.hidden = YES;
    }
}

#pragma mark RoomProtocol
- (void)closeRoom {
    WEAK(self);
    [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"QuitClassroomText", nil) sureHandler:^(UIAlertAction * _Nullable action) {
    
        [weakself.educationManager releaseResources];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (BOOL)prefersStatusBarHidden {
    return self.isLandscape;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)showTipWithMessage:(NSString *)toastMessage {
    
    self.tipLabel.hidden = NO;
    [self.tipLabel setText: toastMessage];
    
    WEAK(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       weakself.tipLabel.hidden = YES;
    });
}

#pragma mark SignalDelegate
- (void)didReceivedPeerSignal:(SignalP2PInfoModel *)model {
    switch (model.type) {
        case SignalLinkStateTeaReject:
            [self showTipWithMessage:NSLocalizedString(@"RejectRequestText", nil)];
            break;
        case SignalLinkStateTeaAccept:
            [self showTipWithMessage:NSLocalizedString(@"AcceptRequestText", nil)];
            break;
        case SignalLinkStateTeaClose:
            [self showTipWithMessage:NSLocalizedString(@"TeaCloseCoVideoText", nil)];
            break;
        default:
            break;
    }
    self.linkState = model.type;
}
- (void)didReceivedSignal:(SignalInfoModel *)signalInfoModel {
    switch (signalInfoModel.signalType) {
        case SignalValueCoVideo: {
            if(signalInfoModel.uid == self.educationManager.teacherModel.uid) {
                [self checkNeedRenderWithRole:UserRoleTypeTeacher];
            } else {
                if(self.educationManager.renderStudentModel == nil){
                    [self removeStudentCanvas:signalInfoModel.uid];
                }
                [self checkNeedRenderWithRole:UserRoleTypeStudent];
            }
        }
            break;
        case SignalValueAudio:
        case SignalValueVideo:
            if(signalInfoModel.uid == self.educationManager.teacherModel.uid) {
                [self updateTeacherViews:self.educationManager.teacherModel];
            } else {
                if(signalInfoModel.uid == self.educationManager.studentModel.uid) {
                    [self updateStudentViews:self.educationManager.renderStudentModel remoteVideo:NO];
                } else {
                    [self updateStudentViews:self.educationManager.renderStudentModel remoteVideo:YES];
                }
            }
            break;
        case SignalValueChat: {
             [self updateChatViews];
        }
            break;
        case SignalValueFollow: {
            NSString *toastMessage;
            BOOL lockBoard = self.educationManager.roomModel.lockBoard;
            if(lockBoard) {
                toastMessage = NSLocalizedString(@"LockBoardText", nil);
            } else {
                toastMessage = NSLocalizedString(@"UnlockBoardText", nil);
            }
            [self showTipWithMessage:toastMessage];
            [self disableCameraTransform:lockBoard];
        }
            break;
        case SignalValueAllChat: {
            [self updateChatViews];
        }
            break;
        default:
            break;
    }
}

- (void)didReceivedMessage:(MessageInfoModel *)model {
    [self.messageView addMessageModel:model];
    
    if (self.messageView.hidden == YES) {
        self.unreadMessageCount = self.unreadMessageCount + 1;
        [self.segmentedView showBadgeWithCount:(self.unreadMessageCount)];
    }
}
- (void)didReceivedConnectionStateChanged:(AgoraRtmConnectionState)state {
    if(state == AgoraRtmConnectionStateConnected) {

        if(self.hasSignalReconnect) {
            self.hasSignalReconnect = NO;
            [self updateViewOnReconnected];
        }
        
    } else if(state == AgoraRtmConnectionStateReconnecting) {
        
        self.hasSignalReconnect = YES;
        
        // When the signaling is abnormal, ensure that there is no voice and image of the current user in the current channel
        // 当信令异常的时候，保证当前频道内没有当前用户说话的声音和图像
        [self.educationManager muteRTCLocalVideo: YES];
        [self.educationManager muteRTCLocalAudio: YES];
        
    } else if(state == AgoraRtmConnectionStateDisconnected) {
        
        // When the signaling is abnormal, ensure that there is no voice and image of the current user in the current channel
        // 当信令异常的时候，保证当前频道内没有当前用户说话的声音和图像
        [self.educationManager muteRTCLocalVideo: YES];
        [self.educationManager muteRTCLocalAudio: YES];
        
    } else if(state == AgoraRtmConnectionStateAborted) {
        [self showToast:NSLocalizedString(@"LoginOnAnotherDeviceText", nil)];
        [self.educationManager releaseResources];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark RTCDelegate
- (void)rtcDidJoinedOfUid:(NSUInteger)uid {
    if(self.educationManager.teacherModel && uid == self.educationManager.teacherModel.screenId) {
        [self renderShareCanvas: uid];
    }
}
- (void)rtcDidOfflineOfUid:(NSUInteger)uid {
    if(self.educationManager.teacherModel && uid == self.educationManager.teacherModel.screenId) {
        [self removeShareCanvas];
    }
}
- (void)rtcNetworkTypeGrade:(RTCNetworkGrade)grade {
    switch (grade) {
        case RTCNetworkGradeHigh:
            [self.navigationView updateSignalImageName:@"icon-signal3"];
            break;
        case RTCNetworkGradeMiddle:
            [self.navigationView updateSignalImageName:@"icon-signal2"];
            break;
        case RTCNetworkGradeLow:
            [self.navigationView updateSignalImageName:@"icon-signal1"];
            break;
        default:
            [self.navigationView updateSignalImageName:@"icon-signal1"];
            break;
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard = YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard =  NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *content = textField.text;
    if (content.length > 0) {
        WEAK(self);
        [BaseEducationManager sendMessageWithType:MessageTypeText message:content successBolck:^{
            MessageInfoModel *model = [MessageInfoModel new];
            model.userName = EduConfigModel.shareInstance.userName;
            model.message = content;
            model.isSelfSend = YES;
            [weakself.messageView addMessageModel:model];
        } completeFailBlock:^(NSString * _Nonnull errMessage) {
            [weakself showToast:errMessage];
        }];
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

@end
