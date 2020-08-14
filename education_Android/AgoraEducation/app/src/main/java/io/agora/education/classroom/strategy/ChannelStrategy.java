package io.agora.education.classroom.strategy;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.ArrayList;
import java.util.List;

import io.agora.base.Callback;
import io.agora.education.classroom.bean.channel.ChannelInfo;
import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.log.LogManager;

public abstract class ChannelStrategy<T> {

    private final LogManager log = new LogManager(this.getClass().getSimpleName());

    private String channelId;
    private ChannelInfo channelInfo;

    @Nullable
    ChannelEventListener channelEventListener;

    ChannelStrategy(String channelId, User local) {
        this.channelId = channelId;
        this.channelInfo = new ChannelInfo(local);
    }

    public final String getChannelId() {
        return channelId;
    }

    @Nullable
    public final Room getRoom() {
        return channelInfo.getRoom();
    }

    @NonNull
    public final User getLocal() {
        return channelInfo.getLocal();
    }

    @Nullable
    public final User getTeacher() {
        return channelInfo.getTeacher();
    }

    @NonNull
    public final List<User> getOthers() {
        return channelInfo.getOthers();
    }

    public final List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        if (getTeacher() != null) {
            users.add(getTeacher());
        }
        users.add(getLocal());
        users.addAll(getOthers());
        return users;
    }

    public final void updateRoom(Room room) {
        if (channelInfo.updateRoom(room)) {
            if (channelEventListener != null) {
                channelEventListener.onRoomChanged(getRoom());
            }
        }
    }

    public final void updateRoom(ChannelMsg.RoomMsg roomMsg) {
        Room room = channelInfo.getRoom();
        if (room == null) return;
        room = room.copy();
        roomMsg.updateTo(room);
        updateRoom(room);
    }

    public final void updateCoVideoUsers(@NonNull List<User> users) {
        List<User> others = new ArrayList<>();
        User local = null;
        User teacher = null;
        for (User user : users) {
            if (user.isTeacher()) {
                teacher = user;
            } else if (TextUtils.equals(user.userId, getLocal().userId)) {
                local = user;
            } else {
                others.add(user);
            }
        }

        if (channelInfo.updateLocal(local)) {
            if (channelEventListener != null) {
                channelEventListener.onLocalChanged(getLocal());
            }
        }
        channelInfo.updateTeacher(teacher);
        channelInfo.updateOthers(others);

        onCoVideoUsersChanged();
    }

    private void onCoVideoUsersChanged() {
        if (channelEventListener != null) {
            List<User> coVideoUsers = new ArrayList<>();
            for (User user : getAllUsers()) {
                if (user.isCoVideoEnable()) {
                    coVideoUsers.add(user);
                }
            }
            channelEventListener.onCoVideoUsersChanged(coVideoUsers);
        }
    }

    public final void setChannelEventListener(@Nullable ChannelEventListener listener) {
        this.channelEventListener = listener;
    }

    public void release() {
        channelEventListener = null;
    }

    public abstract void joinChannel();

    public abstract void leaveChannel();

    public abstract void queryOnlineUserNum(@NonNull Callback<Integer> callback);

    public abstract void queryChannelInfo(@Nullable Callback<Void> callback);

    public abstract void parseChannelInfo(T data);

    public abstract void updateLocalAttribute(User local, @Nullable Callback<Void> callback);

    public abstract void clearLocalAttribute(@Nullable Callback<Void> callback);

}
