package io.agora.education.classroom.fragment;

import android.content.Intent;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.widget.EditText;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.listener.OnItemChildClickListener;

import butterknife.BindView;
import io.agora.base.ToastManager;
import io.agora.base.network.RetrofitManager;
import io.agora.education.BuildConfig;
import io.agora.education.EduApplication;
import io.agora.education.R;
import io.agora.education.base.BaseCallback;
import io.agora.education.base.BaseFragment;
import io.agora.education.classroom.BaseClassActivity;
import io.agora.education.classroom.ReplayActivity;
import io.agora.education.classroom.adapter.MessageListAdapter;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.service.RecordService;
import io.agora.education.service.RoomService;
import io.agora.education.service.bean.request.ChatReq;

import static io.agora.education.classroom.bean.msg.ChannelMsg.ChatMsg.Type.TEXT;

public class ChatRoomFragment extends BaseFragment implements OnItemChildClickListener, View.OnKeyListener {

    @BindView(R.id.rcv_msg)
    protected RecyclerView rcv_msg;
    @BindView(R.id.edit_send_msg)
    protected EditText edit_send_msg;

    private MessageListAdapter adapter;
    private boolean isMuteAll;
    private boolean isMuteLocal;

    @Override
    protected int getLayoutResId() {
        return R.layout.fragment_chatroom;
    }

    @Override
    protected void initData() {
        adapter = new MessageListAdapter();
        adapter.setOnItemChildClickListener(this);
    }

    @Override
    protected void initView() {
        LinearLayoutManager layoutManager = new LinearLayoutManager(getContext());
        layoutManager.setStackFromEnd(true);
        rcv_msg.setLayoutManager(layoutManager);
        rcv_msg.setAdapter(adapter);
        edit_send_msg.setOnKeyListener(this);
    }

    public void setMuteAll(boolean isMuteAll) {
        this.isMuteAll = isMuteAll;
        setEditTextEnable(!(this.isMuteAll || isMuteLocal));
    }

    public void setMuteLocal(boolean isMuteLocal) {
        this.isMuteLocal = isMuteLocal;
        setEditTextEnable(!(this.isMuteAll || isMuteLocal));
    }

    private void setEditTextEnable(boolean isEnable) {
        runOnUiThread(() -> {
            if (edit_send_msg != null) {
                edit_send_msg.setEnabled(isEnable);
                if (isEnable) {
                    edit_send_msg.setHint(R.string.hint_im_message);
                } else {
                    edit_send_msg.setHint(R.string.chat_muting);
                }
            }
        });
    }

    public void addMessage(ChannelMsg.ChatMsg chatMsg) {
        runOnUiThread(() -> {
            if (rcv_msg != null) {
                adapter.addData(chatMsg);
                rcv_msg.scrollToPosition(adapter.getItemPosition(chatMsg));
            }
        });
    }

    @Override
    public void onItemChildClick(BaseQuickAdapter adapter, View view, int position) {
        if (view.getId() == R.id.tv_content) {
            Object object = adapter.getItem(position);
            if (object instanceof ChannelMsg.ReplayMsg) {
                ChannelMsg.ReplayMsg msg = (ChannelMsg.ReplayMsg) object;
                if (context instanceof BaseClassActivity) {
                    RetrofitManager.instance().getService(BuildConfig.API_BASE_URL, RecordService.class)
                            .record(EduApplication.getAppId(), ((BaseClassActivity) context).getRoomId(), msg.recordId)
                            .enqueue(new BaseCallback<>(data -> {
                                if (data.isFinished()) {
                                    String url = data.getTeacherRecordUrl();
                                    if (!TextUtils.isEmpty(url)) {
                                        Intent intent = new Intent(context, ReplayActivity.class);
                                        intent.putExtra(ReplayActivity.WHITEBOARD_ROOM_ID, data.roomId);
                                        intent.putExtra(ReplayActivity.WHITEBOARD_START_TIME, data.startTime);
                                        intent.putExtra(ReplayActivity.WHITEBOARD_END_TIME, data.endTime);
                                        intent.putExtra(ReplayActivity.WHITEBOARD_URL, url);
                                        startActivity(intent);
                                    }
                                } else {
                                    ToastManager.showShort(R.string.wait_record);
                                }
                            }));
                }
            }
        }
    }

    @Override
    public boolean onKey(View view, int keyCode, KeyEvent event) {
        if (!edit_send_msg.isEnabled()) {
            return false;
        }
        String text = edit_send_msg.getText().toString();
        if (KeyEvent.KEYCODE_ENTER == keyCode && KeyEvent.ACTION_DOWN == event.getAction() && text.trim().length() > 0) {
            if (context instanceof BaseClassActivity) {
                RetrofitManager.instance().getService(BuildConfig.API_BASE_URL, RoomService.class)
                        .roomChat(EduApplication.getAppId(), ((BaseClassActivity) context).getRoomId(), new ChatReq(text, TEXT))
                        .enqueue(new BaseCallback<>(data -> edit_send_msg.setText("")));
            }
            return true;
        }
        return false;
    }

}
