package io.agora.education.classroom.bean.msg;

import androidx.annotation.IntDef;

import com.google.gson.Gson;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.util.ArrayList;
import java.util.List;

import io.agora.education.classroom.bean.JsonBean;
import io.agora.education.classroom.bean.channel.Room;
import io.agora.education.classroom.bean.channel.User;

public class ChannelMsg extends JsonBean {

    @Cmd
    public int cmd;
    public Object data;

    @IntDef({Cmd.CHAT, Cmd.ACCESS, Cmd.ROOM, Cmd.USER, Cmd.REPLAY})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Cmd {
        /**
         * simple chat msg
         */
        int CHAT = 1;
        /**
         * user join or leave msg
         */
        int ACCESS = 2;
        /**
         * room attributes updated msg
         */
        int ROOM = 3;
        /**
         * user attributes updated msg
         */
        int USER = 4;
        /**
         * replay msg
         */
        int REPLAY = 5;
    }

    public static class ChatMsg {
        @Type
        public int type;
        public String userId;
        public String userName;
        public String message;
        public transient boolean isMe;

        @IntDef({Type.TEXT})
        @Retention(RetentionPolicy.SOURCE)
        public @interface Type {
            int TEXT = 1;
        }
    }

    public static class AccessMsg {
        public int total;
        public List<AccessState> list;

        public static class AccessState {
            public String userId;
            public String userName;
            @User.Role
            public int role;
            @State
            public int state;
        }

        @IntDef({ChatMsg.Type.TEXT})
        @Retention(RetentionPolicy.SOURCE)
        public @interface State {
            /**
             * user leave
             */
            int LEAVE = 0;
            /**
             * user join
             */
            int JOIN = 1;
        }
    }

    public static class RoomMsg {
        @Room.State
        public int courseState;
        public long startTime;
        @Room.AllChat
        public int muteAllChat;
        @Room.Board
        public int lockBoard;

        public void updateTo(Room room) {
            room.courseState = courseState;
            room.startTime = startTime;
            room.muteAllChat = muteAllChat;
            room.lockBoard = lockBoard;
        }
    }

    public static class CoVideoUserMsg extends ArrayList<User> {
    }

    public static class ReplayMsg extends ChatMsg {
        public String roomId;
        public String recordId;

        public ReplayMsg() {
            this.message = "replay recording";
        }
    }

    public <T> T getMsg(Class<T> tClass) {
        return new Gson().fromJson(new Gson().toJson(data), tClass);
    }

}
