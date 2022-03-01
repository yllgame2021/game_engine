# Unity3D（Android_Google）接入文档
SDK下载地址(请联系对接人获取)
## 环境
- Unity3D 2018.4
- Android Studio 4.1.3

## 1. 添加资源
### 1.1添加Unity资源
1. 导入C#文件夹下`YllSDK.unitypackage`包
2. 导入后，将 `YllSDK/Android/com.examp.yllgame` 包名修改为自己的包名，确定Android资源都勾选了Android
3. `Script/YllGameHelper.cs`文件，为我方提供的C#调用对应IOS和Android平台代码，供参考，可根据自己的需求进行修改调用。
4. `YallaActivity.java`文件，为我方实现的`YllGameHelper.cs`文件中对Java的调用，可根据需要修改。
5. C#代码开发完毕后，选择菜单`File-Build Settings`，切换到Android平台(可能需要下载Android Build模块)，然后点击`Build`按钮，选择合适的目录构建导出

### 1.2添加Android资源
1. 将 SDK的 aar 文件拷贝到项目的 `Android/unityLibrary/libs`  目录下
2. 将`strings.xml`放入到`Android/unityLibrary/src/main/res/values`里面
3. 修改`strings.xml`中`app_name`、`facebook_app_id`、`fb_login_protocol_scheme`为实际我方提供的值

## 1.Android项目配置
- 通过Android Studio打开Unity导出的Android项目
- 将
### 1.1.配置清单文件
- 在项目中的`AndroidManifest`中`application`key中添加以下代码

```xml
<!-- YallaSDK begin`````````````````````` -->
<activity
    android:name="com.facebook.FacebookActivity"
    android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />
<activity
    android:name="com.facebook.CustomTabActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />

        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />

        <data android:scheme="@string/fb_login_protocol_scheme" />
    </intent-filter>
</activity>

<meta-data
    android:name="com.facebook.sdk.ApplicationId"
    android:value="@string/facebook_app_id" />
<provider
    android:authorities="com.facebook.app.FacebookContentProvider12345678912345"
    android:name="com.facebook.FacebookContentProvider"
    android:exported="true"/>
<!-- 注册SDK中登陆广播 用户登陆信息通过该广播返回 -->
<receiver
    android:name=".ygapi.YGLoginReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="com.yllgame.sdk.loginReceiver" />
    </intent-filter>
</receiver>
<!-- Firebase -->
<service
    android:name=".MyFirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
<!-- YallaSDK end`````````````````````` -->
```

### 1.3配置gradle

- 修改`Android/UnityLibrary/build.gradle`

1. 在第二行添加
```java
    apply plugin: 'com.google.gms.google-services'
```

2.  将下面对应的value填入对应的key中

```js
android {
    repositories {
        flatDir {
            dirs 'libs'
        }
    }
    packagingOptions {
        doNotStrip "*/*/libijiami*.so"
    }
    compileOptions {
        targetCompatibility JavaVersion.VERSION_1_8
        sourceCompatibility JavaVersion.VERSION_1_8
    }
    defaultConfig {
        //显示声明的支持
        javaCompileOptions { annotationProcessorOptions { includeCompileClasspath = true } }
    }
}
```

- 在`dependencies`加入依赖库

```js
//Android X支持库  必须添加
api 'androidx.appcompat:appcompat:1.2.0'
api 'com.google.android.material:material:1.3.0'
//okhttp网络请求库 必须添加
api("com.squareup.okhttp3:okhttp:4.9.0")
//gson数据解析库 必须添加
api 'com.google.code.gson:gson:2.8.5'
//Facebook登陆依赖库 必须添加
api 'com.facebook.android:facebook-login:11.0.0'
//Facebook分享
api 'com.facebook.android:facebook-share:11.0.0'
//Google登陆依赖库 必须添加
api 'com.google.android.gms:play-services-auth:19.0.0'
api "com.google.android.gms:play-services-ads-identifier:17.0.0"
//Google支付依赖库 必须添加
api "com.android.billingclient:billing:4.0.0"
//数据库依赖库 必须添加
def room_version = "2.2.5"
api "androidx.room:room-runtime:$room_version"
api "androidx.room:room-compiler:$room_version"
api "net.zetetic:android-database-sqlcipher:4.4.2"
//数据统计依赖库 必须添加
api 'com.appsflyer:af-android-sdk:6.2.3@aar' 
api 'com.appsflyer:oaid:6.2.4' 
api 'com.android.installreferrer:installreferrer:2.2'
//FCM 推送相关
api platform('com.google.firebase:firebase-bom:26.4.0')
api 'com.google.firebase:firebase-messaging'
api 'com.google.firebase:firebase-analytics'
//Bugly
api 'com.tencent.bugly:crashreport:3.3.92'
api 'com.tencent.bugly:nativecrashreport:3.9.0'
//SDK基础库,需要将名称改为libs文件夹里面的实际名称
implementation(name: 'YllGameSdk_google_1.0.3', ext: 'aar')
```

### 1.4 配置Google推送环境

1. 将`google-services.json`文件(运营方提供)放入`Android/unityLibrary`目录，并检查其中配置是否与申请的一致
2. 修改`Android/build.gradle`文件，在`dependencies`中添加`classpath 'com.google.gms:google-services:4.3.3'`

## 2.SDK初始化与配置

### 2.1 SDK初始化
- 在`AndroidManifest.xml`的`application`中添加`android:name=“.MyAppLication"`
```xml
<application android:name=".MyAppLication">
```
- **注意：** 在`MyAppLication`的`Oncreator`中，为SDK初始化函数，修改自己对应的参数，完成SDK初始化
- 将 `UnityPlayerActivity`继承自`YallaActivity`,`YllSDKActivity`为封装给C#调用的接口文件，对应的调用方式在`YllGameHelper.cs`文件中，根据实际需要修改
- SDK初始化函数：
```java
/**
* 初始化
*
* @param application
* @param appId            游戏的gameAppId
* @param googleClientId   游戏的googleClientId
* @param appsFlyersDevKey 游戏的appsFlyersDevKey
* @param buglyId          游戏的buglyAppId
*/
YllGameSdk.getInstance().init(this, gameAppId, googleClientId, appsFlyersDevKey, buglyAppId); 
```

### 2.2 设置SDK网络模式(强/弱)
- 调用设置弱联网函数为：
``` java
 /**
 * 设置SDK联网默认模式 默认强联网模式
 *
 * @param mode  YGConstants.SDK_STRONG_NET 强联网 YGConstants.SDK_WEAK_NET 弱联网
 */
 YllGameSdk.getInstance().setNetMode(YGConstants.SDK_STRONG_NET);
```
### 2.3 设置SDK语言

```java
//调用设置SDK默认语言 ar：阿语 和 en：英语  如果没设置默认 就按照默认语言集合取第一个
YllGameSdk.getInstance().setLanguageList(Arrays.asList("ar", "en"));
YllGameSdk.getInstance().setLanguage("ar");
```
## 3.登陆与回调
### 3.1 登陆弹窗登陆
``` java
    YGLoginApi.getInstance().login(yallaActivity);
```

### 3.2 静默游客登录
``` java
    YGLoginApi.getInstance().silentGuestLogin();
```

如果配置正确，将会回调到 **com.yllsdk.yllgame.** ygapi.YGLoginReceiver中，参照其中的状态码，通知自己游戏逻辑。(加粗部分改为实际包名)

注：项目中所有登陆以及切换账号都会通过广播通知并且在下发用户信息。

**YGLoginReceiver为固定写法，需要放在项目包名.ygapi下**

返回登陆失败和Token失效建议游戏内再调一次登陆Api重试！
退出登录要退出到登陆界面并且清除本地用户信息

## 4.同步角色与回调
``` YGUserApi.getInstance().syncRoleInfo(); ```
``` java 
    /**
     * 同步角色信息
     *
     * @param roleId：角色id              ：int 必要参数
     * @param roleName：角色名称          ：string 必要参数
     * @param roleLevel：角色等级         ：int 必要参数
     * @param roleVipLevel：角色Vip等级   ：int 必要 没有默认0
     * @param serverId：角色所在服务器id   ：int 必要参数
     * @param roleCastleLevel：城堡等级   ：int 必要 没有默认0
     * @param callback：同步角色回调:       true 同步成功 false 同步失败
     */
     YGUserApi.getInstance().syncRoleInfo(roleId, roleName, roleLevel, roleVipLevel, serverId, roleCastleLevel, new YGBooleanCallBack() {
         @Override
         public void onResult(boolean b) {
             //回调，同步角色成功or失败
             if (b) {
                //同步成功
             } else {
                //同步失败
             }
         }
     });

```

## 5.Google充值/订阅与回调
### 5.1 Google充值
- SDK调起谷歌支付的函数为:
```java
/**
 * 支付
 *
 * @param activity      当前activity
 * @param roleId        角色id
 * @param roleServiceId 角色服务器Id
 * @param sku           商品的sku
 * @param cpNo          支付的订单号
 * @param cpTime        支付订单的创建时间
 * @param number        支付的数量 目前为1
 * @param amount        支付的金额
 * @param pointId       支付的充值点
 * @param listener      支付的回调
 */
 YGPayApi.pay(yallaActivity, roleID, roleServiceID, sku, System.currentTimeMillis() + "",
         System.currentTimeMillis() + "", 1 + "", price, pointID, new YGPaymentListener() {
             @Override
             public void paymentSuccess() {
                //充值成功
             }

             @Override
             public void paymentFailed(int code) {
                //充值失败
             }
         });
```

### 5.2 Google订阅
- SDK调起谷歌支付的函数为：`` YGPayApi.paySubs() ``
```java
/**
 * 支付
 *
 * @param activity      当前activity
 * @param roleId        角色id
 * @param roleServiceId 角色服务器Id
 * @param sku           商品的sku
 * @param cpNo          支付的订单号
 * @param cpTime        支付订单的创建时间
 * @param number        支付的数量 目前为1
 * @param amount        支付的金额
 * @param pointId       支付的充值点
 * @param listener      支付的回调
 */
 YGPayApi.paySubs(yallaActivity, roleID, roleServiceID, sku, System.currentTimeMillis() + "",
         System.currentTimeMillis() + "", 1 + "", price, pointID, new YGPaymentListener() {
             @Override
             public void paymentSuccess() {
                //订阅成功
             }

             @Override
             public void paymentFailed(int code) {
                //订阅失败
             }
         });
```
## 6.设置activity回调
### 该函数必须接入，有些第三方依赖库必须依赖Activity的onActivityResult的回调来传值和回调。在Activity中重写onActivityResult
```java 
@Override
protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
    YGCommonApi.setCallback(requestCode, resultCode, data);
    super.onActivityResult(requestCode, resultCode, data);
}
```
## 7.通用事件埋点
[YllSDK Android埋点文档](https://github.com/yllgame2021/yllgamesdk/blob/085c8905c886073dcd4e069ec2617084f2153600/%E5%9F%8B%E7%82%B9%E9%9C%80%E6%B1%82/Android/%E7%BB%9F%E8%AE%A1%E5%9F%8B%E7%82%B9Android.md)
```java
//event_name 参照埋点文档中的埋点名称，支持自定义
public static void onEvent(String eventName, String jsonData) {
    Map paramsMap = converJsonToMap(jsonData);
    YGEventApi.onEvent(eventName, paramsMap);
}
public static Map converJsonToMap(String json) {
    Gson gson = new GsonBuilder().serializeNulls().create();
    Map map = gson.fromJson(json, new TypeToken<Map>() {
    }.getType());
    return map;
}
```

## 8.Facebook好友列表和分享
### 8.1获取Facebook好友列表
- 获取Facebook好友列表的函数为：`` YGTripartiteApi.getInstance().getFacebookFriends ``
``` java 
    /**
     * 获取Facebook好友
     *
     * @param activity 当前的activity
     * @param callBack 好友列表回调
     */
     YGTripartiteApi.getInstance().getFacebookFriends(yallaActivity, new YGCallBack<List<GameFacebookFriendEntity>>(){
         @Override
         public void onSuccess(List<GameFacebookFriendEntity> gameFacebookFriendEntities) {
           //获取成功
         }

         @Override
         public void onFail(int i) {
            //获取失败
         }
     });
     return json;
```
### 8.2Facebook分享链接
- Facebook分享链接的函数为：`` YGTripartiteApi.getInstance().shareLink ``
``` java 
    /**
     * 分享链接
     *
     * @param activity 当前的activity
     * @param quote    分享的标题
     * @param url      分享的url
     * @param callback 分享回调
     */
     YGTripartiteApi.getInstance().shareLink(yallaActivity, desc, url, new FacebookCallback<Sharer.Result>(){

         @Override
         public void onSuccess(Sharer.Result result) {
         //分享成功
         }
         
         @Override
         public void onCancel() {
         //取消分享
         }

         @Override
         public void onError(FacebookException error) {
         //分享失败
         }
     });
 ```
 
### 8.3Facebook分享图片
- Facebook分享链接的函数为：`` YGTripartiteApi.getInstance().sharePhoto ``
``` java 
    /**
     * 分享图片
     *
     * @param activity 当前的activity
     * @param list     分享图片的集合
     * @param callback
     */
    public void sharePhoto(Activity activity, List<SharePhoto> list, FacebookCallback<Sharer.Result> callback)
```


## 9.其他API
### 9.1 打开客服界面
```java
YGUserApi.getInstance().showServiceChatView(yallaActivity, roleServiceID, roleID);
```
### 9.2 打开SDK设置界面
```java
YGUserApi.getInstance().showSettingsView(yallaActivity, roleServiceID, roleID);
```
### 9.3 打开修改昵称界面
```java
YGUserApi.getInstance().showUpdateNickNameDialog(yallaActivity, new UpdateUserNameListener() {
    public void onResult(boolean stat, String userName) {
        if(stat){
        //修改成功
        }
    }      
});
```
### 9.4 打开用户管理界面
```java
YGUserApi.getInstance().openAccountManager(yallaActivity);
```

### 9.5 检查账号绑定
```java
YGLoginApi.getInstance().checkBindStat(yallaActivity);
```
### 9.6 获取SDK版本
```java
YGLoginApi.getInstance().getVersionInfo();
```
### 9.7获取SDK 版本号Code
```java
YGLoginApi.getInstance().getSDKVersionCode();
```

## 10.推送

### 10.1推送处理

推送处理在`MyFirebaseMessagingService.java`文件中，判断是否为SDK内部消息，然后进行处理

### 10.2获取推送token

```js
GMessageApi.getInstance().getPushToken()
```

