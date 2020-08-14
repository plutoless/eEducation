package io.agora.education.service.bean.request;

import io.agora.education.classroom.bean.channel.Room;

public class RoomEntryReq {

    public String userName;
    public String userUuid; // your user uuid
    public String roomName;
    public String roomUuid; // your room uuid
    @Room.Type
    public int type;
    public int role = 2; // 1.teacher 2.student

}
