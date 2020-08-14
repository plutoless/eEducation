package io.agora.education;

import android.Manifest;
import android.app.DownloadManager;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;

import butterknife.BindView;
import butterknife.OnClick;
import butterknife.OnTouch;
import io.agora.base.Callback;
import io.agora.base.ToastManager;
import io.agora.base.network.RetrofitManager;
import io.agora.education.base.BaseActivity;
import io.agora.education.base.BaseCallback;
import io.agora.education.broadcast.DownloadReceiver;
import io.agora.education.classroom.BaseClassActivity;
import io.agora.education.classroom.LargeClassActivity;
import io.agora.education.classroom.OneToOneClassActivity;
import io.agora.education.classroom.SmallClassActivity;
import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.service.CommonService;
import io.agora.education.service.RoomService;
import io.agora.education.service.bean.request.RoomEntryReq;
import io.agora.education.util.AppUtil;
import io.agora.education.util.CryptoUtil;
import io.agora.education.util.UUIDUtil;
import io.agora.education.widget.ConfirmDialog;
import io.agora.education.widget.PolicyDialog;
import io.agora.sdk.manager.RtcManager;
import io.agora.sdk.manager.RtmManager;

public class MainActivity extends BaseActivity {

    private final int REQUEST_CODE_DOWNLOAD = 100;
    private final int REQUEST_CODE_RTC = 101;

    @BindView(R.id.et_room_name)
    protected EditText et_room_name;
    @BindView(R.id.et_your_name)
    protected EditText et_your_name;
    @BindView(R.id.et_room_type)
    protected EditText et_room_type;
    @BindView(R.id.card_room_type)
    protected CardView card_room_type;

    private DownloadReceiver receiver;
    private CommonService commonService;
    private RoomService roomService;
    private String url;
    private boolean isJoining;

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_main;
    }

    @Override
    protected void initData() {
        receiver = new DownloadReceiver();
        IntentFilter filter = new IntentFilter();
        filter.addAction(DownloadManager.ACTION_DOWNLOAD_COMPLETE);
        filter.setPriority(IntentFilter.SYSTEM_LOW_PRIORITY);
        registerReceiver(receiver, filter);

        String appId = getString(R.string.agora_app_id);
        EduApplication.setAppId(appId);
        RtcManager.instance().init(getApplicationContext(), appId);
        RtmManager.instance().init(getApplicationContext(), appId);

        RetrofitManager.instance().addHeader("Authorization", CryptoUtil.getAuth(getString(R.string.agora_auth)));
        commonService = RetrofitManager.instance().getService(BuildConfig.API_BASE_URL, CommonService.class);
        roomService = RetrofitManager.instance().getService(BuildConfig.API_BASE_URL, RoomService.class);
        checkVersion();
        getConfig();
    }

    @Override
    protected void initView() {
        new PolicyDialog().show(getSupportFragmentManager(), null);
        if (BuildConfig.DEBUG) {
            et_room_name.setText("123");
            et_your_name.setText("123");
        }
    }

    @Override
    protected void onDestroy() {
        unregisterReceiver(receiver);
        RtmManager.instance().reset();
        super.onDestroy();
    }

    private void checkVersion() {
        commonService.appVersion().enqueue(new BaseCallback<>(data -> {
            if (data != null && data.forcedUpgrade != 0) {
                showAppUpgradeDialog(data.upgradeUrl, data.forcedUpgrade == 2);
            }
        }));
    }

    private void showAppUpgradeDialog(String url, boolean isForce) {
        this.url = url;
        String content = getString(R.string.app_upgrade);
        ConfirmDialog.DialogClickListener listener = confirm -> {
            if (confirm) {
                if (AppUtil.checkAndRequestAppPermission(MainActivity.this, new String[]{
                        Manifest.permission.WRITE_EXTERNAL_STORAGE
                }, REQUEST_CODE_DOWNLOAD)) {
                    receiver.downloadApk(MainActivity.this, url);
                }
            }
        };
        ConfirmDialog dialog;
        if (isForce) {
            dialog = ConfirmDialog.singleWithButton(content, getString(R.string.upgrade), listener);
            dialog.setCancelable(false);
        } else {
            dialog = ConfirmDialog.normalWithButton(content, getString(R.string.later), getString(R.string.upgrade), listener);
        }
        dialog.show(getSupportFragmentManager(), null);
    }

    private void getConfig() {
        commonService.language().enqueue(new BaseCallback<>(EduApplication::setMultiLanguage));
    }

    private void joinRoom() {
        String roomNameStr = et_room_name.getText().toString();
        if (TextUtils.isEmpty(roomNameStr)) {
            ToastManager.showShort(R.string.room_name_should_not_be_empty);
            return;
        }

        String yourNameStr = et_your_name.getText().toString();
        if (TextUtils.isEmpty(yourNameStr)) {
            ToastManager.showShort(R.string.your_name_should_not_be_empty);
            return;
        }

        String roomTypeStr = et_room_type.getText().toString();
        if (TextUtils.isEmpty(roomTypeStr)) {
            ToastManager.showShort(R.string.room_type_should_not_be_empty);
            return;
        }

        if (EduApplication.getMultiLanguage() == null) {
            ToastManager.showShort(R.string.configuration_load_failed);
            getConfig();
            return;
        }

        roomEntry(yourNameStr, roomNameStr, getClassType(roomTypeStr));
    }

    @Room.Type
    private int getClassType(String roomTypeStr) {
        if (roomTypeStr.equals(getString(R.string.one2one_class))) {
            return Room.Type.ONE2ONE;
        } else if (roomTypeStr.equals(getString(R.string.small_class))) {
            return Room.Type.SMALL;
        } else {
            return Room.Type.LARGE;
        }
    }

    private void roomEntry(String yourNameStr, String roomNameStr, @Room.Type int classType) {
        if (isJoining) return;
        isJoining = true;
        roomService.roomEntry(EduApplication.getAppId(), new RoomEntryReq() {{
            userName = yourNameStr;
            userUuid = UUIDUtil.getUUID();
            roomName = roomNameStr;
            roomUuid = roomNameStr;
            type = classType;
        }}).enqueue(new BaseCallback<>(data -> {
            RetrofitManager.instance().addHeader("token", data.userToken);
            room(data.roomId);
        }, throwable -> isJoining = false));
    }

    private void room(String roomId) {
        roomService.room(EduApplication.getAppId(), roomId).enqueue(new BaseCallback<>(data -> {
            User user = data.user;
            Room room = data.room;
            RtmManager.instance().login(user.rtmToken, user.uid, new Callback<Void>() {
                @Override
                public void onSuccess(Void res) {
                    startActivity(createIntent(room, user));
                    isJoining = false;
                }

                @Override
                public void onFailure(Throwable throwable) {
                    ToastManager.showShort(throwable.getMessage());
                    isJoining = false;
                }
            });
        }, throwable -> isJoining = false));
    }

    private Intent createIntent(Room room, User user) {
        Intent intent = new Intent();
        if (room.type == Room.Type.ONE2ONE) {
            intent.setClass(this, OneToOneClassActivity.class);
        } else if (room.type == Room.Type.SMALL) {
            intent.setClass(this, SmallClassActivity.class);
        } else {
            intent.setClass(this, LargeClassActivity.class);
        }
        intent.putExtra(BaseClassActivity.ROOM, room)
                .putExtra(BaseClassActivity.USER, user);
        return intent;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        for (int result : grantResults) {
            if (result != PackageManager.PERMISSION_GRANTED) {
                ToastManager.showShort(R.string.no_enough_permissions);
                return;
            }
        }
        switch (requestCode) {
            case REQUEST_CODE_DOWNLOAD:
                receiver.downloadApk(this, url);
                break;
            case REQUEST_CODE_RTC:
                joinRoom();
                break;
        }
    }

    @OnClick({R.id.iv_setting, R.id.et_room_type, R.id.btn_join, R.id.tv_one2one, R.id.tv_small_class, R.id.tv_large_class})
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.iv_setting:
                startActivity(new Intent(this, SettingActivity.class));
                break;
            case R.id.btn_join:
                if (AppUtil.checkAndRequestAppPermission(this, new String[]{
                        Manifest.permission.RECORD_AUDIO,
                        Manifest.permission.CAMERA,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE
                }, REQUEST_CODE_RTC)) {
                    joinRoom();
                }
                break;
            case R.id.tv_one2one:
                et_room_type.setText(R.string.one2one_class);
                card_room_type.setVisibility(View.GONE);
                break;
            case R.id.tv_small_class:
                et_room_type.setText(R.string.small_class);
                card_room_type.setVisibility(View.GONE);
                break;
            case R.id.tv_large_class:
                et_room_type.setText(R.string.large_class);
                card_room_type.setVisibility(View.GONE);
                break;
        }
    }

    @OnTouch(R.id.et_room_type)
    public void onTouch(View view, MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_UP) {
            if (card_room_type.getVisibility() == View.GONE) {
                card_room_type.setVisibility(View.VISIBLE);
            } else {
                card_room_type.setVisibility(View.GONE);
            }
        }
    }

}
