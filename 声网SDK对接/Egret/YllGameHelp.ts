class YllGameHelp {
    //声明回调，用于文档参考，实际上没有用到
    //##########################################################################
    //##########################################################################
    //##########################################################################
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


    //一些调用Navite层的接口
    //##########################################################################
    //##########################################################################
    //##########################################################################
    /**
     * 注册回调监听
     * @param funcname  回调方法名称
     * @param func      回调方法体
     */
    public static addLister(funcname:string, func:any) {
        // eval("this."+funcname+"=func");
        egret.ExternalInterface.addCallback(funcname, func);
    }

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
}