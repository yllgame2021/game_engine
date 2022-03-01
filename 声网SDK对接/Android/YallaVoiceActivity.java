package com.yallagame.voicedemo;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.KeyEvent;
import android.widget.Toast;

import org.egret.egretnativeandroid.EgretNativeAndroid;
import org.egret.runtime.launcherInterface.INativePlayer;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;

import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.models.ChannelMediaOptions;

public class YallaVoiceActivity extends Activity {
    private final String TAG = "MainActivity";
    public EgretNativeAndroid nativeAndroid;

    private String channelname = "";
    private int uid = -1;
    private String url = "";
    private String NowToken = "";
    private RtcEngine mRtcEngine;
    private static final int PERMISSION_REQ_ID_RECORD_AUDIO = 22;
    private final IRtcEngineEventHandler mRtcEventHandler = new IRtcEngineEventHandler() {
        @Override //网络连接状态已改变回调
        public void onConnectionStateChanged(int state, int reason) {
            super.onConnectionStateChanged(state, reason);
        }

        @Override  //加入频道回调
        public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
            nativeAndroid.callExternalInterface("onJoinChannelSuccess", NowToken);
        }

        @Override //重新加入频道回调
        public void onRejoinChannelSuccess(String channel, int uid, int elapsed) {
            super.onRejoinChannelSuccess(channel, uid, elapsed);
        }

        @Override //离开频道回调
        public void onLeaveChannel(RtcStats stats) {
            super.onLeaveChannel(stats);
            nativeAndroid.callExternalInterface("onLeaveChannel", NowToken);
        }

        @Override //用户角色已切换回调
        public void onClientRoleChanged(int oldRole, int newRole) {
            JSONObject json = new JSONObject();
            try {
                json.put("oldRole", oldRole);
                json.put("newRole", newRole);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            nativeAndroid.callExternalInterface("onClientRoleChanged", json.toString());
        }

        @Override //远端用户加入当前频道回调
        public void onUserJoined(int uid, int elapsed) {
            nativeAndroid.callExternalInterface("onUserJoined", String.valueOf(uid));
        }

        @Override //远端用户离开当前频道回调
        public void onUserOffline(int uid, int reason) {
            nativeAndroid.callExternalInterface("onUserOffline", String.valueOf(uid));
        }

        @Override //远端用户停止/恢复发送音频流回调
        public void onUserMuteAudio(int uid, boolean muted) {
            super.onUserMuteAudio(uid, muted);
            JSONObject json = new JSONObject();
            try {
                json.put("uid", uid);
                json.put("muted", muted);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            nativeAndroid.callExternalInterface("onUserMuteAudio", json.toString());
        }

        @Override //网络连接丢失回调
        public void onConnectionLost() {
            nativeAndroid.callExternalInterface("onConnectionLost", "");
        }

        @Override //Token 服务即将过期回调
        public void onTokenPrivilegeWillExpire(String token) {
            super.onTokenPrivilegeWillExpire(token);
            String newToken = getToken();
            if(newToken != null && newToken.length()!= 0){
                NowToken = newToken;
                mRtcEngine.renewToken(NowToken); //开启用户音量提示回调
            }else{
                showTips("获取Token失败");
            }
        }

        @Override //Token服务已经过期回调
        public void onRequestToken() {
            super.onRequestToken();
            String newToken = getToken();
            if(newToken != null && newToken.length()!= 0){
                ChannelMediaOptions option = new ChannelMediaOptions();
                option.publishLocalAudio = false;
                NowToken = newToken;
                mRtcEngine.joinChannel(NowToken, channelname, "Extra Optional Data", uid, option);
            }else{
                showTips("获取Token失败");
            }
        }

        @Override //通话质量回调，txQuality为上行，rxQuality为下行，uid 0为自己
        public void onNetworkQuality(int uid, int txQuality, int rxQuality) {
            JSONObject json = new JSONObject();
            try {
                json.put("uid", uid);
                json.put("txQuality", txQuality);
                json.put("rxQuality", rxQuality);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            nativeAndroid.callExternalInterface("onNetworkQuality", json.toString());
        }

        @Override
        /** 用户音量提示回调, 需要开启enableAudioVolumeIndication
         * AudioVolumeInfo中，uid 0为本地用户，其他为远端用户
         */
        public void onAudioVolumeIndication(AudioVolumeInfo[] speakers, int totalVolume) {
            JSONArray arrar = new JSONArray();
            for (AudioVolumeInfo info : speakers) {
                JSONObject json = new JSONObject();
                try {
                    json.put("uid", info.uid);
                    json.put("volume", info.volume);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                arrar.put(json);
            }
            nativeAndroid.callExternalInterface("onAudioVolumeIndication", arrar.toString());
        }
    };
    public boolean checkSelfPermission(String permission, int requestCode) {
        Log.e(TAG, "checkSelfPermission " + permission + " " + requestCode);
        int code = ContextCompat.checkSelfPermission(this, permission);
        Log.e(TAG, "获取权限返回码：" + code);
        if (code != PackageManager.PERMISSION_GRANTED) {
            return false;
        }
        return true;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onPause() {
        super.onPause();
        nativeAndroid.pause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        nativeAndroid.resume();
    }

    @Override
    public boolean onKeyDown(final int keyCode, final KeyEvent keyEvent) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            nativeAndroid.exitGame();
        }

        return super.onKeyDown(keyCode, keyEvent);
    }


    // 调用 Agora SDK 的方法初始化 RtcEngine。
    private void initializeAgoraEngine() {
        try {
            mRtcEngine = RtcEngine.create(getBaseContext(), getString(R.string.agora_app_id), mRtcEventHandler);
//            mRtcEngine.setAudioProfile(Constants.AUDIO_PROFILE_SPEECH_STANDARD, Constants.AUDIO_SCENARIO_CHATROOM_GAMING);//设置码率场景为开黑场景
            mRtcEngine.setChannelProfile(io.agora.rtc.Constants.CHANNEL_PROFILE_COMMUNICATION); //设置为语音通话场景，该场景自动开麦，无须上麦，并且可以设置扩音或者听筒
//            mRtcEngine.setChannelProfile(io.agora.rtc.Constants.CHANNEL_PROFILE_LIVE_BROADCASTING); //设置为直播场景，该场景默认只能听，不能说，需要上麦可说话，默认扩音，不能设置听筒
            String newToken = getToken();
            if(newToken != null && newToken != "null" && newToken.length()!= 0){
                ChannelMediaOptions option = new ChannelMediaOptions();
                option.publishLocalAudio = false;
                NowToken = newToken;
                mRtcEngine.joinChannel(NowToken, channelname, "Extra Optional Data", uid, option);
                mRtcEngine.setEnableSpeakerphone(true);//开启扬声器
                //          mRtcEngine.setClientRole(2);//1为主播，2为观众，默认加入房间之后为观众
                mRtcEngine.enableAudioVolumeIndication(200, 3, false); //开启用户音量提示回调
            }else{
                showTips("获取Token失败");
            }
        } catch (Exception e) {
            throw new RuntimeException("NEED TO check rtc sdk init fatal error\n" + Log.getStackTraceString(e));
        }
    }
    //获取Token
    private String getToken() {
        try {
            JSONObject json = new JSONObject();
            json.put("channelname", channelname);
            json.put("uid", uid);
            json.put("gameId", 101);

            final String postData = "&postdata="+ URLEncoder.encode(json.toString(), "utf-8");
            final URL url = new URL(this.url);
            Log.e(TAG, "参数为：" + postData + "url为：" + url);
            final String[] tokenStr = {""};
            Thread t = new Thread(new Runnable() {
                @Override
                public void run() {
                    tokenStr[0] = getHttpRequest(postData, url);
                }
            });
            t.start();
            t.join();
            return tokenStr[0];
        } catch (JSONException | MalformedURLException | UnsupportedEncodingException | InterruptedException e) {
            e.printStackTrace();
        }
        return "";
    }

    private String getHttpRequest(String postData, URL url ) {
        String tokenStr = "";
        try {
            // 打开一个HttpURLConnection连接
            HttpURLConnection urlConn = (HttpURLConnection) url.openConnection();
            // 设置连接超时时间
            urlConn.setConnectTimeout(3 * 1000);
            //设置从主机读取数据超时
            urlConn.setReadTimeout(5 * 1000);
            // Post请求必须设置允许输出 默认false
            urlConn.setDoOutput(true);
            //设置请求允许输入 默认是true
            urlConn.setDoInput(true);
            // Post请求不能使用缓存
            urlConn.setUseCaches(false);
            // 设置为Post请求
            urlConn.setRequestMethod("POST");
            //设置本次连接是否自动处理重定向
            urlConn.setInstanceFollowRedirects(true);
            // 配置请求Content-Type
            urlConn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            // 开始连接
            urlConn.connect();
            // 发送请求参数
            DataOutputStream dos = new DataOutputStream(urlConn.getOutputStream());
//            OutputStreamWriter dos = new OutputStreamWriter(urlConn.getOutputStream());

            dos.writeBytes(postData);
            dos.flush();
            dos.close();
            // 判断请求是否成功
            if (urlConn.getResponseCode() == 200) {
                // 获取返回的数据
                String result = streamToString(urlConn.getInputStream());
                Log.e(TAG, "获取成功"+result);
                tokenStr = (new JSONObject(result)).get("Data").toString();
            } else {
                Log.e(TAG, "获取失败"+urlConn.getResponseCode());
                tokenStr = "";
            }
            // 关闭连接
            urlConn.disconnect();
            return  tokenStr;
        } catch (Exception e) {
            e.printStackTrace();
            return tokenStr;
        }
    }
    /**
     * 将输入流转换成字符串
     *
     * @param is 从网络获取的输入流
     * @return
     */
    public String streamToString(InputStream is) {
        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            int len = 0;
            while ((len = is.read(buffer)) != -1) {
                baos.write(buffer, 0, len);
            }
            baos.close();
            is.close();
            byte[] byteArray = baos.toByteArray();
            return new String(byteArray);
        } catch (Exception e) {
            return null;
        }
    }

    // 加入频道
    private void joinChannel(String jsonStr) {
        try {
            JSONObject json = new JSONObject(jsonStr);
            this.channelname = json.get("channelname").toString();
            this.uid = Integer.parseInt(json.get("uid").toString());
            this.url =  json.get("url").toString();
            // 获取权限后，初始化 RtcEngine。
            if (checkSelfPermission(Manifest.permission.RECORD_AUDIO, PERMISSION_REQ_ID_RECORD_AUDIO)) {
                initializeAgoraEngine();
            }else{
                ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.RECORD_AUDIO}, PERMISSION_REQ_ID_RECORD_AUDIO);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    //扬声器/听筒切换
    private void setEnableSpeakerphone(String data){
        int index = Integer.parseInt(data);
        if(1 == index){
            mRtcEngine.setEnableSpeakerphone(false);//false为听筒
        }else if(2 == index){
            mRtcEngine.setEnableSpeakerphone(true);//true为扬声器
        }
    }
    //停止/恢复接收所有音频流(静音)
    private void muteAllRemoteAudioStreams(String data){
        int index = Integer.parseInt(data);
        if(1 == index){
            mRtcEngine.muteAllRemoteAudioStreams(false);//false 开始接收
        }else if(2 == index){
            mRtcEngine.muteAllRemoteAudioStreams(true);//true 停止接收
        }
    }
    //是否开启麦克风(闭麦)
    private void muteLocalAudioStream(String data){
        int index = Integer.parseInt(data);
        if(1 == index){
            mRtcEngine.muteLocalAudioStream(false);//false 开启麦克风
        }else if(2 == index){
            mRtcEngine.muteLocalAudioStream(true);//true 关闭麦克风
        }
    }
    //AI降噪
    private void enableDeepLearningDenoise(String data){
        int index = Integer.parseInt(data);
        if(1 == index){
            mRtcEngine.enableDeepLearningDenoise(true);//开启AI降噪
        }else if(2 == index){
            mRtcEngine.enableDeepLearningDenoise(false);//true 关闭AI降噪
        }
    }
    //设置玩家角色1为主播，2为观众，观众不能说话，上麦之后为主播
    private void setClientRole(String data){
        Log.d(TAG, "设置玩家角色为: " + data);
        int role = Integer.parseInt(data.toString());
        mRtcEngine.setClientRole(role);//1为主播，2为观众，观众不能说话，上麦之后为主播
    }
    //离开频道
    private void leaveChannel() {
        mRtcEngine.leaveChannel();
    }

    protected void setExternalInterfaces() {
        nativeAndroid.setExternalInterface("joinChannel", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String message) {
                joinChannel(message);
            }
        });
        nativeAndroid.setExternalInterface("setClientRole", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String message) {
                setClientRole(message);
            }
        });
        nativeAndroid.setExternalInterface("leaveChannel", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String message) {
                leaveChannel();
            }
        });
        nativeAndroid.setExternalInterface("setEnableSpeakerphone", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String message) {
                setEnableSpeakerphone(message);
            }
        });
        nativeAndroid.setExternalInterface("muteAllRemoteAudioStreams", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String message) {
                muteAllRemoteAudioStreams(message);
            }
        });
        nativeAndroid.setExternalInterface("muteLocalAudioStream", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String message) {
                muteLocalAudioStream(message);
            }
        });
        nativeAndroid.setExternalInterface("enableDeepLearningDenoise", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String message) {
                enableDeepLearningDenoise(message);
            }
        });
        nativeAndroid.setExternalInterface("sendToNative", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String message) {
                Log.d(TAG, "Get message: " + message);
                nativeAndroid.callExternalInterface("sendToJS", "Get message: " + message);
            }
        });
        nativeAndroid.setExternalInterface("@onState", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String message) {
                Log.e(TAG, "Get @onState: " + message);
            }
        });
        nativeAndroid.setExternalInterface("@onError", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String message) {
                Log.e(TAG, "Get @onError: " + message);
            }
        });
        nativeAndroid.setExternalInterface("@onJSError", new INativePlayer.INativeInterface() {
            @Override
            public void callback(String message) {
                Log.e(TAG, "Get @onJSError: " + message);
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mRtcEngine.destroy();
    }

    /**
     * 处理权限请求结果
     *
     * @param requestCode
     *          请求权限时传入的请求码，用于区别是哪一次请求的
     *
     * @param permissions
     *          所请求的所有权限的数组
     *
     * @param grantResults
     *          权限授予结果，和 permissions 数组参数中的权限一一对应，元素值为两种情况，如下:
     *          授予: PackageManager.PERMISSION_GRANTED
     *          拒绝: PackageManager.PERMISSION_DENIED
     */
    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        // ...
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQ_ID_RECORD_AUDIO) {
            boolean isAllGranted = true;
            for (int grant : grantResults) {
                if (grant != PackageManager.PERMISSION_GRANTED) {
                    isAllGranted = false;
                    break;
                }
            }
            if(isAllGranted) {
                initializeAgoraEngine();
            }else{
                showTips("获取麦克风权限失败，请手动去设置开启");
                initializeAgoraEngine();
            }
        }
    }

    public void showTips(String str){
        Toast.makeText(this, str, Toast.LENGTH_LONG).show();
    }
}
