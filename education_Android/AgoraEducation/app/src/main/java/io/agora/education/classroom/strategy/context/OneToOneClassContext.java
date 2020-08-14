package io.agora.education.classroom.strategy.context;

import android.content.Context;

import androidx.annotation.NonNull;

import java.util.List;

import io.agora.base.Callback;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.strategy.ChannelStrategy;
import io.agora.rtc.Constants;
import io.agora.sdk.manager.RtcManager;

public class OneToOneClassContext extends ClassContext {

    private final static int MAX_USER_NUM = 2;

    OneToOneClassContext(Context context, ChannelStrategy strategy) {
        super(context, strategy);
    }

    @Override
    @Deprecated
    public void checkChannelEnterable(@NonNull Callback<Boolean> callback) {
        channelStrategy.queryChannelInfo(new Callback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                channelStrategy.queryOnlineUserNum(new Callback<Integer>() {
                    @Override
                    public void onSuccess(Integer integer) {
                        callback.onSuccess(integer < MAX_USER_NUM);
                    }

                    @Override
                    public void onFailure(Throwable throwable) {
                        callback.onFailure(throwable);
                    }
                });
            }

            @Override
            public void onFailure(Throwable throwable) {
                callback.onFailure(throwable);
            }
        });
    }

    @Override
    void preConfig() {
        RtcManager.instance().setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
        RtcManager.instance().setClientRole(Constants.CLIENT_ROLE_BROADCASTER);
        RtcManager.instance().enableDualStreamMode(false);
    }

    @Override
    public void onLocalChanged(User local) {
        super.onLocalChanged(local);
        if (classEventListener instanceof OneToOneClassEventListener) {
            runListener(() -> ((OneToOneClassEventListener) classEventListener).onLocalMediaChanged(local));
        }
    }

    @Override
    public void onCoVideoUsersChanged(List<User> users) {
        super.onCoVideoUsersChanged(users);
        if (classEventListener instanceof OneToOneClassEventListener) {
            for (User user : users) {
                if (user.isTeacher()) {
                    runListener(() -> ((OneToOneClassEventListener) classEventListener).onTeacherMediaChanged(user));
                    return;
                }
            }
        }
    }

    public interface OneToOneClassEventListener extends ClassEventListener {
        void onTeacherMediaChanged(User user);

        void onLocalMediaChanged(User user);
    }

}
