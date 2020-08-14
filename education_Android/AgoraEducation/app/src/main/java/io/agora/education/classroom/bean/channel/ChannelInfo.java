package io.agora.education.classroom.bean.channel;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.List;

import io.agora.education.classroom.bean.JsonBean;
import io.agora.log.LogManager;

public class ChannelInfo extends JsonBean {

    private final LogManager log = new LogManager(this.getClass().getSimpleName());

    private volatile Room room;
    private volatile User local;
    private volatile User teacher;
    private volatile List<User> others;

    public ChannelInfo(@NonNull User local) {
        this.local = local;
        this.others = new ArrayList<>();
    }

    @Nullable
    public Room getRoom() {
        return room;
    }

    @NonNull
    public User getLocal() {
        return local;
    }

    @Nullable
    public User getTeacher() {
        return teacher;
    }

    @NonNull
    public List<User> getOthers() {
        return others;
    }

    public boolean updateRoom(@NonNull Room room) {
        Gson gson = new Gson();
        String json = gson.toJson(room);
        if (TextUtils.equals(json, gson.toJson(this.room))) {
            return false;
        }
        log.d("updateRoom %s", json);
        this.room = room;
        return true;
    }

    public boolean updateLocal(@Nullable User local) {
        Gson gson = new Gson();
        String json = gson.toJson(local);
        if (TextUtils.equals(json, gson.toJson(this.local))) {
            return false;
        }
        log.d("updateLocal %s", json);
        if (local == null) {
            // process local to audience
            User localCopy = this.local.copy();
            localCopy.disableCoVideo(true);
            this.local = localCopy;
        } else {
            this.local = local;
        }
        return true;
    }

    public boolean updateTeacher(@Nullable User teacher) {
        Gson gson = new Gson();
        String json = gson.toJson(teacher);
        if (TextUtils.equals(json, gson.toJson(this.teacher))) {
            return false;
        }
        log.d("updateTeacher %s", json);
        if (teacher == null) {
            // process teacher to audience
            User teacherCopy = this.teacher.copy();
            teacherCopy.disableCoVideo(true);
            this.teacher = teacherCopy;
        } else {
            this.teacher = teacher;
        }
        return true;
    }

    public boolean updateOthers(@NonNull List<User> others) {
        Gson gson = new Gson();
        String json = gson.toJson(others);
        if (TextUtils.equals(json, gson.toJson(this.others))) {
            return false;
        }
        log.d("updateOthers %s", json);
        this.others.clear();
        this.others.addAll(others);
        return true;
    }

}
