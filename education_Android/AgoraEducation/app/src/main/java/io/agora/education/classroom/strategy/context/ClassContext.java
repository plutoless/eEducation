package io.agora.education.classroom.strategy.context;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Date;
import java.util.List;

import io.agora.base.Callback;
import io.agora.base.network.RetrofitManager;
import io.agora.education.BuildConfig;
import io.agora.education.EduApplication;
import io.agora.education.base.BaseCallback;
import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.bean.msg.PeerMsg;
import io.agora.education.classroom.strategy.ChannelEventListener;
import io.agora.education.classroom.strategy.ChannelStrategy;
import io.agora.education.service.RoomService;
import io.agora.rtc.Constants;
import io.agora.sdk.listener.RtcEventListener;
import io.agora.sdk.manager.RtcManager;

import static io.agora.education.classroom.bean.msg.ChannelMsg.Cmd.CHAT;
import static io.agora.education.classroom.bean.msg.ChannelMsg.Cmd.REPLAY;
import static io.agora.education.classroom.bean.msg.ChannelMsg.Cmd.ROOM;
import static io.agora.education.classroom.bean.msg.ChannelMsg.Cmd.USER;

public abstract class ClassContext implements ChannelEventListener {

    private Context context;

    @NonNull
    ChannelStrategy channelStrategy;
    ClassEventListener classEventListener;

    ClassContext(Context context, @NonNull ChannelStrategy strategy) {
        this.context = context;
        channelStrategy = strategy;
        channelStrategy.setChannelEventListener(this);
        RtcManager.instance().registerListener(rtcEventListener);
    }

    public final void setClassEventListener(@Nullable ClassEventListener listener) {
        classEventListener = listener;
    }

    @Deprecated
    public abstract void checkChannelEnterable(@NonNull Callback<Boolean> callback);

    public final void joinChannel() {
        preConfig();
        channelStrategy.joinChannel();
    }

    public final void leaveChannel() {
        channelStrategy.leaveChannel();
    }

    abstract void preConfig();

    public final void muteLocalAudio(boolean isMute) {
        User local = channelStrategy.getLocal().copy();
        local.disableAudio(isMute);
        channelStrategy.updateLocalAttribute(local, null);
    }

    public final void muteLocalVideo(boolean isMute) {
        User local = channelStrategy.getLocal().copy();
        local.disableVideo(isMute);
        channelStrategy.updateLocalAttribute(local, null);
    }

    public final void release() {
        channelStrategy.release();
        RtcManager.instance().unregisterListener(rtcEventListener);
        leaveChannel();
    }

    void runListener(Runnable runnable) {
        if (classEventListener != null) {
            if (context instanceof Activity) {
                ((Activity) context).runOnUiThread(runnable);
            }
        }
    }

    @Override
    public void onChannelInfoInit() {
        runListener(() -> classEventListener.onTeacherInit(channelStrategy.getTeacher()));
    }

    @Override
    public void onRoomChanged(Room room) {
        runListener(() -> {
            classEventListener.onClassStateChanged(room.isCourseBegin(), new Date().getTime() - room.startTime);
            // TODO load white board
            RetrofitManager.instance().getService(BuildConfig.API_BASE_URL, RoomService.class)
                    .roomBoard(EduApplication.getAppId(), room.roomId)
                    .enqueue(new BaseCallback<>(data -> classEventListener.onWhiteboardChanged(data.boardId, data.boardToken)));
            classEventListener.onLockWhiteboard(room.isBoardLock());
            classEventListener.onMuteAllChat(!room.isAllChatEnable());
        });
    }

    @Override
    public void onLocalChanged(User local) {
        RtcManager.instance().setClientRole(local.isCoVideoEnable() ? Constants.CLIENT_ROLE_BROADCASTER : Constants.CLIENT_ROLE_AUDIENCE);
        RtcManager.instance().muteLocalVideoStream(!local.isVideoEnable());
        RtcManager.instance().muteLocalAudioStream(!local.isAudioEnable());
        runListener(() -> classEventListener.onMuteLocalChat(!local.isChatEnable()));
    }

    @Override
    public void onCoVideoUsersChanged(List<User> users) {
    }

    @Override
    @SuppressLint("SwitchIntDef")
    public void onChannelMsgReceived(ChannelMsg msg) {
        switch (msg.cmd) {
            case CHAT:
                ChannelMsg.ChatMsg chatMsg = msg.getMsg(ChannelMsg.ChatMsg.class);
                runListener(() -> classEventListener.onChatMsgReceived(chatMsg));
                break;
            case ROOM:
                ChannelMsg.RoomMsg roomMsg = msg.getMsg(ChannelMsg.RoomMsg.class);
                channelStrategy.updateRoom(roomMsg);
                break;
            case USER:
                ChannelMsg.CoVideoUserMsg coVideoUserMsg = msg.getMsg(ChannelMsg.CoVideoUserMsg.class);
                channelStrategy.updateCoVideoUsers(coVideoUserMsg);
                break;
            case REPLAY:
                ChannelMsg.ReplayMsg replayMsg = msg.getMsg(ChannelMsg.ReplayMsg.class);
                runListener(() -> classEventListener.onChatMsgReceived(replayMsg));
                break;
        }
    }

    @Override
    public void onPeerMsgReceived(PeerMsg msg) {
    }

    @Override
    public void onMemberCountUpdated(int count) {
    }

    private RtcEventListener rtcEventListener = new RtcEventListener() {
        @Override
        public void onNetworkQuality(int uid, int txQuality, int rxQuality) {
            if (uid == 0) {
                runListener(() -> classEventListener.onNetworkQualityChanged(Math.max(txQuality, rxQuality)));
            }
        }

        @Override
        public void onUserJoined(int uid, int elapsed) {
            User teacher = channelStrategy.getTeacher();
            if (teacher != null) {
                if (uid == teacher.screenId) {
                    runListener(() -> classEventListener.onScreenShareJoined(uid));
                }
            }
        }

        @Override
        public void onUserOffline(int uid, int reason) {
            User teacher = channelStrategy.getTeacher();
            if (teacher != null) {
                if (uid == teacher.screenId) {
                    runListener(() -> classEventListener.onScreenShareOffline(uid));
                }
            }
        }
    };

}
