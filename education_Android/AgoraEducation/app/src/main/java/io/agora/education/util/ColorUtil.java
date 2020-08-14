package io.agora.education.util;

public class ColorUtil {

    public static int[] colorToArray(int color) {
        int[] colorArray = new int[3];
        colorArray[0] = color >> 16 & 0xFF;
        colorArray[1] = color >> 8 & 0xFF;
        colorArray[2] = color & 0xFF;
        return colorArray;
    }

}
