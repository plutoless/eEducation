package io.agora.education.service.bean.request;

import io.agora.education.classroom.bean.msg.PeerMsg;

public class CoVideoReq {

    @PeerMsg.CoVideoMsg.Type
    int type;

    public CoVideoReq(@PeerMsg.CoVideoMsg.Type int type) {
        this.type = type;
    }

}
