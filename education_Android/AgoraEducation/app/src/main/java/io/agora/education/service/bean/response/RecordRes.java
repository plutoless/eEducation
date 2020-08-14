package io.agora.education.service.bean.response;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.util.List;

import io.agora.education.classroom.bean.channel.User;

public class RecordRes {

    public String recordId;
    public int uid;
    public long startTime;
    public long endTime;
    public String roomId;
    @Status
    public int status;
    public List<RecordDetail> recordDetails;

    @IntDef({Status.RECORDING, Status.FINISHED, Status.DOWNLOADING, Status.CONVERTING, Status.UPLOADING})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Status {
        int RECORDING = 1;
        int FINISHED = 2;
        int DOWNLOADING = 3;
        int CONVERTING = 4;
        int UPLOADING = 5;
    }

    public static class RecordDetail {
        public String userId;
        public String userName;
        @User.Role
        public int role;
        public String url;
    }

    public boolean isFinished() {
        return status == Status.FINISHED;
    }

    public String getTeacherRecordUrl() {
        if (recordDetails != null) {
            for (RecordDetail detail : recordDetails) {
                if (detail.role == User.Role.TEACHER) {
                    return detail.url;
                }
            }
        }
        return null;
    }

}
