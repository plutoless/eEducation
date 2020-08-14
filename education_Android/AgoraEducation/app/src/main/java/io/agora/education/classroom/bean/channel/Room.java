package io.agora.education.classroom.bean.channel;

import androidx.annotation.IntDef;

import com.google.gson.Gson;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.util.List;

import io.agora.education.classroom.bean.JsonBean;

public class Room extends JsonBean {

    public String roomId;
    public String roomName;
    public String channelName;
    @Type
    public int type;
    @State
    public int courseState;
    public long startTime;
    @AllChat
    public int muteAllChat;
    public int isRecording;
    public String recordId;
    public long recordingTime;
    @Board
    public int lockBoard;
    public int onlineUsers;
    public List<User> coVideoUsers;

    @IntDef({Type.ONE2ONE, Type.SMALL, Type.LARGE})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Type {
        int ONE2ONE = 0;
        int SMALL = 1;
        int LARGE = 2;
    }

    @IntDef({State.END, State.BEGIN})
    @Retention(RetentionPolicy.SOURCE)
    public @interface State {
        int END = 0;
        int BEGIN = 1;
    }

    @IntDef({AllChat.ENABLE, AllChat.DISABLE})
    @Retention(RetentionPolicy.SOURCE)
    public @interface AllChat {
        int ENABLE = 0;
        int DISABLE = 1;
    }

    @IntDef({Board.UNLOCK, Board.LOCK})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Board {
        int UNLOCK = 0;
        int LOCK = 1;
    }

    public boolean isCourseBegin() {
        return courseState == State.BEGIN;
    }

    public boolean isAllChatEnable() {
        return muteAllChat == AllChat.ENABLE;
    }

    public boolean isBoardLock() {
        return lockBoard == Board.LOCK;
    }

    public Room copy() {
        return new Gson().fromJson(toJsonString(), Room.class);
    }

}
