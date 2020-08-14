package io.agora.education.classroom.widget.player;

import android.content.Context;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.exoplayer2.ui.PlayerView;
import com.herewhite.sdk.domain.PlayerPhase;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.agora.education.R;
import io.agora.education.util.TimeUtil;
import io.agora.timeline.SimpleTimeline;
import io.agora.timeline.SimpleTimelineManager;
import io.agora.timeline.TimelineListener;
import io.agora.timeline.TimelineState;
import io.agora.whiteboard.netless.listener.ReplayEventListener;
import io.agora.whiteboard.netless.manager.ReplayManager;

public class ReplayControlView extends RelativeLayout implements ReplayEventListener, SeekBar.OnSeekBarChangeListener, TimelineListener {

    @BindView(R.id.btn_play)
    protected ImageView btn_play;
    @BindView(R.id.btn_play_pause)
    protected ImageView btn_play_pause;
    @BindView(R.id.sb_time)
    protected SeekBar sb_time;
    @BindView(R.id.tv_current_time)
    protected TextView tv_current_time;
    @BindView(R.id.tv_total_time)
    protected TextView tv_total_time;

    private boolean isTrackingTouch;
    private SimpleTimeline timeline;
    private SimpleTimelineManager mManager;
    private ExoVideoPlayer videoPlayer;
    private ReplayManager replayManager;

    private Handler mHandler;
    private Runnable runnable = () -> {
        if (mManager.getState() == TimelineState.STATE_START
                && !isTrackingTouch) {
            setVisibility(GONE);
        }
    };

    public ReplayControlView(@NonNull Context context) {
        this(context, null);
    }

    public ReplayControlView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ReplayControlView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mHandler = new Handler();
        inflate(context, R.layout.layout_replay_control, this);
        ButterKnife.bind(this);
        sb_time.setOnSeekBarChangeListener(this);
    }

    public void init(PlayerView videoView, String url, long startTime, long endTime) {
        timeline = new SimpleTimeline(startTime, endTime);
        timeline.setTimelineListener(this);
        mManager = new SimpleTimelineManager(timeline);

        videoPlayer = new ExoVideoPlayer(videoView, url);
        mManager.addTimeline(videoPlayer);

        tv_total_time.setText(TimeUtil.stringForTimeHMS(timeline.getDuration() / 1000, "%02d:%02d:%02d"));
    }

    public void release() {
        if (videoPlayer != null) {
            videoPlayer.release();
        }
    }

    private void playOrPause() {
        if (mManager != null) {
            switch (mManager.getState()) {
                case TimelineState.STATE_IDLE:
                case TimelineState.STATE_PAUSE:
                    if (mManager != null) {
                        mManager.start();
                    }
                    break;
                case TimelineState.STATE_BUFFERING:
                    break;
                case TimelineState.STATE_START:
                    if (mManager != null) {
                        mManager.pause();
                    }
                    break;
                case TimelineState.STATE_STOP:
                    if (mManager != null) {
                        mManager.seekTo(0);
                        mManager.start();
                    }
            }
        }
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        if (mManager != null && visibility == VISIBLE) {
            if (mManager.getState() == TimelineState.STATE_START
                    && !isTrackingTouch) {
                mHandler.removeCallbacks(runnable);
                mHandler.postDelayed(runnable, 2500);
            }
        }
    }

    @OnClick({R.id.btn_play, R.id.btn_play_pause})
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.btn_play:
            case R.id.btn_play_pause:
                playOrPause();
                break;
        }
    }

    @Override
    public void onPlayerPrepared(ReplayManager replayBoard) {
        replayManager = replayBoard;
        // whiteboard preload
        replayManager.play();
        if (mManager != null) {
            mManager.addTimeline(new WhiteboardPlayer(replayBoard));
        }
    }

    @Override
    public void onPhaseChanged(PlayerPhase playerPhase) {
    }

    @Override
    public void onLoadFirstFrame() {
        if (replayManager != null) {
            // whiteboard loaded
            replayManager.pause();
        }
        mHandler.post(() -> setVisibility(VISIBLE));
    }

    @Override
    public void onScheduleTimeChanged(long l) {
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        if (fromUser) {
            float percent = (float) progress / seekBar.getMax();
            long position = (long) (timeline.getDuration() * percent);
            tv_current_time.setText(TimeUtil.stringForTimeHMS(position / 1000, "%02d:%02d:%02d"));
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {
        isTrackingTouch = true;
    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {
        float percent = (float) seekBar.getProgress() / seekBar.getMax();
        long position = (long) (timeline.getDuration() * percent);
        if (mManager != null) {
            mManager.seekTo(position);
            if (mManager.getState() == TimelineState.STATE_STOP) {
                mManager.start();
            }
        }
        isTrackingTouch = false;
    }

    @Override
    public void onStart() {
        mHandler.post(() -> {
            btn_play.setVisibility(GONE);
            btn_play_pause.setImageResource(R.drawable.ic_pause);
            setVisibility(VISIBLE);
        });
    }

    @Override
    public void onPause() {
        mHandler.post(() -> {
            btn_play.setVisibility(VISIBLE);
            btn_play_pause.setImageResource(R.drawable.ic_play);
            setVisibility(VISIBLE);
        });
    }

    @Override
    public void onTimelineChanged(long currentTime, long totalTime) {
        if (!isTrackingTouch) {
            mHandler.post(() -> {
                float percent = (float) currentTime / totalTime;
                sb_time.setProgress((int) (percent * sb_time.getMax()));
                tv_current_time.setText(TimeUtil.stringForTimeHMS(currentTime / 1000, "%02d:%02d:%02d"));
            });
        }
    }

    @Override
    public void onStop() {
        mHandler.post(() -> {
            btn_play.setVisibility(VISIBLE);
            btn_play_pause.setImageResource(R.drawable.ic_play);
            setVisibility(VISIBLE);
        });
    }
}
