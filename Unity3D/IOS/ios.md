# Unity3D（IOS）接入文档

SDK下载地址(请联系对接人获取)

## 接入前环境配置

**需要安装pod管理工具**
- Xcode 12.0 +
- Unity 2018.4
- ios 9.0 +

## 1.IOS项目配置

### 1.1Unity配置
1. 导入C#文件夹下`YllSDK.unitypackage`包
2. `YllGameHelper.cs`文件，为我方提供的C#调用对应IOS和Android平台代码，供参考，可根据自己的需求进行修改调用。
3. `YllGameHelper.mm`文件，为我方实现的`YllGameHelper.cs`文件中对OC的调用，可根据需要修改。
3. C#代码开发完毕后，选择菜单`File-Build Settings`，切换到IOS平台(可能需要下载IOS Build模块)，然后点击`Build`按钮，选择合适的目录构建导出

### 1.2 IOS配置
1. 将SDK目录下的 `YllGameSDK.framework` 文件夹和`YllGameResource.bundle`拷贝到导出IOS项目的根目录下(以下简称IOS目录)
2. 使用命令行cd到IOS目录下，执行`pod init` 命令，会自动创建pod管理文件podfile(如果没有pod管理工具，则需要自行安装pod管理工具)
3. 打开podfile文件，在`target 'Unity-iPhone'` `use_frameworks!`下面添加以下依赖库
```obj-c
pod 'FBSDKLoginKit', '~> 9.1.0'
pod 'FBSDKShareKit', '~> 9.1.0'
pod 'GoogleSignIn', '~> 5.0.2'
pod 'AppsFlyerFramework', '~> 6.2.5'
pod 'Firebase/Analytics', '~> 6.34.0'
pod 'Firebase/Messaging', '~> 6.34.0'
pod 'Bugly', '~> 2.5.90'
```
3. 取消 `platform :ios, '9.0'`注释,取消 `use_frameworks` 前面的注释，然后保存podfile文件
4. 回到刚才的命令行窗口，执行`pod install`命令，会自动下载所添加的库，并生成 `project.xcworkspace`文件
5.  双击  `project.xcworkspace` 打开项目，右键项目，选择 Add File to "XXX" , 选择第一步添加的framework和bundle，勾选 "Copy items if needed"，选择 "Create groups"，targets勾选iPhone工程。
6. 修改项目`targets->build Setting-> IOS Deployment Target`为 `ios 9.0`
7. 修改项目`Target`-->`building settings`中搜索`Header Search Paths`和`Other Linker Flags` ，添加`$(inherited)`。
8. 右键根目录下`info.list`，选择`open AS`->`Scoure Code`，在dict中添加以下值(举例如果FB AppID为**123456789123456**)
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>fb123456789123456</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>[REVERSED_CLIENT_ID]</string>
        </array>
    </dict>
</array>
<key>CFBundleVersion</key>
<string>$(CURRENT_PROJECT_VERSION)</string>
<key>CLIENT_ID</key>
<string>[CLIENT_ID]</string>
<key>FacebookAdvertiserIDCollectionEnabled</key>
<string>TRUE</string>
<key>FacebookAppID</key>
<string>123456789123456</string>
<key>FacebookAutoLogAppEventsEnabled</key>
<string>TRUE</string>
<key>FacebookDisplayName</key>
<string>YllGameDemo</string>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>fbapi</string>
    <string>fbapi20130214</string>
    <string>fbapi20130410</string>
    <string>fbapi20130702</string>
    <string>fbapi20131010</string>
    <string>fbapi20131219</string>
    <string>fbapi20140410</string>
    <string>fbapi20140116</string>
    <string>fbapi20150313</string>
    <string>fbapi20150629</string>
    <string>fbapi20160328</string>
    <string>fbauth</string>
    <string>fb-messenger-share-api</string>
    <string>fbauth2</string>
    <string>fbshareextension</string>
</array>
<key>LSRequiresIPhoneOS</key>
<true/>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photos will be used in Personal info, Discovery, Message and Album.</string>
<key>NSUserTrackingUsageDescription</key>
<string>سيتم استخدام بياناتك لتزويدك بخدمة أفضل وتجربة إعلانية مخصصة</string>
<key>REVERSED_CLIENT_ID</key>
<string>[REVERSED_CLIENT_ID]</string>
```
**注意**
- 需要将 `CFBundleURLSchemes` 值替换为"fb"+申请的Facebook Appid(fb123456789123456)
- 需要将 `FacebookAppID`值替换为申请的Facebook Appid(123456789123456)
- 需要将在 `FacebookDisplayName` 值修改为应用名称。
- 在 `[CFBundleURLSchemes]` 键内的 <array><string> 中，将 `[REVERSED_CLIENT_ID]`替换为反向的客户ID
- 在 `CLIENT_ID` 键内的 <string> 中，将 `[CLIENT_ID]` 替换为客户端ID
- 在 `REVERSED_CLIENT_ID` 键内的 <string> 中，将 `[REVERSED_CLIENT_ID]` 替换为反向的客户ID
- `NSPhotoLibraryUsageDescription` 为调用相册权限的描述，可以自行修改
- `NSUserTrackingUsageDescription` 为IDFA权限的描述，可以自行修改

### 1.3 配置登陆和推送
1. 添加以下几种登陆方式(苹果账号登陆&GameCenter登陆)
![登陆配置和推送配置](img/Signing&Capabilities.jpg)
2. 右键项目，选择 Add File to "XXX" , 选择`GoogleService-Info.plist`，勾选 "Copy items if needed"，选择 "Create groups"，targets勾选iPhone工程。

### 1.4 **新增Bugly配置**

1. 下载[自动配置符号表工具包](https://bugly.qq.com/v2/sdk?id=6ecfd28d-d8ea-4446-a9c8-13aed4a94f04)

2. 配置[Java运行环境](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)(JRE或JDK版本需要>=1.6)

3. 把工具包buglySymbollOS.jar 保存在`~/bin`目录下, (没有bin文件夹, 请自行创建):

4. 在Xcode工程对应的Target的Build Phases中新增Run Scrpit Phase

5. 打开工具包`dSYM_upload.sh`, 复制所有内容, 在新增的Run Scrpit Phase 中粘贴

6. 修改新增的Run Script中的<YOUR_APP_ID>为您的App ID, <YOUR_APP_KEY>为您的App key, <YOUR_BUNDLE_ID>为App的Bundle Id

7. 脚本默认的Debug模式及模拟器编译情况下不会上传符号表, 在需要上传的时候, 请修改下列选项</br>
Debug模式编译是否上传, 1 = 上传 0 = 不上传, 默认不上传</br>
UPLOAD_DEBUG_SYMBOLS=0</br>
模拟器编译是否上传. 1 = 上传 0 = 不上传, 默认不上传</br>
UPLOAD_SIMULATOR_SYMBOLS=0

- 至此，自动上传符号表脚本配置完毕，Bugly 会在每次 Xcode 工程编译后自动完成符号表配置工作。

## 2.SDK初始化
- 可参考我方提供的`UnityAppController.mm`文件

- 在`UnityAppController.mm`中添加头文件引用

```obj-c
#import <YllGameSDK/YllGameSDK.h>
```

- 在`UnityAppController.mm`的`didFinishLaunchingWithOptions`方法中添加以下代码
- **注意！**
需要将其中的`gameAppId`，`appleAppId`，`appsFlyerDevKey`，`buglyAppId`换成自己项目的!
```obj-c
//YllSDK-------Begin。appid，key这些参数需要联系游戏发行方获取，改为自己的！
[YllGameSDK getInstance].gameAppId = @"gameAppId";
[YllGameSDK getInstance].appleAppId = @"appleAppId";
[YllGameSDK getInstance].appsFlyerDevKey = @"appsFlyerDevKey";
/// languageList 语言集合  游戏支持语言集合 现支持 ar 阿语 en 英语 该集合默认第一个是SDK的默认语言
[YllGameSDK getInstance].languageList = @[@"ar", @"en"];
/// 当前设置的语言, 不传以 languageList 的第一个值为默认语言, 若 languageList 为 null, 默认为 ar
[YllGameSDK getInstance].localLanguage = @"ar";

//设置Bugly AppID，初始化会在yg_init内部调用
[YllGameSDK getInstance].buglyAppId = @"buglyAppId";

// 设置完以上属性之后再调用该方法, 不然对于语区统计会有影响
[[YllGameSDK getInstance] yg_application:application didFinishLaunchingWithOptions:launchOptions];
// 初始化SDK
[[YllGameSDK getInstance] yg_init];
//推送冷启动的处理
if (launchOptions && [launchOptions.allKeys containsObject:UIApplicationLaunchOptionsRemoteNotificationKey]) {
     NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
}
//YallaSDK------end
```

- 在`UnityAppController.mm`中添加以下方法
```obj-c
//YllSDK-----fun Begin-------
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return [[YllGameSDK getInstance] yg_application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[YllGameSDK getInstance] yg_application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[YllGameSDK getInstance] yg_application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}
//YallaSDK---------func End
```
- 将下列方法的实现放入对应的方法内
```obj-c
- (BOOL)application:(UIApplication*)app openURL:(NSURL*)url options:(NSDictionary<NSString*, id>*)options
{
    return [[YllGameSDK getInstance] yg_application:app openURL:url options:options];
}
- (void)applicationDidEnterBackground:(UIApplication*)application
    [[YllGameSDK getInstance] yg_applicationDidEnterBackground:application];
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[YllGameSDK getInstance] yg_applicationDidBecomeActive:application];
}
- (void)applicationWillTerminate:(UIApplication *)application {
    [[YllGameSDK getInstance] yg_applicationWillTerminate:application];
}
```

## 3.SDK登陆和同步角色
- 具体调用方式，可参考`项目/Libraries/YllSDK/IOS/YllGameHelper.m`文件
### 3.1 设置SDK网络模式
```obj-c
//设置网络模式,1为强网，2为弱网
void OCsetNetModel (int model){
    int NetModel = model;
    if (NetModel == 1) {
        [YllGameSDK getInstance].netMode = YGStrongNet;
    }
    else if (NetModel == 2) {
        [YllGameSDK getInstance].netMode = YGWeakNet;
    }
}
```
### 3.2 设置SDK语言
```obj-c
//设置语言
void OCsetLanguage(char *language){
    NSString *lan = [NSString stringWithCString:language encoding:NSUTF8StringEncoding];
    [YllGameSDK getInstance].localLanguage = lan;
}
```

### 3.3 登陆与回调
- 登陆分两种，静默登陆和弹窗登陆，静默登陆调用的是弹窗登陆中的游客登陆。根据自己需求使用。
1. 弹窗登陆
```obj-c
void OClogin (){
    [[YllGameSDK getInstance] yg_loginWithUserInfo:^(YGUserInfoModel * userInfoModel) {
        /** 
        请根据返回 userInfoModel 内 state 的不同枚举值进行实际业务场景处理
        当 userInfoModel.state == YGLoginSuccess || userInfoModel.state == YGChangeNickName 时, userInfoModel 里面的其他属性才有值
        弱网模式下的切换账号的成功或失败发送的 state 也是 YGLoginSuccess 和 YGLoginFailure
        typedef NS_ENUM(NSInteger, YGState) {
            YGTokenOverdue,   // token过期
            YGChangeNickName, // 修改昵称成功
            YGLoginSuccess,   // 登录成功
            YGLoginFailure,   // 登录失败
            YGAccountBlock,   // 账号被封
            YGAccountRemote,  // 异地登录
            YGLogout,         // 退出登录
        };
        */
     }];
}
```
2. 游客登陆(静默登陆)
```obj-c
void OCloginGuest (){
    [[YllGameSDK getInstance] yg_silentGuestLoginWithUserInfo:^(YGUserInfoModel * userInfoModel) {
        /** 
        请根据返回 userInfoModel 内 state 的不同枚举值进行实际业务场景处理
        当 userInfoModel.state == YGLoginSuccess || userInfoModel.state == YGChangeNickName 时, userInfoModel 里面的其他属性才有值
        弱网模式下的切换账号的成功或失败发送的 state 也是 YGLoginSuccess 和 YGLoginFailure
        typedef NS_ENUM(NSInteger, YGState) {
            YGTokenOverdue,   // token过期
            YGChangeNickName, // 修改昵称成功
            YGLoginSuccess,   // 登录成功
            YGLoginFailure,   // 登录失败
            YGAccountBlock,   // 账号被封
            YGAccountRemote,  // 异地登录
            YGLogout,         // 退出登录
        };
        */
     }];
}
```

**返回登陆失败和Token失效建议游戏内再调一次登陆Api重试**
**退出登录要退出到登陆界面并且清除本地用户信息!**

### 3.4同步角色(**必须在登陆成功之后调用，否则同步不会成功**)
```obj-c
//同步角色
void OCsyncRoleInfo (char *rId, char *rName, char *rLevel, char *rVipLevel, char *sId , char *rCastleLevel)
{
    NSString *roleid = [NSString stringWithCString:rId encoding:NSUTF8StringEncoding];
    NSString *roleName = [NSString stringWithCString:rName encoding:NSUTF8StringEncoding];
    NSString *roleLevel = [NSString stringWithCString:rLevel encoding:NSUTF8StringEncoding];
    NSString *roleVipLevel = [NSString stringWithCString:rVipLevel encoding:NSUTF8StringEncoding];
    NSString *serverId = [NSString stringWithCString:sId encoding:NSUTF8StringEncoding];
    NSString *roleCastleLevel = [NSString stringWithCString:rCastleLevel encoding:NSUTF8StringEncoding];
    
    [[YllGameSDK getInstance] yg_synchroRoleWithRoleId:roleid roleName:roleName roleLevel:roleLevel roleVipLevel:roleVipLevel gameServerId:serverId roleCastleLevel:roleCastleLevel completeHandle:^(NSError * _Nonnull error) {
        if (!error) {
            //同步角色回调
        }
    }];
}
```

## 4.充值和订阅
### 4.1 充值
```obj-c
void OCpay (char *roleID, char *roleServiceID, char *sku, char *price , char *pointID){
    NSString *roleidoc = [NSString stringWithCString:roleID encoding:NSUTF8StringEncoding];
    NSString *serverIdoc = [NSString stringWithCString:roleServiceID encoding:NSUTF8StringEncoding];
    NSString *skuoc = [NSString stringWithCString:sku encoding:NSUTF8StringEncoding];
    NSString *priceoc = [NSString stringWithCString:price encoding:NSUTF8StringEncoding];
    NSString *pointIDoc = [NSString stringWithCString:pointID encoding:NSUTF8StringEncoding];
    //其他参数
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    // 创建订单
    [[YllGameSDK getInstance] yg_createOrderWithRoleId:roleidoc gameServerId:serverIdoc cpno:timeString cptime:timeString sku:skuoc amount:priceoc pointId:pointIDoc successBlock:^{
        //充值成功
    } failedBlock:^(YGPaymentFailedType type, NSString * _Nonnull errorDescription) {
        //充值失败
    }];
}
```
### 4.2 订阅
```obj-c
void OCsub (char *roleID, char *roleServiceID, char *sku, char *price , char *pointID){
    NSString *roleidoc = [NSString stringWithCString:roleID encoding:NSUTF8StringEncoding];
    NSString *serverIdoc = [NSString stringWithCString:roleServiceID encoding:NSUTF8StringEncoding];
    NSString *skuoc = [NSString stringWithCString:sku encoding:NSUTF8StringEncoding];
    NSString *priceoc = [NSString stringWithCString:price encoding:NSUTF8StringEncoding];
    NSString *pointIDoc = [NSString stringWithCString:pointID encoding:NSUTF8StringEncoding];
    //其他参数
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    // 创建订单
    [[YllGameSDK getInstance] yg_createSubscribeOrderWithRoleId:roleidoc gameServerId:serverIdoc cpno:timeString cptime:timeString sku:skuoc amount:priceoc pointId:pointIDoc successBlock:^{
        //订阅成功
    } failedBlock:^(YGPaymentFailedType type, NSString * _Nonnull errorDescription) {
        //订阅失败
    }];
}
```
## 4 通用事件埋点
evName和params参照[YllSDK IOS埋点](https://github.com/yllgame2021/yllgamesdk/blob/master/%E5%9F%8B%E7%82%B9%E9%9C%80%E6%B1%82/IOS/%E7%BB%9F%E8%AE%A1%E5%9F%8B%E7%82%B9IOS.md)
```obj-c
void OConEvent (char *eventName, char *jsonData){
    NSString *evName = [NSString stringWithCString:eventName encoding:NSUTF8StringEncoding];
    NSString * jsStr = [NSString stringWithCString:jsonData encoding:NSUTF8StringEncoding];
    
    NSData *strData = [jsStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:strData
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
    [[YGEventManager getInstance] onEvent:evName params:dic];
}
```
- SDK埋点功能,可以 分别上报到YallaGame, Firebase 和 Facebook 数据平台，接口如下：
```obj-c
// 上报到YallaGame
[[YGEventManager getInstance] onEvent:<#(nonnull NSString *)#> params:<#(NSDictionary * _Nullable)#>];
// 上报到Firebase
[[YGEventManager getInstance] onFirebaseEvent:<#(nonnull NSString *)#> params:<#(NSDictionary * _Nullable)#>];
// 上报到Facebook
[[YGEventManager getInstance] onFacebookEvent:<#(nonnull NSString *)#> params:<#(NSDictionary * _Nullable)#>];
```

## 5.Facebook好友列表和分享
### 5.1 获取好友列表
```obj-c
// 获取fb好友列表
void OConGetFriends(){
    [[YllGameSDK getInstance] yg_getFacebookFriendsWithCompleteHandle:^(NSArray<YGFBFriendInfoModel *> * _Nonnull friendsArray) {
        if(friendsArray.count > 0){
            NSString *str = [[RootViewController getInstance] friendArrayToJSON:friendsArray];
            //将处理之后的json回调到unity处理
        }
    }];
}
//数组转为json
- (NSString *)friendArrayToJSON:(NSArray *)friendArr {
    if (friendArr && friendArr.count > 0) {
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
        
        for (YGFBFriendInfoModel *model in friendArr) {
            NSDictionary *info=@{@"fbId":model.fbId ,
                                 @"userOpenId":model.userOpenId,
                                 @"name":model.name};
//                                 @"avatarUrl":model.avatarUrl};
//                                 @"avatarWidth":[NSString stringWithFormat:@"%d",(int)model.avatarWidth],
//                                 @"avatarHeight":[NSString stringWithFormat:@"%d",(int)model.avatarHeight]};
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:0 error:nil];
            NSString *jsonText = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [arr addObject:jsonText];
        }
        
        return [self objArrayToJSON:arr];
    }
    
    return nil;
}
```
### 5.2 分享
```obj-c
//分享
void OCShare(char *qute, char *link){
    NSLog(@"开始分享");
    NSString *quteoc = [NSString stringWithCString:qute encoding:NSUTF8StringEncoding];
    NSString * linkoc = [NSString stringWithCString:link encoding:NSUTF8StringEncoding];
    [[YGShareManager getInstance] shareLinkContentWithQuote:quteoc linkContent:linkoc success:^{
        //分享成功
    } cancel:^{
        //分享取消
    } failed:^(NSError * _Nonnull) {
        //分享失败
    }];
}
```

## 4.其他API 
### 4.1打开客服界面

```obj-c
void OCshowserviceChat (char *str1, char *str2){
    NSString *roleid = [NSString stringWithCString:str1 encoding:NSUTF8StringEncoding];
    NSString *serverId = [NSString stringWithCString:str2 encoding:NSUTF8StringEncoding];
    [[YllGameSDK getInstance] yg_showServiceChatViewWithRoleId:roleid gameServerId:serverId];
}
```

### 4.2 打开SDK设置界面

```obj-c
//设置界面
void OCshowSetting (char *str1, char *str2){
    NSString *roleid = [NSString stringWithCString:str1 encoding:NSUTF8StringEncoding];
    NSString *serverId = [NSString stringWithCString:str2 encoding:NSUTF8StringEncoding];
    [[YllGameSDK getInstance] yg_showSettingsViewWithRoleId:roleid gameServerId:serverId];
}
```

### 4.3打开修改昵称界面

```obj-c
void OCshowMidifName {
    [[YllGameSDK getInstance] yg_showNicknameView];
}
```

### 4.4打开用户管理界面

```obj-c
//账号管理界面
void OCaccountManager (){
    [[YllGameSDK getInstance] yg_showAccountManagementView];
}
```

### 4.5检查账号绑定

```obj-c
//检查账号绑定
void OCcheckBind(){
    [[YllGameSDK getInstance] yg_checkBindState];
}
```
### 4.6检查SDK版本
```obj-c
void OCcheckSDKInfo(){
    [[YllGameSDK getInstance] yg_checkSDKVersion];
}
```
### 4.7获取SDK版本信息
```obj-c
//获取SDK版本
char* OCgetSDKInfo (){
    NSString *SDKHost = [[YllGameSDK getInstance] yg_getHost];
    char* charString = (char*) [SDKHost UTF8String];
    
    if (charString == NULL)
        return NULL;
    
    char* res = (char*)malloc(strlen(charString) + 1);
    strcpy(res, charString);

    return res;
}
```


## 5消息推送
推送分为SDK推送和游戏方推送，区分两者的方法在于主要在于返回的消息字典(userInfo)内是否含有 YllGameSDKMsgId 这个key，包含该key表明是SDK推送，游戏方可不用处理该条推送.
### 5.1 获取推送token
```obj-c
[[YllGameSDK getInstance] yg_getPushToken:<#^(NSString * _Nullable, NSError * _Nullable)pushToken#>];
```

### 5.2. App冷启动, 在此方法处理推送
在`didFinishLaunchingWithOptions`方法添加以下代码
```obj-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ****************
    if (launchOptions && [launchOptions.allKeys containsObject:UIApplicationLaunchOptionsRemoteNotificationKey]) {
         NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    }
    ***************
}
```
### 5.3 App在前台或后台, 收到通知在此方法处理推送
```obj-c
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler { 
    [[YllGameSDK getInstance] yg_application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}
```
