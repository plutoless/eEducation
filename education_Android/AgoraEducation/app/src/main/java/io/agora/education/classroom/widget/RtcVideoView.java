package io.agora.education.classroom.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.SurfaceView;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.LayoutRes;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.agora.education.classroom.mediator.VideoMediator;
import io.agora.education.R;

public class RtcVideoView extends ConstraintLayout {

    @BindView(R.id.tv_name)
    protected TextView tv_name;
    @BindView(R.id.ic_audio)
    protected RtcAudioView ic_audio;
    @Nullable
    @BindView(R.id.ic_video)
    protected ImageView ic_video;
    @BindView(R.id.layout_place_holder)
    protected FrameLayout layout_place_holder;
    @BindView(R.id.layout_video)
    protected FrameLayout layout_video;

    public RtcVideoView(Context context) {
        super(context);
    }

    public RtcVideoView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public RtcVideoView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void init(@LayoutRes int layoutResId, boolean isShowVideo) {
        inflate(getContext(), layoutResId, this);
        ButterKnife.bind(this);
        if (ic_video != null)
            ic_video.setVisibility(isShowVideo ? VISIBLE : GONE);
    }

    public void setName(String name) {
        tv_name.setText(name);
    }

    public void muteAudio(boolean muted) {
        ic_audio.setState(muted ? RtcAudioView.State.CLOSED : RtcAudioView.State.OPENED);
    }

    public boolean isAudioMuted() {
        return ic_audio.getState() == RtcAudioView.State.CLOSED;
    }

    public void muteVideo(boolean muted) {
        if (ic_video != null)
            ic_video.setSelected(!muted);
        layout_video.setVisibility(muted ? GONE : VISIBLE);
        layout_place_holder.setVisibility(muted ? VISIBLE : GONE);
    }

    public boolean isVideoMuted() {
        if (ic_video != null) {
            return !ic_video.isSelected();
        }
        return true;
    }

    public SurfaceView getSurfaceView() {
        if (layout_video.getChildCount() > 0) {
            return (SurfaceView) layout_video.getChildAt(0);
        }
        return null;
    }

    public void setSurfaceView(SurfaceView surfaceView) {
        layout_video.removeAllViews();
        if (surfaceView != null) {
            layout_video.addView(surfaceView, FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
        }
    }

    public void setOnClickAudioListener(OnClickListener listener) {
        ic_audio.setOnClickListener(listener);
    }

    public void setOnClickVideoListener(OnClickListener listener) {
        if (ic_video != null) {
            ic_video.setOnClickListener(listener);
        }
    }

    public void showLocal() {
        VideoMediator.setupLocalVideo(this);
    }

    public void showRemote(int uid) {
        VideoMediator.setupRemoteVideo(this, uid);
    }

}
