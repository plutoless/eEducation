package io.agora.education.classroom.strategy;

import java.util.List;

import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;
import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.bean.msg.PeerMsg;

public interface ChannelEventListener {

    void onChannelInfoInit();

    void onRoomChanged(Room room);

    void onLocalChanged(User local);

    void onCoVideoUsersChanged(List<User> users);

    void onChannelMsgReceived(ChannelMsg msg);

    void onPeerMsgReceived(PeerMsg msg);

    void onMemberCountUpdated(int count);

}
