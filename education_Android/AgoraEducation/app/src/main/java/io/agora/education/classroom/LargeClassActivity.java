package io.agora.education.classroom;

import android.content.res.Configuration;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.cardview.widget.CardView;

import com.google.android.material.tabs.TabLayout;

import java.util.Locale;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.agora.education.R;
import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.strategy.context.LargeClassContext;
import io.agora.education.classroom.widget.RtcVideoView;

public class LargeClassActivity extends BaseClassActivity implements LargeClassContext.LargeClassEventListener, TabLayout.OnTabSelectedListener {

    @BindView(R.id.layout_video_teacher)
    protected FrameLayout layout_video_teacher;
    @BindView(R.id.layout_video_student)
    protected FrameLayout layout_video_student;
    @Nullable
    @BindView(R.id.layout_tab)
    protected TabLayout layout_tab;
    @BindView(R.id.layout_chat_room)
    protected FrameLayout layout_chat_room;
    @Nullable
    @BindView(R.id.layout_materials)
    protected FrameLayout layout_materials;
    @BindView(R.id.layout_hand_up)
    protected CardView layout_hand_up;

    private RtcVideoView video_teacher;
    private RtcVideoView video_student;
    private User linkUser;

    @Override
    protected int getLayoutResId() {
        Configuration configuration = getResources().getConfiguration();
        if (configuration.orientation == Configuration.ORIENTATION_PORTRAIT) {
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
            return R.layout.activity_large_class_portrait;
        } else {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
            return R.layout.activity_large_class_landscape;
        }
    }

    @Override
    protected void initView() {
        super.initView();
        if (video_teacher == null) {
            video_teacher = new RtcVideoView(this);
            video_teacher.init(R.layout.layout_video_large_class, false);
        }
        removeFromParent(video_teacher);
        layout_video_teacher.addView(video_teacher, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

        if (video_student == null) {
            video_student = new RtcVideoView(this);
            video_student.init(R.layout.layout_video_small_class, true);
            video_student.setOnClickAudioListener(v -> {
                if (isMineLink()) {
                    muteLocalAudio(!video_student.isAudioMuted());
                }
            });
            video_student.setOnClickVideoListener(v -> {
                if (isMineLink()) {
                    muteLocalVideo(!video_student.isVideoMuted());
                }
            });
        }
        removeFromParent(video_student);
        layout_video_student.addView(video_student, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

        if (layout_tab != null)
            layout_tab.addOnTabSelectedListener(this);

        // disable operation in large class
        whiteboardFragment.disableDeviceInputs(true);
        whiteboardFragment.setWritable(false);

        if (surface_share_video != null) {
            removeFromParent(surface_share_video);
            layout_share_video.addView(surface_share_video, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        }

        resetHandState();
    }

    @Override
    protected int getClassType() {
        return Room.Type.LARGE;
    }

    @Override
    public void onConfigurationChanged(@NonNull Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        setContentView(getLayoutResId());
        ButterKnife.bind(this);
        initView();
    }

    @OnClick(R.id.layout_hand_up)
    public void onClick(View view) {
        boolean isSelected = view.isSelected();
        if (isSelected) {
            ((LargeClassContext) classContext).cancel();
        } else {
            ((LargeClassContext) classContext).apply();
        }
    }

    @Override
    public void onUserCountChanged(int count) {
        title_view.setTitle(String.format(Locale.getDefault(), "%s(%d)", getRoomName(), count));
    }

    @Override
    public void onTeacherMediaChanged(User user) {
        video_teacher.setName(user.userName);
        video_teacher.showRemote(user.uid);
        video_teacher.muteVideo(!user.isVideoEnable());
        video_teacher.muteAudio(!user.isAudioEnable());
    }

    @Override
    public void onLinkMediaChanged(User user) {
        linkUser = user;
        resetHandState();
        if (user == null) {
            video_student.setVisibility(View.GONE);
            video_student.setSurfaceView(null);
        } else {
            video_student.setName(user.userName);
            if (user.uid == getLocal().uid) {
                video_student.showLocal();
            } else {
                video_student.showRemote(user.uid);
            }
            // make sure the student video always on the top
            video_student.getSurfaceView().setZOrderMediaOverlay(true);
            video_student.muteVideo(!user.isVideoEnable());
            video_student.muteAudio(!user.isAudioEnable());
            video_student.setVisibility(View.VISIBLE);
        }
    }

    private boolean isMineLink() {
        return linkUser != null && linkUser.uid == getLocal().uid;
    }

    @Override
    public void onHandUpCanceled() {
        layout_hand_up.setSelected(false);
    }

    private void resetHandState() {
        if (isMineLink()) {
            layout_hand_up.setEnabled(true);
            layout_hand_up.setSelected(true);
        } else {
            layout_hand_up.setEnabled(linkUser == null);
            layout_hand_up.setSelected(false);
        }
    }

    @Override
    public void onTabSelected(TabLayout.Tab tab) {
        if (layout_materials == null)
            return;
        boolean showMaterials = tab.getPosition() == 0;
        layout_materials.setVisibility(showMaterials ? View.VISIBLE : View.GONE);
        layout_chat_room.setVisibility(showMaterials ? View.GONE : View.VISIBLE);
    }

    @Override
    public void onTabUnselected(TabLayout.Tab tab) {

    }

    @Override
    public void onTabReselected(TabLayout.Tab tab) {

    }

}
