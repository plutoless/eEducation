package io.agora.education.classroom.strategy.context;

import androidx.annotation.Nullable;

import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.sdk.annotation.NetworkQuality;

public interface ClassEventListener {

    void onTeacherInit(@Nullable User teacher);

    void onNetworkQualityChanged(@NetworkQuality int quality);

    void onClassStateChanged(boolean isBegin, long time);

    void onWhiteboardChanged(String uuid, String roomToken);

    void onLockWhiteboard(boolean locked);

    void onMuteLocalChat(boolean muted);

    void onMuteAllChat(boolean muted);

    void onChatMsgReceived(ChannelMsg.ChatMsg msg);

    void onScreenShareJoined(int uid);

    void onScreenShareOffline(int uid);

}
