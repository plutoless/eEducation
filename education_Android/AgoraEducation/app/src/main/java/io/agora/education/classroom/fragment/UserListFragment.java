package io.agora.education.classroom.fragment;

import android.view.View;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.listener.OnItemChildClickListener;

import java.util.List;

import butterknife.BindView;
import io.agora.education.R;
import io.agora.education.base.BaseFragment;
import io.agora.education.classroom.BaseClassActivity;
import io.agora.education.classroom.adapter.UserListAdapter;
import io.agora.education.classroom.bean.channel.User;

public class UserListFragment extends BaseFragment implements OnItemChildClickListener {

    @BindView(R.id.rcv_users)
    protected RecyclerView rcv_users;

    private UserListAdapter adapter;

    @Override
    protected int getLayoutResId() {
        return R.layout.fragment_user_list;
    }

    @Override
    protected void initData() {
        if (context instanceof BaseClassActivity) {
            adapter = new UserListAdapter(((BaseClassActivity) context).getLocal().uid);
            adapter.setOnItemChildClickListener(this);
        }
    }

    @Override
    protected void initView() {
        LinearLayoutManager layoutManager = new LinearLayoutManager(getContext());
        rcv_users.setLayoutManager(layoutManager);
        rcv_users.setAdapter(adapter);
    }

    public void setUserList(List<User> userList) {
        adapter.setNewData(userList);
    }

    @Override
    public void onItemChildClick(BaseQuickAdapter adapter, View view, int position) {
        if (context instanceof BaseClassActivity) {
            boolean isSelected = view.isSelected();
            switch (view.getId()) {
                case R.id.iv_btn_mute_audio:
                    ((BaseClassActivity) context).muteLocalAudio(isSelected);
                    break;
                case R.id.iv_btn_mute_video:
                    ((BaseClassActivity) context).muteLocalVideo(isSelected);
                    break;
            }
        }
    }

}
