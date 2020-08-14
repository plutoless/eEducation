package io.agora.education.classroom.strategy;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.agora.base.Callback;
import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.bean.msg.PeerMsg;
import io.agora.rtm.RtmChannelAttribute;
import io.agora.rtm.RtmChannelMember;
import io.agora.rtm.RtmMessage;
import io.agora.sdk.listener.RtmEventListener;
import io.agora.sdk.manager.RtcManager;
import io.agora.sdk.manager.RtmManager;
import io.agora.sdk.manager.SdkManager;

public class RtmChannelStrategy extends ChannelStrategy<List<RtmChannelAttribute>> {

    public RtmChannelStrategy(String channelId, User local) {
        super(channelId, local);
        RtmManager.instance().registerListener(rtmEventListener);
    }

    @Override
    public void release() {
        super.release();
        RtmManager.instance().unregisterListener(rtmEventListener);
    }

    @Override
    public void joinChannel() {
        RtmManager.instance().joinChannel(new HashMap<String, String>() {{
            put(SdkManager.CHANNEL_ID, getChannelId());
        }});
        RtcManager.instance().joinChannel(new HashMap<String, String>() {{
            put(SdkManager.TOKEN, null);
            put(SdkManager.CHANNEL_ID, getChannelId());
            put(SdkManager.USER_ID, getLocal().getUid());
        }});
    }

    @Override
    public void leaveChannel() {
        RtmManager.instance().leaveChannel();
        RtcManager.instance().leaveChannel();
    }

    @Override
    public void queryOnlineUserNum(@NonNull Callback<Integer> callback) {
        List<User> users = getAllUsers();
        if (users.size() == 0) {
            callback.onSuccess(0);
        } else {
            Set<String> set = new HashSet<>();
            for (User user : users) {
                set.add(user.getUid());
            }
            RtmManager.instance().queryPeersOnlineStatus(set, new Callback<Map<String, Boolean>>() {
                @Override
                public void onSuccess(Map<String, Boolean> stringBooleanMap) {
                    int num = 0;
                    for (Map.Entry<String, Boolean> entry : stringBooleanMap.entrySet()) {
                        if (entry.getValue()) {
                            num++;
                        }
                    }
                    callback.onSuccess(num);
                }

                @Override
                public void onFailure(Throwable throwable) {
                    callback.onFailure(throwable);
                }
            });
        }
    }

    @Override
    public void queryChannelInfo(@Nullable Callback<Void> callback) {
        RtmManager.instance().getChannelAttributes(getChannelId(), new Callback<List<RtmChannelAttribute>>() {
            @Override
            public void onSuccess(List<RtmChannelAttribute> rtmChannelAttributes) {
                parseChannelInfo(rtmChannelAttributes);
                if (callback != null)
                    callback.onSuccess(null);
            }

            @Override
            public void onFailure(Throwable throwable) {
                if (callback != null)
                    callback.onFailure(throwable);
            }
        });
    }

    @Override
    public void parseChannelInfo(List<RtmChannelAttribute> data) {
        List<User> users = new ArrayList<>();
        for (RtmChannelAttribute attribute : data) {
            String value = attribute.getValue();
            if (TextUtils.equals(attribute.getKey(), "room")) {
                updateRoom(Room.fromJson(value, Room.class));
            } else if (TextUtils.equals(attribute.getKey(), "teacher")) {
                users.add(User.fromJson(value, User.class));
            } else if (TextUtils.equals(attribute.getKey(), getLocal().getUid())) {
                users.add(User.fromJson(value, User.class));
            } else {
                users.add(User.fromJson(value, User.class));
            }
        }
        updateCoVideoUsers(users);
    }

    @Override
    public void updateLocalAttribute(User local, @Nullable Callback<Void> callback) {
        RtmChannelAttribute attribute = new RtmChannelAttribute(local.getUid(), local.toJsonString());
        RtmManager.instance().addOrUpdateChannelAttributes(getChannelId(), Collections.singletonList(attribute), callback);
    }

    @Override
    public void clearLocalAttribute(@Nullable Callback<Void> callback) {
        String key = getLocal().getUid();
        RtmManager.instance().deleteChannelAttributesByKeys(getChannelId(), Collections.singletonList(key), callback);
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
        public void onAttributesUpdated(List<RtmChannelAttribute> list) {
            parseChannelInfo(list);
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
        public void onMemberCountUpdated(int i) {
            if (channelEventListener != null) {
                channelEventListener.onMemberCountUpdated(i);
            }
        }
    };

}
