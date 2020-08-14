package io.agora.education.classroom.adapter;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.agora.education.R;
import io.agora.education.classroom.bean.channel.User;

public class UserListAdapter extends BaseQuickAdapter<User, UserListAdapter.ViewHolder> {

    private int localUid;

    public UserListAdapter(int localUid) {
        super(R.layout.item_user_list);
        this.localUid = localUid;
        addChildClickViewIds(R.id.iv_btn_mute_audio, R.id.iv_btn_mute_video);
    }

    @Override
    protected void convert(@NonNull ViewHolder viewHolder, User user) {
        viewHolder.tv_name.setText(user.userName);
        if (user.uid == localUid) {
            viewHolder.iv_btn_grant_board.setVisibility(View.VISIBLE);
            viewHolder.iv_btn_mute_audio.setVisibility(View.VISIBLE);
            viewHolder.iv_btn_mute_video.setVisibility(View.VISIBLE);
            viewHolder.iv_btn_grant_board.setSelected(user.isBoardGrant());
            viewHolder.iv_btn_mute_audio.setSelected(user.isAudioEnable());
            viewHolder.iv_btn_mute_video.setSelected(user.isVideoEnable());
        } else {
            viewHolder.iv_btn_grant_board.setVisibility(View.GONE);
            viewHolder.iv_btn_mute_video.setVisibility(View.GONE);
            viewHolder.iv_btn_mute_audio.setVisibility(View.GONE);
        }
    }

    static class ViewHolder extends BaseViewHolder {
        @BindView(R.id.tv_name)
        TextView tv_name;
        @BindView(R.id.iv_btn_grant_board)
        ImageView iv_btn_grant_board;
        @BindView(R.id.iv_btn_mute_audio)
        ImageView iv_btn_mute_audio;
        @BindView(R.id.iv_btn_mute_video)
        ImageView iv_btn_mute_video;

        ViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }

}
