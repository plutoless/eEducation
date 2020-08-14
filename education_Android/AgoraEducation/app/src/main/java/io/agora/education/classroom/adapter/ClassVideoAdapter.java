package io.agora.education.classroom.adapter;

import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.DiffUtil;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;

import java.util.List;

import io.agora.education.R;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.mediator.VideoMediator;
import io.agora.education.classroom.widget.RtcVideoView;

public class ClassVideoAdapter extends BaseQuickAdapter<User, ClassVideoAdapter.ViewHolder> {

    private int localUid;

    public ClassVideoAdapter(int localUid) {
        super(0);
        this.localUid = localUid;
        setDiffCallback(new DiffUtil.ItemCallback<User>() {
            @Override
            public boolean areItemsTheSame(@NonNull User oldItem, @NonNull User newItem) {
                return oldItem.uid == newItem.uid;
            }

            @Override
            public boolean areContentsTheSame(@NonNull User oldItem, @NonNull User newItem) {
                return oldItem.enableVideo == newItem.enableVideo
                        && oldItem.enableAudio == newItem.enableAudio
                        && oldItem.userName.equals(newItem.userName);
            }

            @Nullable
            @Override
            public Object getChangePayload(@NonNull User oldItem, @NonNull User newItem) {
                if (oldItem.enableVideo != newItem.enableVideo
                        || oldItem.enableAudio != newItem.enableAudio
                        || !oldItem.userName.equals(newItem.userName)) {
                    return true;
                } else {
                    return null;
                }
            }
        });
    }

    @NonNull
    @Override
    protected ViewHolder onCreateDefViewHolder(@NonNull ViewGroup parent, int viewType) {
        RtcVideoView item = new RtcVideoView(getContext());
        item.init(R.layout.layout_video_small_class, false);
        int width = getContext().getResources().getDimensionPixelSize(R.dimen.dp_95);
        int height = parent.getHeight() - parent.getPaddingTop() - parent.getPaddingBottom();
        item.setLayoutParams(new ViewGroup.LayoutParams(width, height));
        return new ViewHolder(item);
    }

    @Override
    protected void convert(@NonNull ViewHolder viewHolder, User user, @NonNull List<?> payloads) {
        super.convert(viewHolder, user, payloads);
        if (payloads.size() > 0) {
            viewHolder.convert(user);
        }
    }

    @Override
    protected void convert(@NonNull ViewHolder viewHolder, User user) {
        viewHolder.convert(user);

        if (user.uid == localUid) { // local render
            VideoMediator.setupLocalVideo(viewHolder.view);
        } else { // remote render
            VideoMediator.setupRemoteVideo(viewHolder.view, user.uid);
        }
    }

    static class ViewHolder extends BaseViewHolder {
        private RtcVideoView view;

        ViewHolder(RtcVideoView view) {
            super(view);
            this.view = view;
        }

        void convert(User user) {
            view.muteVideo(!user.isVideoEnable());
            view.muteAudio(!user.isAudioEnable());
            view.setName(user.userName);
        }
    }

}
