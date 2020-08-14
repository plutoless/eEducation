package io.agora.sdk.listener;

import java.util.List;
import java.util.Map;

import io.agora.rtm.RtmChannelAttribute;
import io.agora.rtm.RtmChannelListener;
import io.agora.rtm.RtmChannelMember;
import io.agora.rtm.RtmClientListener;
import io.agora.rtm.RtmMessage;

public abstract class RtmEventListener implements RtmClientListener, RtmChannelListener {

    public void onJoinChannelSuccess(String channel) {

    }

    @Override
    public void onMemberCountUpdated(int i) {

    }

    @Override
    public void onAttributesUpdated(List<RtmChannelAttribute> list) {

    }

    @Override
    public void onMessageReceived(RtmMessage rtmMessage, RtmChannelMember rtmChannelMember) {

    }

    @Override
    public void onMemberJoined(RtmChannelMember rtmChannelMember) {

    }

    @Override
    public void onMemberLeft(RtmChannelMember rtmChannelMember) {

    }

    @Override
    public void onConnectionStateChanged(int i, int i1) {

    }

    @Override
    public void onMessageReceived(RtmMessage rtmMessage, String s) {

    }

    @Override
    public void onTokenExpired() {

    }

    @Override
    public void onPeersOnlineStatusChanged(Map<String, Integer> map) {

    }

}
