package io.agora.education.classroom;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import com.google.android.exoplayer2.ui.PlayerView;

import butterknife.BindView;
import butterknife.OnClick;
import io.agora.base.network.RetrofitManager;
import io.agora.education.BuildConfig;
import io.agora.education.EduApplication;
import io.agora.education.R;
import io.agora.education.base.BaseActivity;
import io.agora.education.base.BaseCallback;
import io.agora.education.classroom.fragment.ReplayBoardFragment;
import io.agora.education.service.RoomService;

public class ReplayActivity extends BaseActivity {

    public static final String WHITEBOARD_ROOM_ID = "whiteboardRoomId";
    public static final String WHITEBOARD_START_TIME = "whiteboardStartTime";
    public static final String WHITEBOARD_END_TIME = "whiteboardEndTime";
    public static final String WHITEBOARD_URL = "whiteboardUrl";

    @BindView(R.id.video_view)
    protected PlayerView video_view;

    private ReplayBoardFragment replayBoardFragment;
    private String url, roomId;
    private long startTime, endTime;
    private boolean isInit;

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_replay;
    }

    @Override
    protected void initData() {
        Intent intent = getIntent();
        url = intent.getStringExtra(WHITEBOARD_URL);
        roomId = intent.getStringExtra(WHITEBOARD_ROOM_ID);
        startTime = intent.getLongExtra(WHITEBOARD_START_TIME, 0);
        endTime = intent.getLongExtra(WHITEBOARD_END_TIME, 0);
    }

    @Override
    protected void initView() {
        video_view.setUseController(false);
        video_view.setVisibility(!TextUtils.isEmpty(url) ? View.VISIBLE : View.GONE);
        findViewById(R.id.iv_temp).setVisibility(TextUtils.isEmpty(url) ? View.VISIBLE : View.GONE);

        replayBoardFragment = new ReplayBoardFragment();
        Bundle bundle = new Bundle();
        bundle.putLong(WHITEBOARD_START_TIME, startTime);
        bundle.putLong(WHITEBOARD_END_TIME, endTime);
        replayBoardFragment.setArguments(bundle);
        getSupportFragmentManager().beginTransaction()
                .add(R.id.layout_whiteboard, replayBoardFragment)
                .commitNow();
    }

    @Override
    protected void onResumeFragments() {
        super.onResumeFragments();
        if (!isInit) {
            RetrofitManager.instance().getService(BuildConfig.API_BASE_URL, RoomService.class)
                    .roomBoard(EduApplication.getAppId(), roomId)
                    .enqueue(new BaseCallback<>(data -> {
                        replayBoardFragment.initReplayWithRoomToken(data.boardId, data.boardToken);
                        replayBoardFragment.setPlayer(video_view, url);
                        isInit = true;
                    }));
        }
    }

    @Override
    protected void onDestroy() {
        replayBoardFragment.releaseReplay();
        super.onDestroy();
    }

    @OnClick(R.id.iv_back)
    public void onClick(View view) {
        finish();
    }

}
