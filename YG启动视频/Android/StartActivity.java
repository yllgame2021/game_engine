package com.yallagame.voicedemo;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.Window;
import android.view.WindowManager;
import com.opensource.svgaplayer.SVGACallback;
import com.opensource.svgaplayer.SVGAImageView;

public class StartActivity extends Activity {
    private SVGAImageView svgaImage;
    private Handler mHandler;

    private Runnable timeoutRunnable = new Runnable() {
        @Override
        public void run() {
            svgaImage.setCallback(null);
            startActivity(new Intent(StartActivity.this, MainActivity.class));
            finish();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        this.requestWindowFeature(Window.FEATURE_NO_TITLE);

        setContentView(R.layout.activity_start);

        //防止有些手机播放不了SVGA动画，设置开场最多停留4秒
        mHandler = new Handler();
        mHandler.postDelayed(timeoutRunnable, 4 * 1000);

        svgaImage = findViewById(R.id.SVGAImageView);
        svgaImage.setLoops(1);
        svgaImage.setCallback(new SVGACallback() {
            @Override
            public void onPause() {

            }

            @Override
            public void onFinished() {
                mHandler.removeCallbacks(timeoutRunnable); //取消任务
                startActivity(new Intent(StartActivity.this, MainActivity.class));
                finish();
            }

            @Override
            public void onRepeat() {
            }

            @Override
            public void onStep(int i, double v) {

            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mHandler.removeCallbacks(timeoutRunnable);
    }
}
