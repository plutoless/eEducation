package io.agora.education.classroom.fragment;

import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.RadioGroup;

import com.herewhite.sdk.RoomParams;
import com.herewhite.sdk.WhiteSdk;
import com.herewhite.sdk.WhiteSdkConfiguration;
import com.herewhite.sdk.WhiteboardView;
import com.herewhite.sdk.domain.Appliance;
import com.herewhite.sdk.domain.DeviceType;
import com.herewhite.sdk.domain.MemberState;
import com.herewhite.sdk.domain.Promise;
import com.herewhite.sdk.domain.RoomPhase;
import com.herewhite.sdk.domain.SDKError;
import com.herewhite.sdk.domain.SceneState;

import butterknife.BindView;
import butterknife.OnTouch;
import io.agora.base.ToastManager;
import io.agora.education.R;
import io.agora.education.base.BaseFragment;
import io.agora.education.classroom.widget.whiteboard.ApplianceView;
import io.agora.education.classroom.widget.whiteboard.ColorPicker;
import io.agora.education.classroom.widget.whiteboard.PageControlView;
import io.agora.education.util.ColorUtil;
import io.agora.whiteboard.netless.listener.BoardEventListener;
import io.agora.whiteboard.netless.manager.BoardManager;

public class WhiteBoardFragment extends BaseFragment implements RadioGroup.OnCheckedChangeListener, PageControlView.PageControlListener, BoardEventListener {

    @BindView(R.id.white_board_view)
    protected WhiteboardView white_board_view;
    @BindView(R.id.appliance_view)
    protected ApplianceView appliance_view;
    @BindView(R.id.color_select_view)
    protected ColorPicker color_select_view;
    @BindView(R.id.page_control_view)
    protected PageControlView page_control_view;
    @BindView(R.id.pb_loading)
    protected ProgressBar pb_loading;

    private WhiteSdk whiteSdk;
    private BoardManager boardManager = new BoardManager();

    @Override
    protected int getLayoutResId() {
        return R.layout.fragment_white_board;
    }

    @Override
    protected void initData() {
        WhiteSdkConfiguration configuration = new WhiteSdkConfiguration(DeviceType.touch, 10, 0.1);
        whiteSdk = new WhiteSdk(white_board_view, context, configuration);
        boardManager.setListener(this);
    }

    @Override
    protected void initView() {
        white_board_view.addOnLayoutChangeListener((v, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom) -> {
            boardManager.refreshViewSize();
        });
        appliance_view.setVisibility(boardManager.isDisableDeviceInputs() ? View.GONE : View.VISIBLE);
        appliance_view.setOnCheckedChangeListener(this);
        color_select_view.setChangedListener(color -> {
            appliance_view.check(appliance_view.getApplianceId(boardManager.getAppliance()));
            boardManager.setStrokeColor(ColorUtil.colorToArray(color));
        });
        page_control_view.setListener(this);
    }

    public void initBoardWithRoomToken(String uuid, String roomToken) {
        if (TextUtils.isEmpty(uuid) || TextUtils.isEmpty(roomToken)) return;
        boardManager.getRoomPhase(new Promise<RoomPhase>() {
            @Override
            public void then(RoomPhase phase) {
                if (phase != RoomPhase.connected) {
                    pb_loading.setVisibility(View.VISIBLE);
                    RoomParams params = new RoomParams(uuid, roomToken);
                    boardManager.init(whiteSdk, params);
                }
            }

            @Override
            public void catchEx(SDKError t) {
                ToastManager.showShort(t.getMessage());
            }
        });
    }

    public void disableDeviceInputs(boolean disabled) {
        if (disabled != boardManager.isDisableDeviceInputs()) {
            ToastManager.showShort(disabled ? R.string.revoke_board : R.string.authorize_board);
        }
        if (appliance_view != null) {
            appliance_view.setVisibility(disabled ? View.GONE : View.VISIBLE);
        }
        boardManager.disableDeviceInputs(disabled);
    }

    public void disableCameraTransform(boolean disabled) {
        if (disabled != boardManager.isDisableCameraTransform()) {
            if (disabled) {
                ToastManager.showShort(R.string.follow_tips);
                boardManager.disableDeviceInputsTemporary(true);
            } else {
                boardManager.disableDeviceInputsTemporary(boardManager.isDisableDeviceInputs());
            }
        }
        boardManager.disableCameraTransform(disabled);
    }

    public void setWritable(boolean writable) {
        boardManager.setWritable(writable);
    }

    public void releaseBoard() {
        boardManager.disconnect();
    }

    @OnTouch(R.id.white_board_view)
    boolean onTouch(View view, MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_DOWN) {
            white_board_view.requestFocus();
            if (boardManager.isDisableCameraTransform() && !boardManager.isDisableDeviceInputs()) {
                ToastManager.showShort(R.string.follow_tips);
            }
        }
        return false;
    }

    @Override
    public void onCheckedChanged(RadioGroup group, int checkedId) {
        color_select_view.setVisibility(View.GONE);
        switch (checkedId) {
            case R.id.tool_selector:
                boardManager.setAppliance(Appliance.SELECTOR);
                break;
            case R.id.tool_pencil:
                boardManager.setAppliance(Appliance.PENCIL);
                break;
            case R.id.tool_text:
                boardManager.setAppliance(Appliance.TEXT);
                break;
            case R.id.tool_eraser:
                boardManager.setAppliance(Appliance.ERASER);
                break;
            case R.id.tool_color:
                color_select_view.setVisibility(View.VISIBLE);
                break;
        }
    }

    @Override
    public void toStart() {
        boardManager.setSceneIndex(0);
    }

    @Override
    public void toPrevious() {
        boardManager.pptPreviousStep();
    }

    @Override
    public void toNext() {
        boardManager.pptNextStep();
    }

    @Override
    public void toEnd() {
        boardManager.setSceneIndex(boardManager.getSceneCount() - 1);
    }

    @Override
    public void onRoomPhaseChanged(RoomPhase phase) {
        pb_loading.setVisibility(phase == RoomPhase.connected ? View.GONE : View.VISIBLE);
    }

    @Override
    public void onSceneStateChanged(SceneState state) {
        page_control_view.setPageIndex(state.getIndex(), state.getScenes().length);
    }

    @Override
    public void onMemberStateChanged(MemberState state) {
        appliance_view.check(appliance_view.getApplianceId(state.getCurrentApplianceName()));
    }

}
