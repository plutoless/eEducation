package io.agora.education.service.bean.request;

import io.agora.education.classroom.bean.msg.ChannelMsg;

public class ChatReq {

    String message;
    @ChannelMsg.ChatMsg.Type
    int type;

    public ChatReq(String message, @ChannelMsg.ChatMsg.Type int type) {
        this.message = message;
        this.type = type;
    }

}
