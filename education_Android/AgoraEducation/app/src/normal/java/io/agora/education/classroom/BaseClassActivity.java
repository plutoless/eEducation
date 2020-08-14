package io.agora.education.classroom;

import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import butterknife.BindView;
import io.agora.base.ToastManager;
import io.agora.education.R;
import io.agora.education.base.BaseActivity;
import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.fragment.ChatRoomFragment;
import io.agora.education.classroom.fragment.WhiteBoardFragment;
import io.agora.education.classroom.strategy.context.ClassContext;
import io.agora.education.classroom.strategy.context.ClassContextFactory;
import io.agora.education.classroom.strategy.context.ClassEventListener;
import io.agora.education.classroom.widget.TitleView;
import io.agora.education.widget.ConfirmDialog;
import io.agora.rtc.video.VideoCanvas;
import io.agora.sdk.annotation.NetworkQuality;
import io.agora.sdk.manager.RtcManager;

public abstract class BaseClassActivity extends BaseActivity implements ClassEventListener {

    public static final String ROOM = "room";
    public static final String USER = "user";

    @BindView(R.id.title_view)
    protected TitleView title_view;
    @BindView(R.id.layout_whiteboard)
    protected FrameLayout layout_whiteboard;
    @BindView(R.id.layout_share_video)
    protected FrameLayout layout_share_video;

    protected SurfaceView surface_share_video;

    protected WhiteBoardFragment whiteboardFragment = new WhiteBoardFragment();
    protected ChatRoomFragment chatRoomFragment = new ChatRoomFragment();

    protected ClassContext classContext;

    @Override
    protected void initData() {
        initStrategy();
    }

    @Override
    protected void initView() {
        title_view.setTitle(getRoomName());

        getSupportFragmentManager().beginTransaction()
                .remove(whiteboardFragment)
                .remove(chatRoomFragment)
                .commitNow();
        getSupportFragmentManager().beginTransaction()
                .add(R.id.layout_whiteboard, whiteboardFragment)
                .add(R.id.layout_chat_room, chatRoomFragment)
                .show(chatRoomFragment)
                .commit();
    }

    protected final void initStrategy() {
        classContext = new ClassContextFactory(this).getClassContext(getClassType(), getRoomId(), getLocal());
        classContext.setClassEventListener(this);
        classContext.joinChannel();
    }

    public final void muteLocalAudio(boolean isMute) {
        classContext.muteLocalAudio(isMute);
    }

    public final void muteLocalVideo(boolean isMute) {
        classContext.muteLocalVideo(isMute);
    }

    public final User getLocal() {
        return getUserFromIntent();
    }

    @Room.Type
    protected abstract int getClassType();

    @Override
    protected void onDestroy() {
        classContext.release();
        whiteboardFragment.releaseBoard();
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
        showLeaveDialog();
    }

    public final void showLeaveDialog() {
        ConfirmDialog.normal(getString(R.string.confirm_leave_room_content), confirm -> {
            if (confirm) finish();
        }).show(getSupportFragmentManager(), null);
    }

    private Room getRoomFromIntent() {
        return (Room) getIntent().getSerializableExtra(ROOM);
    }

    public final String getRoomId() {
        return getRoomFromIntent().roomId;
    }

    public final String getRoomName() {
        return getRoomFromIntent().roomName;
    }

    private User getUserFromIntent() {
        return (User) getIntent().getSerializableExtra(USER);
    }

    @Override
    public void onTeacherInit(User teacher) {
        if (teacher == null) {
            ToastManager.showShort(R.string.there_is_no_teacher_in_this_classroom);
        }
    }

    @Override
    public void onNetworkQualityChanged(@NetworkQuality int quality) {
        title_view.setNetworkQuality(quality);
    }

    @Override
    public void onClassStateChanged(boolean isBegin, long time) {
        title_view.setTimeState(isBegin, time);
    }

    @Override
    public void onWhiteboardChanged(String uuid, String roomToken) {
        whiteboardFragment.initBoardWithRoomToken(uuid, roomToken);
    }

    @Override
    public void onLockWhiteboard(boolean locked) {
        whiteboardFragment.disableCameraTransform(locked);
    }

    @Override
    public void onMuteLocalChat(boolean muted) {
        chatRoomFragment.setMuteLocal(muted);
    }

    @Override
    public void onMuteAllChat(boolean muted) {
        chatRoomFragment.setMuteAll(muted);
    }

    @Override
    public void onChatMsgReceived(ChannelMsg.ChatMsg msg) {
        chatRoomFragment.addMessage(msg);
    }

    @Override
    public void onScreenShareJoined(int uid) {
        if (surface_share_video == null) {
            surface_share_video = RtcManager.instance().createRendererView(this);
        }
        layout_whiteboard.setVisibility(View.GONE);
        layout_share_video.setVisibility(View.VISIBLE);

        removeFromParent(surface_share_video);
        surface_share_video.setTag(uid);
        layout_share_video.addView(surface_share_video, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        RtcManager.instance().setupRemoteVideo(surface_share_video, VideoCanvas.RENDER_MODE_FIT, uid);
    }

    @Override
    public void onScreenShareOffline(int uid) {
        Object tag = surface_share_video.getTag();
        if (tag instanceof Integer) {
            if ((int) tag == uid) {
                layout_whiteboard.setVisibility(View.VISIBLE);
                layout_share_video.setVisibility(View.GONE);

                removeFromParent(surface_share_video);
                surface_share_video = null;
            }
        }
    }

}
