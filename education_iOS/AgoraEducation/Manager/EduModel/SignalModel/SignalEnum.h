//
//  SignalEnum.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/29.
//  Copyright © 2019 Agora. All rights reserved.
//

typedef NS_ENUM(NSInteger, MessageCmdType) {
    MessageCmdTypeChat                  = 1,
    MessageCmdTypeUserOnline            = 2,
    MessageCmdTypeRoomInfo              = 3,
    MessageCmdTypeUserInfo              = 4,
    MessageCmdTypeReplay                = 5,
    MessageCmdTypeShareScreen           = 6,
};

typedef NS_ENUM(NSInteger, SignalType) {
    SignalValueCoVideo,         // 上/下麦
    SignalValueAudio,           // 禁/解禁音频
    SignalValueVideo,           // 禁/解禁视频
    SignalValueChat,            // 禁/解禁聊天
    SignalValueGrantBoard,      // 禁/解禁白板
    
    SignalValueFollow,          // 跟随/取消白板
    SignalValueCourse,          // 开始/结束上课
    SignalValueAllChat,         // 全员禁言/解除
    
    SignalValueShareScreen,     // 开始/结束分享屏幕
};

// covideo state
typedef NS_ENUM(NSInteger, SignalLinkState) {
    SignalLinkStateIdle             = 0,
    SignalLinkStateApply            = 1,
    SignalLinkStateTeaReject        = 2,
    SignalLinkStateStuCancel        = 3, // Cancel Apply
    SignalLinkStateTeaAccept        = 4, // linked
    SignalLinkStateTeaClose         = 5, // teacher close link
    SignalLinkStateStuClose         = 6, // student close link
};
