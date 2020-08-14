package io.agora.education.classroom;

import android.view.View;

import butterknife.BindView;
import butterknife.OnClick;
import io.agora.education.R;
import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.strategy.context.OneToOneClassContext;
import io.agora.education.classroom.widget.RtcVideoView;

public class OneToOneClassActivity extends BaseClassActivity implements OneToOneClassContext.OneToOneClassEventListener {

    @BindView(R.id.layout_video_teacher)
    protected RtcVideoView video_teacher;
    @BindView(R.id.layout_video_student)
    protected RtcVideoView video_student;
    @BindView(R.id.layout_im)
    protected View layout_im;

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_one2one_class;
    }

    @Override
    protected void initView() {
        super.initView();
        video_teacher.init(R.layout.layout_video_one2one_class, false);
        video_student.init(R.layout.layout_video_one2one_class, true);
        video_student.setOnClickAudioListener(v -> muteLocalAudio(!video_student.isAudioMuted()));
        video_student.setOnClickVideoListener(v -> muteLocalVideo(!video_student.isVideoMuted()));
    }

    @Override
    protected int getClassType() {
        return Room.Type.ONE2ONE;
    }

    @OnClick(R.id.iv_float)
    public void onClick(View view) {
        boolean isSelected = view.isSelected();
        view.setSelected(!isSelected);
        layout_im.setVisibility(isSelected ? View.VISIBLE : View.GONE);
    }

    @Override
    public void onTeacherMediaChanged(User user) {
        video_teacher.setName(user.userName);
        video_teacher.showRemote(user.uid);
        video_teacher.muteVideo(!user.isVideoEnable());
        video_teacher.muteAudio(!user.isAudioEnable());
    }

    @Override
    public void onLocalMediaChanged(User user) {
        video_student.setName(user.userName);
        video_student.showLocal();
        video_student.muteVideo(!user.isVideoEnable());
        video_student.muteAudio(!user.isAudioEnable());
    }

}
