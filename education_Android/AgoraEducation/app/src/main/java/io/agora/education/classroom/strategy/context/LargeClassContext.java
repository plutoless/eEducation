package io.agora.education.classroom.strategy.context;

import android.annotation.SuppressLint;
import android.content.Context;

import androidx.annotation.NonNull;

import java.util.List;

import io.agora.base.Callback;
import io.agora.base.ToastManager;
import io.agora.base.network.RetrofitManager;
import io.agora.education.BuildConfig;
import io.agora.education.EduApplication;
import io.agora.education.R;
import io.agora.education.base.BaseCallback;
import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.bean.msg.PeerMsg;
import io.agora.education.classroom.strategy.ChannelStrategy;
import io.agora.education.service.RoomService;
import io.agora.education.service.bean.request.CoVideoReq;
import io.agora.rtc.Constants;
import io.agora.sdk.manager.RtcManager;

import static io.agora.education.classroom.bean.msg.PeerMsg.CoVideoMsg.Type.ACCEPT;
import static io.agora.education.classroom.bean.msg.PeerMsg.CoVideoMsg.Type.APPLY;
import static io.agora.education.classroom.bean.msg.PeerMsg.CoVideoMsg.Type.CANCEL;
import static io.agora.education.classroom.bean.msg.PeerMsg.CoVideoMsg.Type.EXIT;
import static io.agora.education.classroom.bean.msg.PeerMsg.CoVideoMsg.Type.REJECT;

public class LargeClassContext extends ClassContext {

    LargeClassContext(Context context, ChannelStrategy strategy) {
        super(context, strategy);
    }

    @Override
    public void checkChannelEnterable(@NonNull Callback<Boolean> callback) {
        callback.onSuccess(true);
    }

    @Override
    void preConfig() {
        RtcManager.instance().setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
        RtcManager.instance().setClientRole(Constants.CLIENT_ROLE_AUDIENCE);
        RtcManager.instance().enableDualStreamMode(false);
    }

    @Override
    public void onRoomChanged(Room room) {
        super.onRoomChanged(room);
        if (classEventListener instanceof LargeClassEventListener) {
            runListener(() -> ((LargeClassEventListener) classEventListener).onUserCountChanged(room.onlineUsers));
        }
    }

    @Override
    public void onCoVideoUsersChanged(List<User> users) {
        super.onCoVideoUsersChanged(users);
        if (classEventListener instanceof LargeClassEventListener) {
            LargeClassEventListener listener = (LargeClassEventListener) classEventListener;
            runListener(() -> {
                User linkUser = null;
                for (User user : users) {
                    if (user.isTeacher()) {
                        listener.onTeacherMediaChanged(user);
                    } else {
                        linkUser = user;
                        break;
                    }
                }
                listener.onLinkMediaChanged(linkUser);
            });
        }
    }

    @SuppressLint("SwitchIntDef")
    @Override
    public void onPeerMsgReceived(PeerMsg msg) {
        super.onPeerMsgReceived(msg);
        if (msg.cmd == PeerMsg.Cmd.CO_VIDEO) {
            PeerMsg.CoVideoMsg coVideoMsg = msg.getMsg(PeerMsg.CoVideoMsg.class);
            switch (coVideoMsg.type) {
                case REJECT:
                    ToastManager.showShort(R.string.reject_interactive);
                    break;
                case ACCEPT:
                    ToastManager.showShort(R.string.accept_interactive);
                    break;
            }
        }
    }

    public void apply() {
        RetrofitManager.instance().getService(BuildConfig.API_BASE_URL, RoomService.class)
                .roomCoVideo(EduApplication.getAppId(), channelStrategy.getChannelId(), new CoVideoReq(APPLY))
                .enqueue(new BaseCallback<>(null));
    }

    public void cancel() {
        RetrofitManager.instance().getService(BuildConfig.API_BASE_URL, RoomService.class)
                .roomCoVideo(EduApplication.getAppId(), channelStrategy.getChannelId(), new CoVideoReq(channelStrategy.getLocal().isCoVideoEnable() ? EXIT : CANCEL))
                .enqueue(new BaseCallback<>(null));
    }

    public interface LargeClassEventListener extends ClassEventListener {
        void onUserCountChanged(int count);

        void onTeacherMediaChanged(User user);

        void onLinkMediaChanged(User user);

        void onHandUpCanceled();
    }

}
