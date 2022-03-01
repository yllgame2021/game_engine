# Android 语聊接入文档

## 前提条件
- Android Studio 3.0 或以上版本
- Android SDK API 等级 16 或以上
- Android 4.1 或以上版本的设备

## 1.集成 SDK
1. 在项目的 `/Gradle Scripts/build.gradle(Project: <projectname>)` 文件中添加 mavenCentral 支持：
```js
buildscript {
    repositories {
        ...
        mavenCentral()
    }
    ...
}

allprojects {
    repositories {
        ...
        mavenCentral()
    }
}
```

2. 在` /Gradle Scripts/build.gradle(Module: <projectname>.app)` 中添加如下依赖：
```js
...
dependencies {
 ...
 implementation 'io.agora.rtc:voice-sdk:3.5.0'
}
```

3. 添加权限
根据场景需要，在` /app/src/main/AndroidManifest.xml` 文件中添加如下行，获取相应的设备权限：
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yallagame.voicedemo">

   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
   <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   <uses-permission android:name="android.permission.BLUETOOTH" />
...
</manifest>
```

4. 防止代码混淆
在 `app/proguard-rules.pro` 文件中添加如下行，防止混淆 Agora SDK 的代码：
```js
-keep class io.agora.**{*;}
```

5.  在`app/res/values/string.xml`中 设置SDK KEY (运营方提供)
```xml
<resources>
    <string name="app_name">voicedemo</string>
    <string name="agora_app_id">[运营方提供]</string>
</resources>
```

## 2.代码集成
1. 将`YallaVoiceActivity.java`放入`app/java/包名`目录下
2. 将`MainActivity`继承自`YallaVoiceActivity`
3. 删除`MainActivity`中的如下声明:
```java
//    private final String TAG = "MainActivity";
//    public EgretNativeAndroid nativeAndroid;
```
4. 修改`MainActivity`中的`setExternalInterfaces`接口如下：
```java
protected void setExternalInterfaces() {
    super.setExternalInterfaces();
}
```
5. 将`YllGameHelp.ts` 文件放入对应的白鹭项目路径中

## 3.API
我们已经封装好了Android和IOS的底层实现，用户只需要调用`YllGameHelp.ts`文件接口即可。
### 3.1 事件（用户触发）
```js
/**
 * 加入房间
 * @param channelname  房间名
 * @param uid    角色ID
 * @param token  Token
 */
public static joinChannel(channelname:String, uid:string, url:string){
    var Obj = {
        channelname: channelname,
        uid: uid,
        url:url
    };
    var jsonStr = JSON.stringify(Obj)
    egret.ExternalInterface.call("joinChannel", jsonStr);
}

/**
 * 离开房间
 */
public static leaveChannel(){
    egret.ExternalInterface.call("leaveChannel", "");
}

/**
 * 开启和关闭声音(静音)
 * @param index 1为开启接收(取消静音)，2为关闭接收(静音)
 */
public static muteAllRemoteAudioStreams(index:number){
    egret.ExternalInterface.call("muteAllRemoteAudioStreams", String(index));
}

/**
 * 开启和关闭麦克风
 * @param index  1为开启麦克风，2为关闭麦克风
 */
public static muteLocalAudioStream(index:number){
    egret.ExternalInterface.call("muteLocalAudioStream", String(index));
}

/**
 * 设置客户端角色
 * @param role 1为主播，2为观众，
 * 观众不能说话，上麦之后为主播
 */
public static setClientRole(role:string){
    egret.ExternalInterface.call("setClientRole", role);
}

/**
 * 开启和关闭AI降噪
 * @param index 1为开启AI降噪，2为关闭AI降噪
 */
public static enableDeepLearningDenoise(index:number){
    egret.ExternalInterface.call("enableDeepLearningDenoise", String(index));
}

/**
 * 开启和关闭扬声器
 * @param index 1为关闭扬声器(听筒)，2为开启扬声器
 * 该方法只有1V1生效，多人语音中，只能开启扩音
 */
public static setEnableSpeakerphone(index:number){
    egret.ExternalInterface.call("setEnableSpeakerphone", String(index));
}

/**
 * 获取Token
 * 获取Token之后才可以加入房间
 */
public static getToken(postData:String, url:String){
    var paramData = {
        postData:postData,
        url: url
    }
    var jsonStr = JSON.stringify(paramData)
    egret.ExternalInterface.call("getToken", jsonStr);
}
```

### 3.2 回调（SDK触发）
```js
public callBackFunctionList = {
    /**
     * 自己加入房间成功回调
     * @param NowToken 当前房间的token
     */
    onJoinChannelSuccess:Function,

    /**
     * 自己离开房间成功回调
     * @param NowToken 当前房间的token
     */
    onLeaveChannel:Function,

    /**
     * 其他玩家加入房间回调
     * @param uid 玩家uid
     */
    onUserJoined:Function,

    /**
     * 其他玩家离开房间回调
     * @param uid 玩家uid
     */
    onUserOffline:Function,

    /**
    * 其他玩家停止/恢复发送音频流回调
    * @param json ["uid":0,"muted":0]
    * @param uid 0为自己
    * @param muted true静音，false开启麦克风
    */
    onUserMuteAudio:Function,

    /**
     *通话质量回调
    * @param json ["uid":0,"txQuality":0, "rxQuality":0]
    * @param uid 0为自己
    * @param txQuality 上行质量
    * @param rxQuality 下行质量
    * 0：质量未知
    * 1：质量极好
    * 2：用户主观感觉和极好差不多，但码率可能略低于极好
    * 3：用户主观感受有瑕疵但不影响沟通
    * 4：勉强能沟通但不顺畅
    * 5：网络质量非常差，基本不能沟通
    * 6：网络连接断开，完全无法沟通
    * 7：SDK 正在探测网络质量
    */
    onNetworkQuality:Function,

    /**
     * 音浪回调
     * @param json json数组[{"uid":0,"volume":255}, {"uid":1,"volume":255}]
     * uid 0为本地用户，其他为远端用户
     * volume 混合后音量 0-255
     */
    onAudioVolumeIndication:Function,

    /*
    * 网络连接丢失回调
    */
    onConnectionLost:Function,
}
```
- 回调需要在界面初始化的时候注册监听
```js
/**
 * 注册回调监听
 * @param funcname  回调方法名称
 * @param func      回调方法体
 */
public static addLister(funcname:string, func:any) {
    egret.ExternalInterface.addCallback(funcname, func);
}
```
例子：

```js
//自己加入房间成功回调
YllGameHelp.addLister("onJoinChannelSuccess",(message:string)=> {
    console.log("加入房间成功，房间Token为: " + message);
})
```
