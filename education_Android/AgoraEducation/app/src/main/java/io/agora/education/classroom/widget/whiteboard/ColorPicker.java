package io.agora.education.classroom.widget.whiteboard;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Checkable;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.cardview.widget.CardView;
import androidx.core.content.ContextCompat;

import java.util.ArrayList;

import io.agora.education.R;

public class ColorPicker extends CardView {

    public ColorPicker(@NonNull Context context) {
        this(context, null);
    }

    public ColorPicker(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ColorPicker(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private final int[] colors = new int[12];
    private ArrayList<ColorView> colorViews = new ArrayList<>();
    private int selectIndex = -1;

    private OnClickListener onClickListener = v -> {
        int index = (int) v.getTag();
        select(index);
    };

    private void init(Context context) {
        inflate(context, R.layout.layout_color_picker, this);
        colors[0] = ContextCompat.getColor(context, R.color.red_FF0D19);
        colors[1] = ContextCompat.getColor(context, R.color.yellow_FF8F00);
        colors[2] = ContextCompat.getColor(context, R.color.yellow_FFCA00);
        colors[3] = ContextCompat.getColor(context, R.color.green_00DD52);
        colors[4] = ContextCompat.getColor(context, R.color.blue_007CFF);
        colors[5] = ContextCompat.getColor(context, R.color.purple_C455DF);
        colors[6] = ContextCompat.getColor(context, R.color.white);
        colors[7] = ContextCompat.getColor(context, R.color.gray_EEEEEE);
        colors[8] = ContextCompat.getColor(context, R.color.gray_CCCCCC);
        colors[9] = ContextCompat.getColor(context, R.color.gray_666666);
        colors[10] = ContextCompat.getColor(context, R.color.gray_333333);
        colors[11] = ContextCompat.getColor(context, R.color.black);

        LinearLayout llColors1 = findViewById(R.id.ll_colors_1);
        LinearLayout llColors2 = findViewById(R.id.ll_colors_2);

        for (int i = 0; i < colors.length; i++) {
            ColorView colorView = new ColorView(context);
            colorView.setTag(i);
            colorView.setFillColor(colors[i]);
            colorView.setOnClickListener(onClickListener);
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT);
            lp.weight = 1;
            if (i < 6) {
                llColors1.addView(colorView, lp);
            } else {
                llColors2.addView(colorView, lp);
            }

            colorViews.add(colorView);
        }

        select(0);
    }

    private void select(int index) {
        if (selectIndex != index) {
            if (selectIndex >= 0) {
                colorViews.get(selectIndex).setChecked(false);
            }
            colorViews.get(index).setChecked(true);
            selectIndex = index;
            if (changedListener != null) {
                changedListener.onColorChanged(getSelectColor());
            }
        }
    }

    private ColorChangedListener changedListener;

    public void setChangedListener(ColorChangedListener changedListener) {
        this.changedListener = changedListener;
        if (selectIndex >= 0) {
            if (changedListener != null) {
                changedListener.onColorChanged(getSelectColor());
            }
        }
    }

    public interface ColorChangedListener {
        void onColorChanged(int color);
    }

    public int getSelectColor() {
        return colors[selectIndex];
    }

    private class ColorView extends View implements Checkable {

        public ColorView(Context context) {
            super(context);
            init(context);
        }

        public ColorView(Context context, @Nullable AttributeSet attrs) {
            super(context, attrs);
            init(context);
        }

        public ColorView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
            super(context, attrs, defStyleAttr);
            init(context);
        }

        private Paint mStrokePaint, mFillPaint, mStrokeWhiteFillPaint;
        private float fillPadding;
        private float stokeWidth;
        private boolean isNeedWhiteStroke;

        public void setFillColor(int fillColor) {
            mStrokePaint.setAntiAlias(true);
            mFillPaint.setColor(fillColor);
            if (fillColor == ContextCompat.getColor(getContext(), R.color.white)) {
                isNeedWhiteStroke = true;
            }
            invalidate();
        }

        private void init(Context context) {
            mStrokePaint = new Paint();
            mStrokePaint.setStyle(Paint.Style.STROKE);
            stokeWidth = context.getResources().getDimension(R.dimen.dp_1);
            mStrokePaint.setStrokeWidth(stokeWidth);
            mStrokePaint.setAntiAlias(true);
            mStrokePaint.setColor(ContextCompat.getColor(context, R.color.colorAccent));

            mStrokeWhiteFillPaint = new Paint();
            mStrokeWhiteFillPaint.setStyle(Paint.Style.STROKE);
            mStrokeWhiteFillPaint.setStrokeWidth(stokeWidth);
            mStrokeWhiteFillPaint.setAntiAlias(true);
            mStrokeWhiteFillPaint.setColor(ContextCompat.getColor(context, R.color.gray_EEEEEE));

            mFillPaint = new Paint();
            mFillPaint.setStyle(Paint.Style.FILL);
            mFillPaint.setAntiAlias(true);
            mFillPaint.setColor(ContextCompat.getColor(context, R.color.transparent));

            fillPadding = context.getResources().getDimension(R.dimen.dp_3);
        }

        @Override
        protected void onDraw(Canvas canvas) {
            super.onDraw(canvas);
            int x = getWidth() / 2;
            int y = getHeight() / 2;
            int radius = Math.min(x, y);
            if (isChecked) {
                canvas.drawCircle(x, y, radius - stokeWidth, mStrokePaint);
            }
            if (isNeedWhiteStroke) {
                canvas.drawCircle(x, y, radius - fillPadding - stokeWidth, mFillPaint);
                canvas.drawCircle(x, y, radius - fillPadding, mStrokeWhiteFillPaint);
            } else {
                canvas.drawCircle(x, y, radius - fillPadding, mFillPaint);
            }
        }

        private boolean isChecked;

        @Override
        public void setChecked(boolean checked) {
            if (isChecked != checked) {
                isChecked = checked;
                invalidate();
            }
        }

        @Override
        public boolean isChecked() {
            return isChecked;
        }

        @Override
        public void toggle() {
            isChecked = !isChecked;
            invalidate();
        }

    }

}
