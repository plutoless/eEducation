package io.agora.education.classroom.bean.msg;

import androidx.annotation.IntDef;

import com.google.gson.Gson;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.education.classroom.bean.JsonBean;

public class PeerMsg extends JsonBean {

    @Cmd
    public int cmd;
    public Object data;

    @IntDef({Cmd.CO_VIDEO})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Cmd {
        /**
         * co-video operation msg
         */
        int CO_VIDEO = 1;
    }

    public static class CoVideoMsg {
        @Type
        public int type;
        public String userId;
        public String userName;

        @IntDef({Type.APPLY, Type.REJECT, Type.CANCEL, Type.ACCEPT, Type.ABORT, Type.EXIT})
        @Retention(RetentionPolicy.SOURCE)
        public @interface Type {
            /**
             * student apply co-video
             */
            int APPLY = 1;
            /**
             * teacher reject apply
             */
            int REJECT = 2;
            /**
             * student cancel apply
             */
            int CANCEL = 3;
            /**
             * teacher accept apply
             */
            int ACCEPT = 4;
            /**
             * teacher abort co-video
             */
            int ABORT = 5;
            /**
             * student exit co-video
             */
            int EXIT = 6;
        }
    }

    public <T> T getMsg(Class<T> tClass) {
        return new Gson().fromJson(new Gson().toJson(data), tClass);
    }

}
