package io.agora.education.classroom.strategy;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashMap;

import io.agora.base.Callback;
import io.agora.base.network.RetrofitManager;
import io.agora.education.BuildConfig;
import io.agora.education.EduApplication;
import io.agora.education.base.BaseCallback;
import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.bean.msg.PeerMsg;
import io.agora.education.service.RoomService;
import io.agora.education.service.bean.request.UserReq;
import io.agora.education.service.bean.response.RoomRes;
import io.agora.rtm.RtmChannelMember;
import io.agora.rtm.RtmMessage;
import io.agora.sdk.listener.RtmEventListener;
import io.agora.sdk.manager.RtcManager;
import io.agora.sdk.manager.RtmManager;
import io.agora.sdk.manager.SdkManager;

public class HttpChannelStrategy extends ChannelStrategy<RoomRes> {

    private RoomService roomService;

    public HttpChannelStrategy(String channelId, User local) {
        super(channelId, local);
        roomService = RetrofitManager.instance().getService(BuildConfig.API_BASE_URL, RoomService.class);
        RtmManager.instance().registerListener(rtmEventListener);
    }

    @Override
    public void release() {
        super.release();
        RtmManager.instance().unregisterListener(rtmEventListener);
    }

    @Override
    public void joinChannel() {
        roomService.room(EduApplication.getAppId(), getChannelId()).enqueue(new BaseCallback<>(data -> {
            Room room = data.room;
            User user = data.user;
            RtmManager.instance().joinChannel(new HashMap<String, String>() {{
                put(SdkManager.CHANNEL_ID, room.channelName);
            }});
            RtcManager.instance().joinChannel(new HashMap<String, String>() {{
                put(SdkManager.TOKEN, user.rtcToken);
                put(SdkManager.CHANNEL_ID, room.channelName);
                put(SdkManager.USER_ID, user.getUid());
                put(SdkManager.USER_EXTRA, BuildConfig.EXTRA);
            }});
        }));
    }

    @Override
    public void leaveChannel() {
        roomService.roomExit(EduApplication.getAppId(), getChannelId());
        RtmManager.instance().leaveChannel();
        RtcManager.instance().leaveChannel();
    }

    @Override
    public void queryOnlineUserNum(@NonNull Callback<Integer> callback) {
        roomService.room(EduApplication.getAppId(), getChannelId()).enqueue(new BaseCallback<>(
                data -> callback.onSuccess(data.room.onlineUsers),
                callback::onFailure)
        );
    }

    @Override
    public void queryChannelInfo(@Nullable Callback<Void> callback) {
        roomService.room(EduApplication.getAppId(), getChannelId())
                .enqueue(new BaseCallback<>(data -> {
                    parseChannelInfo(data);
                    if (callback != null) {
                        callback.onSuccess(null);
                    }
                }, throwable -> {
                    if (callback != null) {
                        callback.onFailure(throwable);
                    }
                }));
    }

    @Override
    public void parseChannelInfo(RoomRes data) {
        Room room = data.room;
        updateRoom(room);
        updateCoVideoUsers(room.coVideoUsers);
    }

    @Override
    public void updateLocalAttribute(User local, @Nullable Callback<Void> callback) {
        roomService.user(EduApplication.getAppId(), getChannelId(), local.userId, UserReq.fromUser(local))
                .enqueue(new BaseCallback<>(data -> {
                    if (callback != null) {
                        callback.onSuccess(null);
                    }
                    queryChannelInfo(null);
                }, throwable -> {
                    if (callback != null) {
                        callback.onFailure(throwable);
                    }
                }));
    }

    @Override
    public void clearLocalAttribute(@Nullable Callback<Void> callback) {
        UserReq req = UserReq.fromUser(getLocal());
        req.coVideo = User.CoVideo.DISABLE;
        roomService.user(EduApplication.getAppId(), getChannelId(), getLocal().userId, req).enqueue(new BaseCallback<>(data -> {
            if (callback != null) {
                callback.onSuccess(null);
            }
        }, throwable -> {
            if (callback != null) {
                callback.onFailure(throwable);
            }
        }));
    }

    private RtmEventListener rtmEventListener = new RtmEventListener() {
        @Override
        public void onJoinChannelSuccess(String channel) {
            queryChannelInfo(new Callback<Void>() {
                @Override
                public void onSuccess(Void aVoid) {
                    if (channelEventListener != null) {
                        channelEventListener.onChannelInfoInit();
                    }
                }

                @Override
                public void onFailure(Throwable throwable) {
                }
            });
        }

        @Override
        public void onMessageReceived(RtmMessage rtmMessage, RtmChannelMember rtmChannelMember) {
            if (channelEventListener != null) {
                ChannelMsg msg = ChannelMsg.fromJson(rtmMessage.getText(), ChannelMsg.class);
                channelEventListener.onChannelMsgReceived(msg);
            }
        }

        @Override
        public void onMessageReceived(RtmMessage rtmMessage, String s) {
            if (channelEventListener != null) {
                PeerMsg msg = PeerMsg.fromJson(rtmMessage.getText(), PeerMsg.class);
                channelEventListener.onPeerMsgReceived(msg);
            }
        }

        @Override
        public void onMemberCountUpdated(int count) {
            if (channelEventListener != null) {
                channelEventListener.onMemberCountUpdated(count);
            }
        }
    };

}
