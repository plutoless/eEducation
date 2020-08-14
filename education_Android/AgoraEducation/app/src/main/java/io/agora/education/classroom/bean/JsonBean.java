package io.agora.education.classroom.bean;

import com.google.gson.Gson;

import java.io.Serializable;

public class JsonBean implements Serializable {

    public String toJsonString() {
        return new Gson().toJson(this);
    }

    public static <T extends JsonBean> T fromJson(String jsonStr, Class<T> classType) {
        return new Gson().fromJson(jsonStr, classType);
    }

}
