package io.agora.education.service.bean.request;

import io.agora.education.classroom.bean.channel.User;

public class UserReq {

    @User.Chat
    public Integer enableChat;
    @User.Video
    public Integer enableVideo;
    @User.Audio
    public Integer enableAudio;
    @User.Board
    public Integer grantBoard;
    @User.CoVideo
    public Integer coVideo;

    public static UserReq fromUser(User user) {
        return new UserReq() {{
            enableChat = user.enableChat;
            enableVideo = user.enableVideo;
            enableAudio = user.enableAudio;
            grantBoard = user.grantBoard;
            coVideo = user.coVideo;
        }};
    }

}
