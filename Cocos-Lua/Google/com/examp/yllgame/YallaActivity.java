package com.examp.yllgame;
import android.content.ClipboardManager;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.webkit.WebView;
import android.widget.ImageButton;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.Sharer;
import com.google.common.reflect.TypeToken;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.yllgame.sdk.BuildConfig;
import com.yllgame.sdk.YllGameSdk;
import com.yllgame.sdk.common.YGCommonApi;
import com.yllgame.sdk.constants.YGConstants;
import com.yllgame.sdk.entity.GameFacebookFriendEntity;
import com.yllgame.sdk.event.YGEventApi;
import com.yllgame.sdk.listener.YGBooleanCallBack;
import com.yllgame.sdk.listener.YGCallBack;
import com.yllgame.sdk.login.YGLoginApi;
import com.yllgame.sdk.pay.YGPayApi;
import com.yllgame.sdk.pay.YGPaymentListener;
import com.yllgame.sdk.tripartite.YGTripartiteApi;
import com.yllgame.sdk.ui.dialog.listener.UpdateUserNameListener;
import com.yllgame.sdk.user.YGUserApi;
import com.yllgame.sdk.utils.LogUtils;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lua.DragButton;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.List;
import java.util.Map;

import afu.org.checkerframework.checker.nullness.qual.Nullable;


public class YallaActivity extends Cocos2dxActivity {

    private static YallaActivity yallaActivity = null;
    //登陆回调，需要在登陆的时候传入lua函数
    private static int luaLoginCallBack = -1;
    //修改昵称回调
    private static int modifyNameCallBack = -1;
    //同步角色回调
    private static int syncRoleCallBack = -1;
    //支付回调
    private static int payCallBack = -1;
    //分享回调
    private static int friendCallBack = -1;

    @Override
    protected void onStart() {
        super.onStart();
        LogUtils.logEForDeveloper("c2d-onStart");
    }

    @Override
    protected void onRestart() {
        super.onRestart();
        LogUtils.logEForDeveloper("c2d-onRestart");
        onWindowFocusChanged(true);
    }

    @Override
    protected void onStop() {
        super.onStop();
        LogUtils.logEForDeveloper("c2d-onStop");
    }

    @Override
    protected void onPause() {
        super.onPause();
        LogUtils.logEForDeveloper("c2d-onPause");
    }

    @Override
    protected void onResume() {
        super.onResume();
        LogUtils.logEForDeveloper("c2d-onResume");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        LogUtils.logEForDeveloper("c2d-onDestroy");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        yallaActivity = this;
    }

    //登陆界面
    public static void login(final int luaFunc) {
        luaLoginCallBack = luaFunc;
        YGLoginApi.getInstance().login(yallaActivity);
    }
    //静默登陆
    public static void loginGuest(final int luaFunc) {
        luaLoginCallBack = luaFunc;
        YGLoginApi.getInstance().silentGuestLogin();
    }
    //登陆回调
    public static void login_callBack(final String info) {
        Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
            @Override
            public void run() {
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaLoginCallBack, info);
//                Cocos2dxLuaJavaBridge.releaseLuaFunction(luaLoginCallBack);
            }
        });
    }
    //用户管理界面
    public static void accountManager() {
        YGUserApi.getInstance().openAccountManager(yallaActivity);
    }
    //修改昵称
    public static void showModifyName(final int luaFunc){
        modifyNameCallBack = luaFunc;
        YGUserApi.getInstance().showUpdateNickNameDialog(yallaActivity, new UpdateUserNameListener() {
            /**
             * 修改成功回调
             * @param stat true：修改成功 false：修改失败
             * @param userName 修改后的用户名
             */
            @Override
            public void onResult(boolean stat, String userName) {
                Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
                    @Override
                    public void run() {
                        if(stat){
                            Cocos2dxLuaJavaBridge.callLuaFunctionWithString(modifyNameCallBack, userName);
//                          Cocos2dxLuaJavaBridge.releaseLuaFunction(modifyNameCallBack);
                        }
                    }
                });
            }
        });
    }
    //设置界面
    public static void showSetting(String serviceId, String roleID){
        YGUserApi.getInstance().showSettingsView(yallaActivity, serviceId, roleID);
    }
    //客服界面
    public static void showserviceChat(String roleServiceID, String roleID) {
        YGUserApi.getInstance().showServiceChatView(yallaActivity, roleServiceID, roleID);
    }
    //设置语言
    public static void setLanguage(String language) {
        YllGameSdk.setLanguage(language);
    }
    //设置SDK模式
    public static void setNetModel(final int netM) {
        LogUtils.logEForDeveloper("设置网络模式为"+netM);
        if (netM == 1) {
            YllGameSdk.setNetMode(YGConstants.SDK_STRONG_NET);
        }else if (netM == 2){
            YllGameSdk.setNetMode(YGConstants.SDK_WEAK_NET);
        }
    }
    //同步角色
    // roleId：角色id ：Int 必要参数
    // roleName：角色名称 ：string 必要参数
    // roleLevel：角色等级 ：int 必要参数
    // roleVipLevel：角色Vip等级 ：int 非必要 没有默认0
    // serverId：角色所在服务器id：int 必要参数
    // roleCastleLevel：城堡等级 ：int 非必要 没有默认0
    //  CommonBooleanCallBack：同步角色回调
    public static void syncRoleInfo(String roleId, String roleName, String roleLevel, String roleVipLevel, String serverId ,String roleCastleLevel,final int luaFunc) {
        syncRoleCallBack = luaFunc;
        YGUserApi.getInstance().syncRoleInfo(roleId, roleName, roleLevel, roleVipLevel, serverId, roleCastleLevel, new YGBooleanCallBack() {
            @Override
            public void onResult(boolean b) {
                //回调，同步角色成功or失败
                if (b) {
                    LogUtils.logEForDeveloper("同步角色成功");
                    Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
                        @Override
                        public void run() {
                            Cocos2dxLuaJavaBridge.callLuaFunctionWithString(syncRoleCallBack, "success");
//                            Cocos2dxLuaJavaBridge.releaseLuaFunction(syncRoleCallBack);
                        }
                    });
                } else {

                }
            }
        });
    }

    //获取SDK信息
    public static String getSDKInfo(){
        JSONObject result = new JSONObject();
        try {
            result.put("baseurl", BuildConfig.BASE_URL);
            result.put("versionname", BuildConfig.versionName);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        String finalStr = result.toString().replaceAll("\\\\", "");
        return finalStr.toString();
    }
    //充值
    public static void pay(String roleID, String roleServiceID, String sku, String price , String pointID, final int luaFunc) {
        payCallBack = luaFunc;
        YGPayApi.pay(yallaActivity, roleID, roleServiceID, sku, System.currentTimeMillis() + "",
            System.currentTimeMillis() + "", 1 + "", price, pointID, new YGPaymentListener() {
                @Override
                public void paymentSuccess() {
                    Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
                        @Override
                        public void run() {
                            LogUtils.logEForDeveloper("支付成功");
                            Cocos2dxLuaJavaBridge.callLuaFunctionWithString(payCallBack, pointID);
                            //Cocos2dxLuaJavaBridge.releaseLuaFunction(payCallBack);
                        }
                    });
                }

                @Override
                public void paymentFailed(int code) {
                    LogUtils.logEForDeveloper("充值失败，返回码"+code);
                }
        });
    }
    //订阅
    public static void paySubs(String roleID, String roleServiceID, String sku, String price , String pointID, final int luaFunc) {
        payCallBack = luaFunc;
        YGPayApi.paySubs(yallaActivity, roleID, roleServiceID, sku, System.currentTimeMillis() + "",
                System.currentTimeMillis() + "", 1 + "", price, pointID, new YGPaymentListener() {
                    @Override
                    public void paymentSuccess() {
                        Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
                            @Override
                            public void run() {
                                LogUtils.logEForDeveloper("支付成功");
                                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(payCallBack, pointID);
                                //Cocos2dxLuaJavaBridge.releaseLuaFunction(payCallBack);
                            }
                        });
                    }

                    @Override
                    public void paymentFailed(int code) {
                        LogUtils.logEForDeveloper("充值失败，返回码"+code);
                    }
                });
    }

    public static void crashTest(String test) {
        test.toString();
    }

    //自定义事件
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

    public static void copyToClipboard(String str)
    {
        Runnable runnable = new Runnable() {
            @SuppressWarnings("deprecation")
            public void run() {
                ClipboardManager mClipboardManager = (ClipboardManager)yallaActivity.getSystemService(CLIPBOARD_SERVICE);
                mClipboardManager.setText(str);
            }
        };
        yallaActivity.runOnUiThread(runnable);
    }
    //分享
    public static void shareToFB(String  desc, String url, final int luaFunc){
        YGTripartiteApi.getInstance().shareLink(yallaActivity, desc, url, new FacebookCallback<Sharer.Result> (){

            @Override
            public void onSuccess(Sharer.Result result) {
                Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
                    @Override
                    public void run() {
                        LogUtils.logDForDeveloper("开始分享"+"success");
                        //回调,释放lua函数
                        Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaFunc, "success");
                        Cocos2dxLuaJavaBridge.releaseLuaFunction(luaFunc);
                    }
                });
            }

            @Override
            public void onCancel() {
                Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
                    @Override
                    public void run() {
                        Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaFunc, "cancel");
                        Cocos2dxLuaJavaBridge.releaseLuaFunction(luaFunc);
                    }
                });
            }

            @Override
            public void onError(FacebookException error) {
                Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
                    @Override
                    public void run() {
                        Cocos2dxLuaJavaBridge.callLuaFunctionWithString(luaFunc, "faild");
                        Cocos2dxLuaJavaBridge.releaseLuaFunction(luaFunc);
                    }
                });
            }
        });
    }
    //获取好友列表
    public static String getFriends(final int luaFunc){
        friendCallBack = luaFunc;
        String json = "";
        Log.e("bagin", "开始获取");
        YGTripartiteApi.getInstance().getFacebookFriends(yallaActivity, new YGCallBack<List<GameFacebookFriendEntity>>(){
            @Override
            public void onSuccess(List<GameFacebookFriendEntity> gameFacebookFriendEntities) {
                Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
                    @Override
                    public void run() {

                        LogUtils.logEForDeveloper("收到好友列表"+gameFacebookFriendEntities.size());
                        JSONArray json = new JSONArray();
                        for(GameFacebookFriendEntity entityOne : gameFacebookFriendEntities){
                            JSONObject jo = new JSONObject();
                            try {
                                jo.put("fbId", entityOne.getFbId());
                                jo.put("userOpenId", entityOne.getUserOpenId());
                                jo.put("name", entityOne.getName());
//                                jo.put("avatarUrl", entityOne.getAvatarUrl());
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            json.put(jo);
                        }

                        LogUtils.logEForDeveloper(json.toString());
//                        String finalStr = json.toString().replaceAll("\\\\", "");
                        //回调,释放lua函数
                        Cocos2dxLuaJavaBridge.callLuaFunctionWithString(friendCallBack, json.toString());
//                        Cocos2dxLuaJavaBridge.releaseLuaFunction(friendCallBack);
                    }
                });
            }

            @Override
            public void onFail(int i) {
                Log.e("faild", "获取失败");
            }
        });
        return json;
    }

    public static void OpenWebViewPortrait(final String url, final int luaFunc) {
        Log.e("YallaActivity======", url);
    }

    //分享回调才需要
    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        YGCommonApi.setCallback(requestCode, resultCode, data);
        super.onActivityResult(requestCode, resultCode, data);
    }
}

