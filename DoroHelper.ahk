#Requires AutoHotkey >=v2.0
#SingleInstance Force
#Include <github>
#Include <FindText>
#Include <PicLib>
#Include <GuiCtrlTips>
#Include <RichEdit>
CoordMode "Pixel", "Client"
CoordMode "Mouse", "Client"
;region 设置常量
try TraySetIcon "doro.ico"
currentVersion := "v1.8.6"
;tag 检查脚本哈希
SplitPath A_ScriptFullPath, , , &scriptExtension
scriptExtension := StrLower(scriptExtension)
if (scriptExtension = "ahk") {
    currentVersion := currentVersion . "-beta"
}
usr := "1204244136"
repo := "DoroHelper"
;endregion 设置常量
;region 设置变量
;tag 简单开关
global g_settings := Map(
    ;登录游戏
    "Login", 0,                         ; 登录游戏总开关
    ;商店
    "Shop", 0,                          ; 商店总开关
    "ShopCash", 1,                      ; 付费商店
    "ShopCashFree", 0,                  ; 付费商店免费物品
    "ShopCashFreePackage", 0,           ; 付费商店免费STEPUP
    "ShopGeneral", 1,                   ; 普通商店
    "ShopGeneralFree", 0,               ; 普通商店：免费物品
    "ShopGeneralDust", 0,               ; 普通商店：芯尘盒
    "ShopGeneralPackage", 0,            ; 普通商店：简介个性化礼包
    "ShopArena", 1,                     ; 竞技场商店
    "ShopArenaBookFire", 0,             ; 竞技场商店：燃烧手册
    "ShopArenaBookWater", 0,            ; 竞技场商店：水冷手册
    "ShopArenaBookWind", 0,             ; 竞技场商店：风压手册
    "ShopArenaBookElec", 0,             ; 竞技场商店：电击手册
    "ShopArenaBookIron", 0,             ; 竞技场商店：铁甲手册
    "ShopArenaBookBox", 0,              ; 竞技场商店：手册宝箱
    "ShopArenaPackage", 0,              ; 竞技场商店：简介个性化礼包
    "ShopArenaFurnace", 0,              ; 竞技场商店：公司武器熔炉
    "ShopRecycling", 1,                 ; 废铁商店
    "ShopRecyclingGem", 0,              ; 废铁商店：珠宝
    "ShopRecyclingVoucher", 0,          ; 废铁商店：好感券
    "ShopRecyclingResources", 0,        ; 废铁商店：养成资源
    "ShopRecyclingTeamworkBox", 0,      ; 废铁商店：团队合作宝箱
    "ShopRecyclingKitBox", 0,           ; 废铁商店：保养工具箱
    "ShopRecyclingArms", 0,             ; 废铁商店：企业精选武装
    ;模拟室
    "SimulationRoom", 0,                ; 模拟室
    "SimulationNormal", 0,              ; 普通模拟室
    "SimulationOverClock", 0,           ; 模拟室超频
    ;竞技场
    "Arena", 0,                         ; 竞技场总开关
    "AwardArena", 0,                    ; 竞技场收菜
    "ArenaRookie", 0,                   ; 新人竞技场
    "ArenaSpecial", 0,                  ; 特殊竞技场
    "ArenaChampion", 0,                 ; 冠军竞技场
    ;无限之塔
    "Tower", 0,                         ; 无限之塔总开关
    "TowerCompany", 0,                  ; 企业塔
    "TowerUniversal", 0,                ; 通用塔
    ;拦截
    "Interception", 0,                  ; 拦截战
    "InterceptionNormal", 0,            ; 普通拦截战
    "InterceptionAnomaly", 0,           ; 异常拦截战
    "InterceptionScreenshot", 0,        ; 拦截截图
    "InterceptionRedCircle", 0,         ; 拦截红圈
    "InterceptionExit7", 0,             ; 满7退出
    ;常规奖励
    "Award", 0,                         ; 奖励领取总开关
    "AwardOutpost", 0,                  ; 前哨基地收菜
    "AwardOutpostDispatch", 0,          ; 派遣
    "AwardAdvise", 0,                   ; 咨询
    "AwardAdviseAward", 0,              ; 咨询奖励
    "AwardAppreciation", 0,             ; 花絮鉴赏会
    "AwardFriendPoint", 0,              ; 好友点数
    "AwardMail", 0,                     ; 邮箱
    "AwardRanking", 0,                  ; 排名奖励
    "AwardDaily", 0,                    ; 任务
    "AwardPass", 0,                     ; 通行证
    ;小活动
    "Event", 0,                         ; 活动总开关
    "EventSmall", 0,                    ; 小活动
    "EventSmallChallenge", 0,           ; 小活动挑战
    "EventSmallStory", 0,               ; 小活动剧情
    "EventSmallMission", 0,             ; 小活动任务
    ;大活动
    "EventLarge", 0,                    ; 大活动
    "EventLargeSign", 0,                ; 大活动签到
    "EventLargeChallenge", 0,           ; 大活动挑战
    "EventLargeStory", 0,               ; 大活动剧情
    "EventLargeCooperate", 0,           ; 大活动协同作战
    "EventLargeMinigame", 0,            ; 大活动小游戏
    "EventLargeDaily", 0,               ; 大活动奖励
    ;特殊活动
    "EventSpecial", 0,                  ; 特殊活动
    "EventSpecialSign", 0,              ; 特殊活动签到
    "EventSpecialChallenge", 0,         ; 特殊活动挑战
    "EventSpecialStory", 0,             ; 特殊活动剧情
    "EventSpecialCooperate", 0,         ; 特殊活动协同作战
    "EventSpecialMinigame", 0,          ; 特殊活动小游戏
    "EventSpecialDaily", 0,             ; 特殊活动奖励
    ;限时奖励
    "AwardFreeRecruit", 0,              ; 活动期间每日免费招募
    "AwardCooperate", 0,                ; 协同作战
    "AwardSoloRaid", 0,                 ; 个人突击
    ;妙妙工具
    "StoryModeAutoStar", 0,             ; 剧情模式自动收藏
    "StoryModeAutoChoose", 0,           ; 剧情模式自动选择
    ;清除红点
    "ClearRed", 0,                      ; 总开关
    "ClearRedNotice", 0,                ; 清除公告红点
    "ClearRedWallpaper", 0,             ; 清除壁纸红点
    "ClearRedRecycling", 0,             ; 自动升级循环室
    "ClearRedSynchro", 0,               ; 自动升级同步器
    "ClearRedCube", 0,                  ; 自动升级魔方
    "ClearRedSynchroForce", 0,          ; 开箱子
    "ClearRedLimit", 0,                 ; 自动突破妮姬
    "ClearRedProfile", 0,               ; 清除个人页红点
    "ClearRedBla", 0,                   ; 清除Bla红点
    ;启动/退出相关
    "CloseAdvertisement", 0,            ; 关闭广告提示
    "CloseHelp", 0,                     ; 关闭帮助提示
    "AutoSwitchLanguage", 0,            ; 自动切换语言
    "AutoCheckUpdate", 0,               ; 自动检查更新
    "AutoCheckUserGroup", 1,            ; 自动检查会员组
    "AutoDeleteOldFile", 0,             ; 自动删除旧版本
    "DoroClosing", 0,                   ; 完成后自动关闭Doro
    "LoopMode", 0,                      ; 完成后自动关闭游戏
    "OpenBlablalink", 0,                ; 完成后打开Blablalink
    "CheckEvent", 0,                    ; 活动结束提醒
    "AutoStartNikke", 0,                ; 使用脚本启动NIKKE
    "Timedstart", 0,                    ; 定时启动
    ;其他
    "AutoFill", 0,                      ; 自动填充加成妮姬
    "CheckAuto", 0,                     ; 开启自动射击和爆裂
    "TestModeInitialization", 1,       ; 调试模式预初始化
    "BluePill", 0,                      ; 万用开关
    "RedPill", 0                        ; 万用开关
)
;tag 其他非简单开关
global g_numeric_settings := Map(
    "doroGuiX", 200,                    ; DoroHelper窗口X坐标
    "doroGuiY", 200,                    ; DoroHelper窗口Y坐标
    "TestModeValue", "",                ; 调试模式值
    "StartupTime", "",                  ; 定时启动时间
    "StartupPath", "",                  ; 启动路径
    "SleepTime", 1000,                  ; 默认等待时间
    "InterceptionBossNormal", 1,        ; 普通拦截战BOSS选择
    "InterceptionBoss", 1,              ; 异常拦截战BOSS选择
    "LanguageList", 1,                  ; 语言选择
    "Tolerance", 1,                     ; 宽容度
    "MirrorCDK", "",                    ; Mirror酱的CDK
    "Version", currentVersion,          ; 版本号
    "UpdateChannels", "正式版",         ; 更新渠道
    "DownloadSource", "GitHub",         ; 下载源
    "UserGroup", "普通用户",             ; 用户组
    "UserLevel", 0                      ; 用户级别
)
;tag 其他全局变量
outputText := ""
Victory := 0
BattleSkip := 0
QuickBattle := 0
PicTolerance := g_numeric_settings["Tolerance"]
g_settingPages := Map()
Hashed := ""
stdScreenW := 3840
stdScreenH := 2160
nikkeID := ""
NikkeX := 0
NikkeY := 0
NikkeW := 0
NikkeH := 0
NikkeXP := 0
NikkeYP := 0
NikkeWP := 0
NikkeHP := 0
TrueRatio := 1
;是否能进入战斗，0表示根本没找到进入战斗的图标，1表示能，2表示能但次数耗尽（灰色的进入战斗）
BattleActive := 1
; 确定地区
LocaleName := GetUserLocaleName()
; 会员等级定义
g_MembershipLevels := Map(
    "普通用户", { monthlyCost: 0, userLevel: 0 },
    "铜Doro会员", { monthlyCost: 1, userLevel: 1 },
    "银Doro会员", { monthlyCost: 3, userLevel: 2 },
    "金Doro会员", { monthlyCost: 5, userLevel: 3 },
    "管理员", { monthlyCost: 999, userLevel: 10 }
)
; 地区价格映射表
defaultPriceData := { Unitprice: 1, Currency: "USD", currencySymbol: "$" }
g_PriceMap := Map(
    "zh-CN", { Unitprice: 6, Currency: "CNY", currencySymbol: "¥" },
    "en-US", defaultPriceData, ; 示例：美国
)
g_DefaultRegionPriceData := defaultPriceData
;退出时保存设置
OnExit(WriteSettings)
;检测管理员身份
if !A_IsAdmin {
    MsgBox "请以管理员身份运行DoroHelper！`nPlease run DoroHelper as administrator!"
    ExitApp
}
;tag 彩蛋
konami_code := "UUDDLRLRBA" ; 目标序列 (U=Up, D=Down, L=Left, R=Right)
key_history := ""           ; 用于存储用户按键历史的变量
if (scriptExtension = "ahk") {
    MyFileHash := HashGitSHA1(A_ScriptFullPath)
    global MyFileShortHash := SubStr(MyFileHash, 1, 7)
}
;tag 变量备份
g_default_settings := g_settings.Clone()
g_default_numeric_settings := g_numeric_settings.Clone()
;tag 更新相关变量
global latestObj := Map( ; latestObj 是全局变量，在此处初始化，并通过辅助函数直接填充
    "version", "",
    "change_notes", "无更新说明",
    "download_url", "",
    "source", "", ; 例如: "github", "mirror", "ahk"
    "display_name", "" ; 例如: "GitHub", "Mirror酱", "AHK版"
)
;endregion 设置变量
;region 读取设置
SetWorkingDir A_ScriptDir
;tag 变量名修改提示
try {
    LoadSettings()
    if InStr(currentVersion, "v1.7.7") and g_numeric_settings["Version"] != currentVersion {
        MsgBox("该版本部分选项被重置了，请按需勾选")
        g_numeric_settings["Version"] := currentVersion
    }
}
catch {
    WriteSettings()
}
;endregion 读取设置
;region 创建GUI
;tag 基础配置
g_settingPages := Map("Default", [], "Login", [], "Shop", [], "SimulationRoom", [], "Arena", [], "Tower", [], "Interception", [], "Event", [], "Award", [], "Settings", [], "After", [])
title := "DoroHelper - " currentVersion
doroGui := Gui("+Resize", title)
doroGui.Opt("+DPIScale +OwnDialogs")
doroGui.Tips := GuiCtrlTips(doroGui) ; 为 doroGui 实例化 GuiCtrlTips
doroGui.Tips.SetBkColor(0xFFFFFF)
doroGui.Tips.SetTxColor(0x000000)
doroGui.Tips.SetMargins(3, 3, 3, 3)
doroGui.Tips.SetDelayTime("AUTOPOP", 10000)
doroGui.MarginY := Round(doroGui.MarginY * 1)
doroGui.SetFont('s12', 'Microsoft YaHei UI')
;tag 框
Update := doroGui.AddGroupBox("x10 y10 w250 h210 ", "更新")
;tag 检查更新
BtnUpdate := doroGui.Add("Button", "xp+50 yp-1 w80 h25", "检查更新")
doroGui.Tips.SetTip(BtnUpdate, "Check for updates")
BtnUpdate.OnEvent("Click", ClickOnCheckForUpdate)
;tag 赞助
BtnSponsor := doroGui.Add("Button", "x+10  w50 h25", "赞助")
doroGui.Tips.SetTip(BtnSponsor, "Sponsor")
BtnSponsor.OnEvent("Click", MsgSponsor)
;tag 帮助
BtnHelp := doroGui.Add("Button", "x+10 w50 h25", "帮助")
doroGui.Tips.SetTip(BtnHelp, "Help")
BtnHelp.OnEvent("Click", ClickOnHelp)
;tag 版本
TextVersion := doroGui.Add("Text", "x20 y40 R1 +0x0100", "版本：" currentVersion)
doroGui.Tips.SetTip(TextVersion, "Version")
;tag 用户组
TextUserGroup := doroGui.Add("Text", "x20 y+5 R1 +0x0100 Section", "用户组：")
doroGui.Tips.SetTip(TextUserGroup, "你可以通点击上方的赞助按钮来获得更高级的用户组`nUserGroup:You can upgrade your membership by clicking the Sponsor button above`n普通用户:Normal User|铜:Copper|银:Silver|金:Gold")
VariableUserGroup := doroGui.Add("Text", "x+0.5 w100 R1 +0x0100", g_numeric_settings["UserGroup"])
;tag 更新渠道
TextUpdateChannels := doroGui.Add("Text", "Section x20 y+8 R1 +0x0100", "更新渠道")
doroGui.Tips.SetTip(TextUpdateChannels, "UpdateChannels`n正式版:稳定，适合大多数用户|Stable: Reliable, recommended for most users.`n测试版:现已弃用|Beta: Now deprecated.`nAHK版:源代码版本，第一时间体验最新功能|AHK: Source code version with earliest access to new features.")
if g_numeric_settings["UpdateChannels"] = "正式版" {
    var := 1
}
else if g_numeric_settings["UpdateChannels"] = "测试版" {
    var := 2
}
else {
    var := 3
}
cbUpdateChannels := doroGui.Add("DropDownList", "x140 yp w100 Choose" var, ["正式版", "测试版", "AHK版"])
cbUpdateChannels.OnEvent("Change", (Ctrl, Info) => g_numeric_settings["UpdateChannels"] := Ctrl.Text)
;tag 资源下载
TextDownloadSource := doroGui.Add("Text", "xs R1 +0x0100", "资源下载源")
doroGui.Tips.SetTip(TextDownloadSource, "Download Source")
if g_numeric_settings["DownloadSource"] = "GitHub" {
    var := 1
}
else {
    var := 2
}
cbDownloadSource := doroGui.AddDropDownList(" x140 yp w100 Choose" var, ["GitHub", "Mirror酱"])
cbDownloadSource.OnEvent("Change", (Ctrl, Info) => ShowMirror(Ctrl, Info))
;tag Mirror酱
MirrorText := doroGui.Add("Text", "xs R1 +0x0100", "Mirror酱CDK❔️")
doroGui.Tips.SetTip(MirrorText, "Mirror酱是一个第三方应用分发平台，让你能在普通网络环境下更新应用`n网址：https://mirrorchyan.com/zh/（付费使用）`nMirror酱和Doro会员并无任何联系")
MirrorEditControl := doroGui.Add("Edit", "x140 yp+1 w100 h20")
MirrorEditControl.Value := g_numeric_settings["MirrorCDK"]
MirrorEditControl.OnEvent("Change", (Ctrl, Info) => g_numeric_settings["MirrorCDK"] := Ctrl.Value)
; 初始化隐藏状态
if g_numeric_settings["DownloadSource"] = "Mirror酱" {
    ShowMirror(cbDownloadSource, "")
} else {
    MirrorText.Visible := false
    MirrorEditControl.Visible := false
}
;tag 任务列表
global g_taskListCheckboxes := []
doroGui.AddGroupBox("x10 y230 w250 h420 ", "任务列表")
;tag 全选/全不选
doroGui.SetFont('s9')
BtnCheckAll := doroGui.Add("Button", "xp+180 R1", "✅️")
doroGui.Tips.SetTip(BtnCheckAll, "勾选全部|Check All")
BtnCheckAll.OnEvent("Click", CheckAllTasks)
BtnUncheckAll := doroGui.Add("Button", "xp+40 R1", "🔲")
doroGui.Tips.SetTip(BtnUncheckAll, "取消勾选全部|Uncheck All")
BtnUncheckAll.OnEvent("Click", UncheckAllTasks)
;tag 任务总开关
doroGui.SetFont('s14')
TextSettings := doroGui.Add("Text", "x20 yp+40 Section +0x0100", "　基础设置")
doroGui.Tips.SetTip(TextSettings, "Basic Settings")
BtnSetting := doroGui.Add("Button", "x210 yp-2 w30 h30", "🔧").OnEvent("Click", (Ctrl, Info) => ShowSetting("Settings"))
cbLogin := AddCheckboxSetting(doroGui, "Login", "登录", "xs", true)
doroGui.Tips.SetTip(cbLogin, "是否先尝试进入大厅页面|Login:Proceed to the lobby first")
BtnLogin := doroGui.Add("Button", "x210 yp-2 w30 h30", "🔧").OnEvent("Click", (Ctrl, Info) => ShowSetting("Login"))
cbShop := AddCheckboxSetting(doroGui, "Shop", "商店", "xs", true)
doroGui.Tips.SetTip(cbShop, "Shop")
BtnShop := doroGui.Add("Button", "x210 yp-2 w30 h30", "🔧").OnEvent("Click", (Ctrl, Info) => ShowSetting("Shop"))
cbSimulationRoom := AddCheckboxSetting(doroGui, "SimulationRoom", "模拟室", "xs", true)
doroGui.Tips.SetTip(cbSimulationRoom, "SimulationRoom")
BtnSimulationRoom := doroGui.Add("Button", "x210 yp-2 w30 h30", "🔧").OnEvent("Click", (Ctrl, Info) => ShowSetting("SimulationRoom"))
cbArena := AddCheckboxSetting(doroGui, "Arena", "竞技场", "xs", true)
doroGui.Tips.SetTip(cbArena, "Arena")
BtnArena := doroGui.Add("Button", "x210 yp-2 w30 h30", "🔧").OnEvent("Click", (Ctrl, Info) => ShowSetting("Arena"))
cbTower := AddCheckboxSetting(doroGui, "Tower", "无限之塔", "xs", true)
doroGui.Tips.SetTip(cbTower, "Tribe Tower")
BtnTower := doroGui.Add("Button", "x210 yp-2 w30 h30", "🔧").OnEvent("Click", (Ctrl, Info) => ShowSetting("Tower"))
cbInterception := AddCheckboxSetting(doroGui, "Interception", "拦截战", "xs", true)
doroGui.Tips.SetTip(cbInterception, "Interception")
BtnInterception := doroGui.Add("Button", "x210 yp-2 w30 h30", "🔧").OnEvent("Click", (Ctrl, Info) => ShowSetting("Interception"))
cbAward := AddCheckboxSetting(doroGui, "Award", "奖励收取", "xs", true)
doroGui.Tips.SetTip(cbAward, "Award")
BtnAward := doroGui.Add("Button", "x210 yp-2 w30 h30", "🔧").OnEvent("Click", (Ctrl, Info) => ShowSetting("Award"))
cbEvent := AddCheckboxSetting(doroGui, "Event", "活动", "xs", true)
doroGui.Tips.SetTip(cbEvent, "Event")
BtnEvent := doroGui.Add("Button", "x210 yp-2 w30 h30", "🔧").OnEvent("Click", (Ctrl, Info) => ShowSetting("Event"))
cbAfterText := doroGui.Add("Text", "x20 yp+40 Section +0x0100", "　任务完成后")
doroGui.Tips.SetTip(cbAfterText, "After Task Completion")
BtnAfter := doroGui.Add("Button", "x210 yp-2 w30 h30", "🔧").OnEvent("Click", (Ctrl, Info) => ShowSetting("After"))
doroGui.SetFont('s12')
BtnDoro := doroGui.Add("Button", "w80 xm+80 yp+40", "DORO!")
doroGui.Tips.SetTip(BtnDoro, "开始运行Doro|Start Doro")
BtnDoro.OnEvent("Click", ClickOnDoro)
doroGui.SetFont('s16')
BtnSaveSettings := doroGui.Add("Button", "x210 yp+2 w30 h30 ", "♻️")
doroGui.Tips.SetTip(BtnSaveSettings, "保存并重启Doro|Save and Restart Doro")
BtnSaveSettings.OnEvent("Click", SaveAndRestart)
;tag 二级设置
doroGui.SetFont('s12')
TaskSettings := doroGui.AddGroupBox("x280 y10 w300 h640 +0x0100", "任务设置")
doroGui.Tips.SetTip(TaskSettings, "Task Settings")
;tag 二级默认Default
SetNotice1 := doroGui.Add("Text", "x290 y40 w280 +0x0100 Section", "====提示====")
doroGui.Tips.SetTip(SetNotice1, "Notice")
g_settingPages["Default"].Push(SetNotice1)
SetNotice2 := doroGui.Add("Text", "x290 y+10 w280 +0x0100", "鼠标悬停以查看对应详细信息")
doroGui.Tips.SetTip(SetNotice2, "Hover the mouse to view the corresponding detailed information")
g_settingPages["Default"].Push(SetNotice2)
SetSize1 := doroGui.Add("Text", "x290 y+10 w280 +0x0100", "====游戏尺寸设置====")
doroGui.Tips.SetTip(SetSize1, "Game size Settings")
g_settingPages["Default"].Push(SetSize1)
SetSize2 := doroGui.Add("Text", "x290 y+10 w280 +0x0100", "推荐1080p分辨率的用户使用游戏内部的全屏（而不通过本软件调整）`n1080p以上分辨率的用户选择1080p")
doroGui.Tips.SetTip(SetSize2, "For 1080p, use in-game fullscreen (not via this app), and for higher resolutions, select 1080p.")
g_settingPages["Default"].Push(SetSize2)
Btn1080 := doroGui.Add("Button", "w150 h30 ", "点击设置为1080p")
Btn1080.OnEvent("Click", (Ctrl, Info) => AdjustSize(1920, 1080))
doroGui.Tips.SetTip(Btn1080, "Click to set to 1080p")
g_settingPages["Default"].Push(Btn1080)
;tag 二级设置Settings
SetNormalTitle := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====基础设置====")
g_settingPages["Settings"].Push(SetNormalTitle)
cbCloseAdvertisement := AddCheckboxSetting(doroGui, "CloseAdvertisement", "移除广告提示[铜Doro]", "R1")
doroGui.Tips.SetTip(cbCloseAdvertisement, "Remove ads[Copper Doro]")
g_settingPages["Settings"].Push(cbCloseAdvertisement)
cbAutoSwitchLanguage := AddCheckboxSetting(doroGui, "AutoSwitchLanguage", "自动切换语言", "R1")
doroGui.Tips.SetTip(cbAutoSwitchLanguage, "Switch language automatically")
g_settingPages["Settings"].Push(cbAutoSwitchLanguage)
DropDownListLanguage := doroGui.Add("DropDownList", "w150 Choose" g_numeric_settings["LanguageList"], ["ENGLISH", "日本语", "中文 (繁体)", "中文 (简体)"])
doroGui.Tips.SetTip(DropDownListLanguage, "程序会最终切换回你选择的语言`nThe program will eventually switch back to the language you have chosen")
DropDownListLanguage.OnEvent("Change", (Ctrl, Info) => g_numeric_settings["LanguageList"] := Ctrl.Value)
g_settingPages["Settings"].Push(DropDownListLanguage)
cbAutoCheckVersion := AddCheckboxSetting(doroGui, "AutoCheckUpdate", "自动检查更新", "R1")
doroGui.Tips.SetTip(cbAutoCheckVersion, "Check for updates automatically at startup")
g_settingPages["Settings"].Push(cbAutoCheckVersion)
cbAutoCheckUserGroup := AddCheckboxSetting(doroGui, "AutoCheckUserGroup", "自动检查用户组", "R1")
doroGui.Tips.SetTip(cbAutoCheckUserGroup, "Check user group automatically at startup")
g_settingPages["Settings"].Push(cbAutoCheckUserGroup)
cbAutoDeleteOldFile := AddCheckboxSetting(doroGui, "AutoDeleteOldFile", "自动删除旧版本", "R1")
doroGui.Tips.SetTip(cbAutoDeleteOldFile, "Delete old versions automatically after updating")
g_settingPages["Settings"].Push(cbAutoDeleteOldFile)
CheckAutoText := AddCheckboxSetting(doroGui, "CheckAuto", "自动开启自动射击和爆裂", "R1")
doroGui.Tips.SetTip(CheckAutoText, "Enable Auto Shoot and Burst automatically")
g_settingPages["Settings"].Push(CheckAutoText)
;tag 二级登录Login
SetLogin := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====登录====")
g_settingPages["Login"].Push(SetLogin)
StartupText := AddCheckboxSetting(doroGui, "AutoStartNikke", "使用脚本启动NIKKE[金Doro]", "R1")
doroGui.Tips.SetTip(StartupText, "勾选后，脚本会尝试通过填写的路径启动NIKKE`nLaunch NIKKEwith Script:If checked, the script will attempt to start NIKKE using the specified path")
g_settingPages["Login"].Push(StartupText)
StartupPathText := doroGui.Add("Text", "xs+20 R1 +0x0100", "启动器路径")
doroGui.Tips.SetTip(StartupPathText, "Path of NIKKE Launcher")
g_settingPages["Login"].Push(StartupPathText)
StartupPathEdit := doroGui.Add("Edit", "x+5 yp+1 w160 h20")
StartupPathEdit.Value := g_numeric_settings["StartupPath"]
StartupPathEdit.OnEvent("Change", (Ctrl, Info) => g_numeric_settings["StartupPath"] := Ctrl.Value)
doroGui.Tips.SetTip(StartupPathEdit, "例如：C:\NIKKE\Launcher\nikke_launcher.exe`nFor example: C:\NIKKE\Launcher\nikke_launcher.exe")
g_settingPages["Login"].Push(StartupPathEdit)
SetTimedstart := AddCheckboxSetting(doroGui, "Timedstart", "定时启动[金Doro]", "xs R1")
doroGui.Tips.SetTip(SetTimedstart, "勾选后，脚本会在指定时间自动视为点击DORO！，让程序保持后台即可`nTimed start[Gold Doro]:If checked, the script will Click DORO! at the specified time. Just keep the program running in the background.")
g_settingPages["Login"].Push(SetTimedstart)
StartupTimeText := doroGui.Add("Text", "xs+20 R1 +0x0100", "启动时间")
doroGui.Tips.SetTip(StartupTimeText, "Time to start NIKKE")
g_settingPages["Login"].Push(StartupTimeText)
StartupTimeEdit := doroGui.Add("Edit", "x+5 yp+1 w100 h20")
StartupTimeEdit.Value := g_numeric_settings["StartupTime"]
StartupTimeEdit.OnEvent("Change", (Ctrl, Info) => g_numeric_settings["StartupTime"] := Ctrl.Value)
doroGui.Tips.SetTip(StartupTimeEdit, "填写格式为 HHmmss 例如：080000 表示早上8点`nTime format must be HHmmss. For example, 080000 represents 08:00 AM.")
g_settingPages["Login"].Push(StartupTimeEdit)
cbLoopMode := AddCheckboxSetting(doroGui, "LoopMode", "自律模式", "xs+20 R1 +0x0100")
doroGui.Tips.SetTip(cbLoopMode, "勾选后，当 DoroHelper 完成所有已选任务后，NIKKE将自动退出，同时会自动重启Doro，以便再次定时启动`nLoopMode:If checked, when DoroHelper completes all selected tasks, NIKKE will automatically exit, and Doro will automatically restart to facilitate timed restarts.")
g_settingPages["Login"].Push(cbLoopMode)
;tag 二级商店Shop
SetShop := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====商店选项====")
g_settingPages["Shop"].Push(SetShop)
SetShopCashTitle := doroGui.Add("Text", "R1", "===付费商店===")
doroGui.Tips.SetTip(SetShopCashTitle, "Cash Shop")
g_settingPages["Shop"].Push(SetShopCashTitle)
SetShopCashFree := AddCheckboxSetting(doroGui, "ShopCashFree", "购买付费商店免费珠宝", "R1")
doroGui.Tips.SetTip(SetShopCashFree, "Automatically purchase free gems when they appear in the cash shop")
g_settingPages["Shop"].Push(SetShopCashFree)
SetShopCashFreePackage := AddCheckboxSetting(doroGui, "ShopCashFreePackage", "购买付费商店免费礼包", "R1")
doroGui.Tips.SetTip(SetShopCashFreePackage, "Automatically purchase free packages when they appear in the cash shop")
g_settingPages["Shop"].Push(SetShopCashFreePackage)
SetShopGeneralTitle := doroGui.Add("Text", "R1", "===普通商店===")
doroGui.Tips.SetTip(SetShopCashTitle, "General shop")
g_settingPages["Shop"].Push(SetShopGeneralTitle)
SetShopGeneralFree := AddCheckboxSetting(doroGui, "ShopGeneralFree", "购买普通商店免费商品", "R1")
doroGui.Tips.SetTip(SetShopGeneralFree, "Automatically purchase free item when they appear in the General shop")
g_settingPages["Shop"].Push(SetShopGeneralFree)
SetShopGeneralDust := AddCheckboxSetting(doroGui, "ShopGeneralDust", "用信用点买芯尘盒", "R1")
doroGui.Tips.SetTip(SetShopGeneralDust, "Automatically purchase Core Dust Case using Credit when they appear in the General shop")
g_settingPages["Shop"].Push(SetShopGeneralDust)
SetShopGeneralPackage := AddCheckboxSetting(doroGui, "ShopGeneralPackage", "购买简介个性化礼包", "R1")
doroGui.Tips.SetTip(SetShopGeneralPackage, "Automatically purchase Profile Custom Pack in the General shop")
g_settingPages["Shop"].Push(SetShopGeneralPackage)
SetShopArenaTitle := doroGui.Add("Text", " R1 xs +0x0100", "===竞技场商店===")
doroGui.Tips.SetTip(SetShopArenaTitle, "Arena Shop")
g_settingPages["Shop"].Push(SetShopArenaTitle)
; SetShopArena := AddCheckboxSetting(doroGui, "ShopArena", "总开关", "R1")
; g_settingPages["Shop"].Push(SetShopArena)
SetShopArenaBookFire := AddCheckboxSetting(doroGui, "ShopArenaBookFire", "燃烧", "R1")
doroGui.Tips.SetTip(SetShopArenaBookFire, "Fire")
g_settingPages["Shop"].Push(SetShopArenaBookFire)
SetShopArenaBookWater := AddCheckboxSetting(doroGui, "ShopArenaBookWater", "水冷", "R1 X+0.1")
doroGui.Tips.SetTip(SetShopArenaBookWater, "Water")
g_settingPages["Shop"].Push(SetShopArenaBookWater)
SetShopArenaBookWind := AddCheckboxSetting(doroGui, "ShopArenaBookWind", "风压", "R1 X+0.1")
doroGui.Tips.SetTip(SetShopArenaBookWind, "Wind")
g_settingPages["Shop"].Push(SetShopArenaBookWind)
SetShopArenaBookElec := AddCheckboxSetting(doroGui, "ShopArenaBookElec", "电击", "R1 X+0.1")
doroGui.Tips.SetTip(SetShopArenaBookElec, "Electric")
g_settingPages["Shop"].Push(SetShopArenaBookElec)
SetShopArenaBookIron := AddCheckboxSetting(doroGui, "ShopArenaBookIron", "铁甲", "R1 X+0.1")
doroGui.Tips.SetTip(SetShopArenaBookIron, "Iron")
g_settingPages["Shop"].Push(SetShopArenaBookIron)
SetShopArenaBookBox := AddCheckboxSetting(doroGui, "ShopArenaBookBox", "购买代码手册宝箱", "xs R1.2")
doroGui.Tips.SetTip(SetShopArenaBookBox, "Automatically purchase Code Manual Selection Box when they appear in the Arena shop")
g_settingPages["Shop"].Push(SetShopArenaBookBox)
SetShopArenaPackage := AddCheckboxSetting(doroGui, "ShopArenaPackage", "购买简介个性化礼包", "R1.2")
doroGui.Tips.SetTip(SetShopArenaPackage, "Automatically purchase Profile Custom Pack in the Arena shop")
g_settingPages["Shop"].Push(SetShopArenaPackage)
SetShopArenaFurnace := AddCheckboxSetting(doroGui, "ShopArenaFurnace", "购买公司武器熔炉", "R1.2")
doroGui.Tips.SetTip(SetShopArenaFurnace, "Automatically purchase Manufacturer Arms Furnace in the Arena shop")
g_settingPages["Shop"].Push(SetShopArenaFurnace)
SetShopRecyclingTitle := doroGui.Add("Text", "R1 xs Section +0x0100", "===废铁商店===")
doroGui.Tips.SetTip(SetShopRecyclingTitle, "Recycling Shop")
g_settingPages["Shop"].Push(SetShopRecyclingTitle)
; SetShopRecycling := AddCheckboxSetting(doroGui, "ShopRecycling", "总开关", "R1")
; g_settingPages["Shop"].Push(SetShopRecycling)
SetShopRecyclingGem := AddCheckboxSetting(doroGui, "ShopRecyclingGem", "购买珠宝", "R1.2")
doroGui.Tips.SetTip(SetShopRecyclingGem, "Automatically purchase Gems when they appear in the Recycling shop")
g_settingPages["Shop"].Push(SetShopRecyclingGem)
SetShopRecyclingVoucher := AddCheckboxSetting(doroGui, "ShopRecyclingVoucher", "购买全部好感券", "R1.2")
doroGui.Tips.SetTip(SetShopRecyclingVoucher, "Automatically purchase all types of Vouchers when they appear in the Recycling shop")
g_settingPages["Shop"].Push(SetShopRecyclingVoucher)
SetShopRecyclingResources := AddCheckboxSetting(doroGui, "ShopRecyclingResources", "购买全部养成资源", "R1.2")
doroGui.Tips.SetTip(SetShopRecyclingResources, "Automatically purchase all types of Development Resources when they appear in the Recycling shop")
g_settingPages["Shop"].Push(SetShopRecyclingResources)
SetRecyclingTeamworkBox := AddCheckboxSetting(doroGui, "ShopRecyclingTeamworkBox", "购买团队协作宝箱", "R1.2")
doroGui.Tips.SetTip(SetRecyclingTeamworkBox, "Automatically purchase Teamwork Box when they appear in the Recycling shop")
g_settingPages["Shop"].Push(SetRecyclingTeamworkBox)
SetShopRecyclingKitBox := AddCheckboxSetting(doroGui, "ShopRecyclingKitBox", "购买保养工具箱", "R1.2")
doroGui.Tips.SetTip(SetShopRecyclingKitBox, "Automatically purchase Maintenance Kit Box when they appear in the Recycling shop")
g_settingPages["Shop"].Push(SetShopRecyclingKitBox)
SetShopRecyclingArmsBox := AddCheckboxSetting(doroGui, "ShopRecyclingArms", "购买企业精选武装", "R1.2")
doroGui.Tips.SetTip(SetShopRecyclingArmsBox, "Automatically purchase Manufacturer Arms when they appear in the Recycling shop")
g_settingPages["Shop"].Push(SetShopRecyclingArmsBox)
;tag 二级模拟室SimulationRoom
SetSimulationTitle := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====模拟室选项====")
g_settingPages["SimulationRoom"].Push(SetSimulationTitle)
SetSimulationNormal := AddCheckboxSetting(doroGui, "SimulationNormal", "普通模拟室", "R1")
doroGui.Tips.SetTip(SetSimulationNormal, "此功能需要你在游戏内已经解锁了快速模拟功能才能正常使用，需要预勾选5C`nNormal Simulation Room:This feature requires you to have unlocked the Quick Simulation function in the game to work properly, and you need to pre-check 5C")
g_settingPages["SimulationRoom"].Push(SetSimulationNormal)
SetSimulationOverClock := AddCheckboxSetting(doroGui, "SimulationOverClock", "模拟室超频", "R1")
doroGui.Tips.SetTip(SetSimulationOverClock, "程序会默认尝试使用你上次进行超频挑战时选择的增益标签组合。挑战难度必须是25，且需要勾选「禁止无关人员进入」和「好战型战术」`nSimulationOverClock:The program will by default try to use the combination of boost tags you selected the last time you did an overclock challenge. The challenge difficulty must be 25, and you need to check 'Relevant Personnel Only' and 'Aggressive Tactics'")
g_settingPages["SimulationRoom"].Push(SetSimulationOverClock)
;tag 二级竞技场Arena
SetArenaTitle := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====竞技场选项====")
g_settingPages["Arena"].Push(SetArenaTitle)
SetAwardArena := AddCheckboxSetting(doroGui, "AwardArena", "竞技场收菜", "R1")
doroGui.Tips.SetTip(SetAwardArena, "Claim Arena Accumulated Rewards")
g_settingPages["Arena"].Push(SetAwardArena)
SetArenaRookie := AddCheckboxSetting(doroGui, "ArenaRookie", "新人竞技场", "R1")
doroGui.Tips.SetTip(SetArenaRookie, "使用五次每日免费挑战次数挑战第三位`nRookie Arena:Use five daily free challenge attempts to challenge the third place")
g_settingPages["Arena"].Push(SetArenaRookie)
SetArenaSpecial := AddCheckboxSetting(doroGui, "ArenaSpecial", "特殊竞技场", "R1")
doroGui.Tips.SetTip(SetArenaSpecial, "使用两次每日免费挑战次数挑战第三位`nSpecial Arena:Use two daily free challenge attempts to challenge the third place")
g_settingPages["Arena"].Push(SetArenaSpecial)
SetArenaChampion := AddCheckboxSetting(doroGui, "ArenaChampion", "冠军竞技场", "R1")
doroGui.Tips.SetTip(SetArenaChampion, "在活动期间进行跟风竞猜`nChampion Arena:Follow the Trend with your event predictions.")
g_settingPages["Arena"].Push(SetArenaChampion)
;tag 二级无限之塔Tower
SetTowerTitle := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====无限之塔选项====")
g_settingPages["Tower"].Push(SetTowerTitle)
SetTowerCompany := AddCheckboxSetting(doroGui, "TowerCompany", "爬企业塔", "R1")
doroGui.Tips.SetTip(SetTowerCompany, "自动挑战当前可进入的所有企业塔，直到无法通关或次数用尽`nCompany Tower:Automatically challenge all currently accessible company towers until you can no longer pass or run out of attempts")
g_settingPages["Tower"].Push(SetTowerCompany)
SetTowerUniversal := AddCheckboxSetting(doroGui, "TowerUniversal", "爬通用塔", "R1")
doroGui.Tips.SetTip(SetTowerUniversal, "自动挑战通用无限之塔，直到无法通关`nUniversal Tower:Automatically challenge the Tribe Tower until you can no longer pass")
g_settingPages["Tower"].Push(SetTowerUniversal)
;tag 二级拦截战Interception
SetInterceptionTitle := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====拦截战选项====")
g_settingPages["Interception"].Push(SetInterceptionTitle)
SetInterceptionNormal := AddCheckboxSetting(doroGui, "InterceptionNormal", "普通拦截", "R1")
doroGui.Tips.SetTip(SetInterceptionNormal, "暂不支持`nNormal Interception:Not supported yet")
g_settingPages["Interception"].Push(SetInterceptionNormal)
DropDownListBossNormal := doroGui.Add("DropDownList", "x+10 w150 Choose" g_numeric_settings["InterceptionBossNormal"], ["Level D", "Level S", "特殊目标拦截战"])
DropDownListBossNormal.OnEvent("Change", (Ctrl, Info) => g_numeric_settings["InterceptionBossNormal"] := Ctrl.Value)
g_settingPages["Interception"].Push(DropDownListBossNormal)
SetInterceptionAnomaly := AddCheckboxSetting(doroGui, "InterceptionAnomaly", "异常拦截", "R1 xs")
doroGui.Tips.SetTip(SetInterceptionAnomaly, "Anomaly Interception")
g_settingPages["Interception"].Push(SetInterceptionAnomaly)
DropDownListBoss := doroGui.Add("DropDownList", "x+10 w150 Choose" g_numeric_settings["InterceptionBoss"], ["克拉肯，编队1", "镜像容器，编队2", "茵迪维利亚，编队3", "过激派，编队4", "死神，编队5"])
doroGui.Tips.SetTip(DropDownListBoss, "例如，选择克拉肯(模组)，编队1，则程序会使用你的编队1去挑战克拉肯`nfor example, if you choose Kraken, Team 1, the program will use your Team 1 to challenge the Kraken`n克拉肯(模组):Kraken(Module)`n镜像容器(手):Mirage Container(Hand)`n茵迪维利亚(衣):Indivilia(Clothes)`n过激派(头):UItra(Head)`n死神(脚):Harvester(foot)")
DropDownListBoss.OnEvent("Change", (Ctrl, Info) => g_numeric_settings["InterceptionBoss"] := Ctrl.Value)
g_settingPages["Interception"].Push(DropDownListBoss)
SetInterceptionNormalTitle := doroGui.Add("Text", "R1 +0x0100 xs", "===基础选项===")
doroGui.Tips.SetTip(SetInterceptionNormalTitle, "Basic Options")
g_settingPages["Interception"].Push(SetInterceptionNormalTitle)
SetInterceptionScreenshot := AddCheckboxSetting(doroGui, "InterceptionScreenshot", "结果截图", "R1.2")
doroGui.Tips.SetTip(SetInterceptionScreenshot, "自动截取结算画面的图片，并保存在程序目录下的「截图」文件夹中`nAutomatic screenshot of the settlement screen, saved in the '截图' folder in the program directory")
g_settingPages["Interception"].Push(SetInterceptionScreenshot)
SetRedCircle := AddCheckboxSetting(doroGui, "InterceptionRedCircle", "自动打红圈", "R1.2")
doroGui.Tips.SetTip(SetRedCircle, "请务必在设置-战斗-控制中开启「同步游标与准星」|只对克拉肯有效`nMake sure to turn on 'Sync Cursor and Crosshair' in Settings - Combat - Controls | Only effective for Kraken")
g_settingPages["Interception"].Push(SetRedCircle)
SetInterceptionExit7 := AddCheckboxSetting(doroGui, "InterceptionExit7", "满7自动退出[金Doro]", "R1.2")
doroGui.Tips.SetTip(SetInterceptionExit7, "Exit immediately after the Boss reaches phase 7[Gold Doro]")
g_settingPages["Interception"].Push(SetInterceptionExit7)
;tag 二级奖励Award
SetAwardTitle := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====奖励选项====")
g_settingPages["Award"].Push(SetAwardTitle)
SetAwardNormalTitle := doroGui.Add("Text", "R1", "===常规奖励===")
doroGui.Tips.SetTip(SetAwardNormalTitle, "Regular Awards")
g_settingPages["Award"].Push(SetAwardNormalTitle)
SetAwardOutpost := AddCheckboxSetting(doroGui, "AwardOutpost", "领取前哨基地防御奖励+1次免费歼灭", "R1")
doroGui.Tips.SetTip(SetAwardOutpost, "Automatically collects the Outpost Defense rewards and uses 1 free annihilation.")
g_settingPages["Award"].Push(SetAwardOutpost)
SetAwardOutpostDispatch := AddCheckboxSetting(doroGui, "AwardOutpostDispatch", "领取并重新派遣委托", "R1 xs+15")
doroGui.Tips.SetTip(SetAwardOutpostDispatch, "Automatically collects and redeploys Outpost Dispatchs")
g_settingPages["Award"].Push(SetAwardOutpostDispatch)
SetAwardAdvise := AddCheckboxSetting(doroGui, "AwardAdvise", "咨询妮姬", "R1 xs Section")
doroGui.Tips.SetTip(SetAwardAdvise, "你可以通过在游戏内将妮姬设置为收藏状态来调整咨询的优先顺序`nNikke Advise:You can adjust the priority of consultation by setting Nikke to the collection status in the game")
g_settingPages["Award"].Push(SetAwardAdvise)
SetAwardAdviseAward := AddCheckboxSetting(doroGui, "AwardAdviseAward", "自动观看新花絮[金Doro]", "R1 xs+15")
doroGui.Tips.SetTip(SetAwardAdviseAward, "自动观看妮姬升级产生的新花絮并领取奖励`nAdviseAward[Gold Doro]:automatically watch new Episode generated by Nikke's upgrade and receive rewards")
g_settingPages["Award"].Push(SetAwardAdviseAward)
SetAwardAppreciation := AddCheckboxSetting(doroGui, "AwardAppreciation", "花絮鉴赏会", "R1 xs+15")
doroGui.Tips.SetTip(SetAwardAppreciation, "Episode Viewing")
g_settingPages["Award"].Push(SetAwardAppreciation)
SetAwardFriendPoint := AddCheckboxSetting(doroGui, "AwardFriendPoint", "好友点数收发", "R1 xs")
doroGui.Tips.SetTip(SetAwardFriendPoint, "Receive and send Social Points")
g_settingPages["Award"].Push(SetAwardFriendPoint)
SetAwardMail := AddCheckboxSetting(doroGui, "AwardMail", "邮箱收取", "R1.2")
doroGui.Tips.SetTip(SetAwardMail, "Automatically collect all items in the mailbox")
g_settingPages["Award"].Push(SetAwardMail)
SetAwardRanking := AddCheckboxSetting(doroGui, "AwardRanking", "方舟排名奖励", "R1.2")
doroGui.Tips.SetTip(SetAwardRanking, "Automatically collect Ark Ranking Rewards")
g_settingPages["Award"].Push(SetAwardRanking)
SetAwardDaily := AddCheckboxSetting(doroGui, "AwardDaily", "任务收取", "R1.2")
doroGui.Tips.SetTip(SetAwardDaily, "收取每日任务、每周任务、主线任务以及成就等已完成任务的奖励`nDailyAward:Automatically collect rewards for completed Daily, Weekly, Main, and Achievement tasks")
g_settingPages["Award"].Push(SetAwardDaily)
SetAwardPass := AddCheckboxSetting(doroGui, "AwardPass", "通行证收取", "R1.2")
doroGui.Tips.SetTip(SetAwardPass, "Collect rewards in the pass")
g_settingPages["Award"].Push(SetAwardPass)
SetAwardCooperate := AddCheckboxSetting(doroGui, "AwardCooperate", "协同作战", "R1.2")
doroGui.Tips.SetTip(SetAwardCooperate, "参与每日三次的普通难度协同作战|也可参与大活动的协同作战`nCooperate:Participate in the three daily normal difficulty cooperative battles | You can also participate in the cooperative battles of events")
g_settingPages["Award"].Push(SetAwardCooperate)
SetAwardSoloRaid := AddCheckboxSetting(doroGui, "AwardSoloRaid", "单人突击日常", "R1.2")
doroGui.Tips.SetTip(SetAwardSoloRaid, "参与单人突击，自动对最新的关卡进行战斗或快速战斗`nSolo Raid:Participate in Solo Raid, automatically fight or quick fight the latest level")
g_settingPages["Award"].Push(SetAwardSoloRaid)
SetLimitedAwardTitle := doroGui.Add("Text", "R1 Section +0x0100", "===限时奖励===")
doroGui.Tips.SetTip(SetLimitedAwardTitle, "设置在特定活动期间可领取的限时奖励或可参与的限时活动`nSet time-limited rewards or time-limited activities that can be participated in during specific events")
g_settingPages["Award"].Push(SetLimitedAwardTitle)
SetAwardFreeRecruit := AddCheckboxSetting(doroGui, "AwardFreeRecruit", "活动期间每日免费招募", "R1.2")
doroGui.Tips.SetTip(SetAwardFreeRecruit, "如果在特定活动期间有每日免费招募机会，则自动进行募`nFree Recruit:if there is a daily free recruitment opportunity during a specific event, it will be recruited automatically")
g_settingPages["Award"].Push(SetAwardFreeRecruit)
;tag 二级活动Event
SetEventUniversal := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====通用选项====")
doroGui.Tips.SetTip(SetEventUniversal, "Universal Options")
g_settingPages["Event"].Push(SetEventUniversal)
SetAutoFill := AddCheckboxSetting(doroGui, "AutoFill", "剧情活动自动添加妮姬[金Doro]", "R1")
doroGui.Tips.SetTip(SetAutoFill, "Automatically add Nikke for story events[Gold Doro]")
g_settingPages["Event"].Push(SetAutoFill)
SetEventTitle := doroGui.Add("Text", "R1 +0x0100", "====活动选项====")
doroGui.Tips.SetTip(SetEventTitle, "Event Options")
g_settingPages["Event"].Push(SetEventTitle)
SetEventSmall := AddCheckboxSetting(doroGui, "EventSmall", "小活动[银Doro](GO!NINJA THIEF!)", "R1")
doroGui.Tips.SetTip(SetEventSmall, "Small Events[Silver Doro]")
g_settingPages["Event"].Push(SetEventSmall)
SetEventSmallChallenge := AddCheckboxSetting(doroGui, "EventSmallChallenge", "小活动挑战", "R1 xs+15")
doroGui.Tips.SetTip(SetEventSmallChallenge, "Small Events Challenge")
g_settingPages["Event"].Push(SetEventSmallChallenge)
SetEventSmallStory := AddCheckboxSetting(doroGui, "EventSmallStory", "小活动剧情", "R1 xs+15")
doroGui.Tips.SetTip(SetEventSmallStory, "Small Events Story")
g_settingPages["Event"].Push(SetEventSmallStory)
SetEventSmallMission := AddCheckboxSetting(doroGui, "EventSmallMission", "小活动任务", "R1 xs+15")
doroGui.Tips.SetTip(SetEventSmallMission, "Small Events Mission")
g_settingPages["Event"].Push(SetEventSmallMission)
SetEventLarge := AddCheckboxSetting(doroGui, "EventLarge", "大活动[银Doro](未开放)", "R1 xs")
doroGui.Tips.SetTip(SetEventLarge, "Large Events[Silver Doro]")
g_settingPages["Event"].Push(SetEventLarge)
SetEventLargeSign := AddCheckboxSetting(doroGui, "EventLargeSign", "大活动签到", "R1 xs+15")
doroGui.Tips.SetTip(SetEventLargeSign, "Large Events Sign-in")
g_settingPages["Event"].Push(SetEventLargeSign)
SetEventLargeChallenge := AddCheckboxSetting(doroGui, "EventLargeChallenge", "大活动挑战", "R1 xs+15")
doroGui.Tips.SetTip(SetEventLargeChallenge, "Large Events Challenge")
g_settingPages["Event"].Push(SetEventLargeChallenge)
SetEventLargeStory := AddCheckboxSetting(doroGui, "EventLargeStory", "大活动剧情", "R1 xs+15")
doroGui.Tips.SetTip(SetEventLargeStory, "Large Events Story")
g_settingPages["Event"].Push(SetEventLargeStory)
SetEventLargeCooperate := AddCheckboxSetting(doroGui, "EventLargeCooperate", "大活动协同作战", "R1 xs+15")
doroGui.Tips.SetTip(SetEventLargeCooperate, "Large Events Cooperate")
g_settingPages["Event"].Push(SetEventLargeCooperate)
SetEventLargeMinigame := AddCheckboxSetting(doroGui, "EventLargeMinigame", "大活动小游戏", "R1 xs+15")
doroGui.Tips.SetTip(SetEventLargeMinigame, "Large Event Minigame")
g_settingPages["Event"].Push(SetEventLargeMinigame)
SetEventLargeDaily := AddCheckboxSetting(doroGui, "EventLargeDaily", "大活动奖励", "R1 xs+15")
doroGui.Tips.SetTip(SetEventLargeDaily, "Large Events Daily Rewards")
g_settingPages["Event"].Push(SetEventLargeDaily)
SetEventSpecial := AddCheckboxSetting(doroGui, "EventSpecial", "特殊活动[银Doro](未开放)", "R1 xs")
doroGui.Tips.SetTip(SetEventSpecial, "Special Events[Silver Doro]")
g_settingPages["Event"].Push(SetEventSpecial)
SetEventSpecialSign := AddCheckboxSetting(doroGui, "EventSpecialSign", "特殊活动签到", "R1 xs+15")
doroGui.Tips.SetTip(SetEventSpecialSign, "Special Events Sign-in")
g_settingPages["Event"].Push(SetEventSpecialSign)
SetEventSpecialChallenge := AddCheckboxSetting(doroGui, "EventSpecialChallenge", "特殊活动挑战", "R1 xs+15")
doroGui.Tips.SetTip(SetEventSpecialChallenge, "Special Events Challenge")
g_settingPages["Event"].Push(SetEventSpecialChallenge)
SetEventSpecialStory := AddCheckboxSetting(doroGui, "EventSpecialStory", "特殊活动剧情❔️", "R1 xs+15")
doroGui.Tips.SetTip(SetEventSpecialStory, "部分关卡可能有特殊关，此时需要手动完成任务`nSpecial Events Story:Some levels may have special stages, which need to be completed manually")
g_settingPages["Event"].Push(SetEventSpecialStory)
SetEventSpecialCooperate := AddCheckboxSetting(doroGui, "EventSpecialCooperate", "特殊活动协同作战", "R1 xs+15")
doroGui.Tips.SetTip(SetEventSpecialCooperate, "Special Events Cooperate")
g_settingPages["Event"].Push(SetEventSpecialCooperate)
SetEventSpecialMinigame := AddCheckboxSetting(doroGui, "EventSpecialMinigame", "特殊活动小游戏", "R1 xs+15")
doroGui.Tips.SetTip(SetEventSpecialMinigame, "Special Event Minigame")
g_settingPages["Event"].Push(SetEventSpecialMinigame)
SetEventSpecialDaily := AddCheckboxSetting(doroGui, "EventSpecialDaily", "特殊活动奖励", "R1 xs+15")
doroGui.Tips.SetTip(SetEventSpecialDaily, "Special Events Daily Rewards")
g_settingPages["Event"].Push(SetEventSpecialDaily)
;tag 二级设置After
SetAfterTitle := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====任务完成后====")
g_settingPages["After"].Push(SetAfterTitle)
cbClearRed := AddCheckboxSetting(doroGui, "ClearRed", "任务完成后[金Doro]", "R1")
g_settingPages["After"].Push(cbClearRed)
cbClearRedRecycling := AddCheckboxSetting(doroGui, "ClearRedRecycling", "升级循环室", "R1 xs+15")
doroGui.Tips.SetTip(cbClearRedRecycling, "Upgrade Recycle Room")
g_settingPages["After"].Push(cbClearRedRecycling)
cbClearRedSynchro := AddCheckboxSetting(doroGui, "ClearRedSynchro", "升级同步器", "R1 xs+15")
doroGui.Tips.SetTip(cbClearRedSynchro, "Upgrade Synchro Device")
g_settingPages["After"].Push(cbClearRedSynchro)
cbClearRedSynchroForce := AddCheckboxSetting(doroGui, "ClearRedSynchroForce", "开箱子", "R1 x+5")
doroGui.Tips.SetTip(cbClearRedSynchroForce, "Open Resource Cases")
g_settingPages["After"].Push(cbClearRedSynchroForce)
cbClearRedLimit := AddCheckboxSetting(doroGui, "ClearRedLimit", "突破/强化妮姬", "R1 xs+15")
doroGui.Tips.SetTip(cbClearRedLimit, "Limit Break/Enhance Nikke")
g_settingPages["After"].Push(cbClearRedLimit)
cbClearRedCube := AddCheckboxSetting(doroGui, "ClearRedCube", "升级魔方", "R1 xs+15")
doroGui.Tips.SetTip(cbClearRedCube, "Upgrade Cubes")
g_settingPages["After"].Push(cbClearRedCube)
cbClearRedNotice := AddCheckboxSetting(doroGui, "ClearRedNotice", "清除公告红点", "R1 xs+15")
doroGui.Tips.SetTip(cbClearRedNotice, "Clear Notice Red Dot")
g_settingPages["After"].Push(cbClearRedNotice)
cbClearRedWallpaper := AddCheckboxSetting(doroGui, "ClearRedWallpaper", "清除壁纸红点", "R1 xs+15")
doroGui.Tips.SetTip(cbClearRedWallpaper, "Clear Wallpaper Red Dot")
g_settingPages["After"].Push(cbClearRedWallpaper)
cbClearRedProfile := AddCheckboxSetting(doroGui, "ClearRedProfile", "清除个人页红点", "R1 xs+15")
doroGui.Tips.SetTip(cbClearRedProfile, "Clear Profile Red Dot")
g_settingPages["After"].Push(cbClearRedProfile)
cbClearRedBla := AddCheckboxSetting(doroGui, "ClearRedBla", "清除blabla红点", "R1 xs+15")
doroGui.Tips.SetTip(cbClearRedBla, "Clear blabla Red Dot")
g_settingPages["After"].Push(cbClearRedBla)
cbOpenBlablalink := AddCheckboxSetting(doroGui, "OpenBlablalink", "打开Blablalink", "R1 xs")
doroGui.Tips.SetTip(cbOpenBlablalink, "Open the Blablalink website")
g_settingPages["After"].Push(cbOpenBlablalink)
cbCheckEvent := AddCheckboxSetting(doroGui, "CheckEvent", "活动结束提醒", "R1")
doroGui.Tips.SetTip(cbCheckEvent, "在大小活动结束前进行提醒`nEvent End Reminder:remind you before the end of major and minor events")
g_settingPages["After"].Push(cbCheckEvent)
cbDoroClosing := AddCheckboxSetting(doroGui, "DoroClosing", "关闭DoroHelper", "R1")
doroGui.Tips.SetTip(cbDoroClosing, "Close DoroHelper")
g_settingPages["After"].Push(cbDoroClosing)
;tag 妙妙工具
doroGui.SetFont('s12')
doroGui.AddGroupBox("x600 y10 w400 h240 Section", "妙妙工具")
MiaoInfo := doroGui.Add("Text", "xp+70 yp-1 R1 +0x0100", "❔️")
doroGui.Tips.SetTip(MiaoInfo, "提供一些与日常任务流程无关的额外小功能`nProvides ancillary features that operate outside the scope of the daily task workflow.")
; 仓库地址
btnRepository := doroGui.Add("Button", "xp xs+10 w80 h30", "仓库地址")
doroGui.Tips.SetTip(btnRepository, "github repository")
btnRepository.OnEvent("Click", (*) => Run("https://github.com/1204244136/DoroHelper"))
; Blablalink
btnBlablalink := doroGui.Add("Button", "x+10 w60 h30", "Blalink")
btnBlablalink.OnEvent("Click", (*) => Run("https://www.blablalink.com/"))
; CDK兑换
btnCDK := doroGui.Add("Button", "x+10 w80 h30", "CDK兑换")
doroGui.Tips.SetTip(btnCDK, "Nikke CDK Exchange")
btnCDK.OnEvent("Click", (*) => Run("https://nikke.hayasa.link/"))
; 反馈qq群
btnFeedbackQQ := doroGui.Add("Button", "x+10 w50 h30", "qq群")
doroGui.Tips.SetTip(btnFeedbackQQ, "Join the feedback group")
btnFeedbackQQ.OnEvent("Click", (*) => Run("https://qm.qq.com/q/ZhvLeKMO2q"))
; 反馈 dc群
btnFeedbackDC := doroGui.Add("Button", "x+10 w70 h30", "Discord")
doroGui.Tips.SetTip(btnFeedbackDC, "Join the feedback group")
btnFeedbackDC.OnEvent("Click", (*) => Run("https://discord.gg/f4rAWJVNJj"))
; 剧情模式
TextStoryModeLabel := doroGui.Add("Text", "xp R1 xs+10 +0x0100", "剧情模式")
doroGui.Tips.SetTip(TextStoryModeLabel, "自动点击对话选项，自动进行下一段剧情，自动启动auto`nAutomatically click dialogue options, automatically proceed to the next segment of the story, automatically start auto")
cbStoryModeAutoStar := AddCheckboxSetting(doroGui, "StoryModeAutoStar", "自动收藏", "x+5  R1")
doroGui.Tips.SetTip(cbStoryModeAutoStar, "Automatically bookmark the current story")
cbStoryModeAutoChoose := AddCheckboxSetting(doroGui, "StoryModeAutoChoose", "自动抉择", "x+5 R1")
doroGui.Tips.SetTip(cbStoryModeAutoChoose, "Automatically choose the first option in choices")
BtnStoryMode := doroGui.Add("Button", " x+5 yp-3 w25 h25", "▶️").OnEvent("Click", StoryMode)
TextTestModeLabel := doroGui.Add("Text", "xp R1 xs+10 +0x0100", "调试模式")
doroGui.Tips.SetTip(TextTestModeLabel, "根据输入的函数直接执行对应任务`nTestMode:Directly execute the corresponding task according to the input function")
TestModeEditControl := doroGui.Add("Edit", "x+10 yp w145 h20")
TestModeEditControl.Value := g_numeric_settings["TestModeValue"]
cbTestModeInitialization := AddCheckboxSetting(doroGui, "TestModeInitialization", "预初始化", "x+5  R1")
doroGui.Tips.SetTip(cbTestModeInitialization, "Initialize before executing tasks")
BtnTestMode := doroGui.Add("Button", " x+5 yp-3 w25 h25", "▶️").OnEvent("Click", TestMode)
TextQuickBurst := doroGui.Add("Text", "xp R1 xs+10 +0x0100", "快速爆裂模式")
doroGui.Tips.SetTip(TextQuickBurst, "启动后，会自动使用爆裂，速度比自带的自动快`n默认先A后S`nAfter starting, Burst will be used automatically, Fater than the built-in auto.`nBy default, A is used before S")
BtnQuickBurst := doroGui.Add("Button", " x+5 yp-3 w25 h25", "▶️").OnEvent("Click", QuickBurst)
TextAutoAdvance := doroGui.Add("Text", "xp R1 xs+10 +0x0100", "推图模式beta[金Doro]")
doroGui.Tips.SetTip(TextAutoAdvance, "半自动推图。视野调到最大。在地图中靠近怪的地方启动，有时需要手动找怪和找机关`nMap Advancement:Semi-automatic map advancement. Set the view to the maximum. Start near the monster in the map, sometimes you need to manually find monsters and mechanisms")
BtnAutoAdvance := doroGui.Add("Button", " x+5 yp-3 w25 h25", "▶️").OnEvent("Click", AutoAdvance)
BtnBluePill := AddCheckboxSetting(doroGui, "BluePill", "蓝色药丸", "xp R1 xs+10 +0x0100")
doroGui.Tips.SetTip(BtnBluePill, "Blue Pill")
BtnRedPill := AddCheckboxSetting(doroGui, "RedPill", "红色药丸", "x+10 R1 +0x0100")
doroGui.Tips.SetTip(BtnRedPill, "Red Pill")
TextPillinfo := doroGui.Add("Text", "x+10 +0x0100", "←特定情况下勾选")
doroGui.Tips.SetTip(TextPillinfo, "Check the box in specific circumstances")
;tag 日志
doroGui.AddGroupBox("x600 y260 w400 h390 Section", "日志")
btnCopyLog := doroGui.Add("Button", "xp+320 yp-5 w80 h30", "导出日志")
doroGui.Tips.SetTip(btnCopyLog, "Export log")
btnCopyLog.OnEvent("Click", CopyLog)
doroGui.SetFont('s10')
LogBox := RichEdit(doroGui, "xs+10 ys+30 w380 h340 -HScroll +0x80 ReadOnly")
LogBox.WordWrap(true)
HideAllSettings()
ShowSetting("Default")
doroGui.OnEvent("Close", (*) => ExitApp())
doroGui.Show("x" g_numeric_settings["doroGuiX"] " y" g_numeric_settings["doroGuiY"])
;endregion 创建GUI
;tag 彩蛋
CheckSequence(key_char) {
    global key_history, konami_code, g_numeric_settings ; 移除 UserLevel，添加 g_numeric_settings
    ; 将当前按键对应的字符追加到历史记录中
    key_history .= key_char
    ; 为了防止历史记录字符串无限变长，我们只保留和目标代码一样长的末尾部分
    if (StrLen(key_history) > StrLen(konami_code)) {
        key_history := SubStr(key_history, -StrLen(konami_code) + 1)
    }
    ; 检查当前的历史记录是否与目标代码完全匹配
    if (key_history == konami_code) {
        AddLog("🎉 彩蛋触发！ 🎉！Konami Code 已输入！", "Blue")
        VariableUserGroup.Value := "炫彩Doro"
        key_history := ""    ; 重置历史记录，以便可以再次触发
        g_numeric_settings["UserLevel"] := 0 ; 直接修改 Map 中的值
    }
}
try {
    #HotIf WinActive(title)
    ~Up:: CheckSequence("U")
    ~Down:: CheckSequence("D")
    ~Left:: CheckSequence("L")
    ~Right:: CheckSequence("R")
    ~b:: CheckSequence("B")
    ~a:: CheckSequence("A")
    #HotIf
}
;region 前置任务
;tag 语言提示
if !(LocaleName = "zh-CN") {
    AddLog("Hover your mouse over to view the English translatio, except for the content of the log")
    AddLog("For our international users,this will be a much faster and better way to get support. Here's the invite link:https://discord.gg/WtSxX6q6")
}
;tag 检查用户组
if g_settings["AutoCheckUserGroup"]
    CheckUserGroup(true)
;tag 广告
; 如果满足以下任一条件，则显示广告：
; 1. 未勾选关闭广告 (无论用户是谁)
; 2. 是普通用户 (无论是否勾选了关闭广告，因为普通用户无法关闭)
if (!g_settings["CloseAdvertisement"] OR g_numeric_settings["UserLevel"] < 1) {
    ; 额外判断，如果用户是普通用户且勾选了关闭广告，则弹窗提示
    if (g_settings["CloseAdvertisement"] and g_numeric_settings["UserLevel"] < 1) {
        MsgBox("普通用户无法关闭广告，请点击赞助按钮升级会员组")
    }
    Advertisement
}
if !g_settings["CloseHelp"] {
    ClickOnHelp
}
;tag 删除旧文件
if g_settings["AutoDeleteOldFile"]
    DeleteOldFile
;tag 检查更新
if g_settings["AutoCheckUpdate"]
    CheckForUpdate(false)
;tag 定时启动
if g_settings["Timedstart"] {
    if g_numeric_settings["UserLevel"] >= 3 {
        if !g_numeric_settings["StartupTime"] {
            MsgBox("请设置定时启动时间")
            Pause
        }
        StartDailyTimer()
        return
    } else {
        MsgBox("当前用户组不支持定时启动，请点击左上角赞助按钮升级会员组或取消勾选该功能，脚本即将暂停")
        Pause
    }
}
;endregion 前置任务
;tag 点击运行
ClickOnDoro(*) {
    ;清空文本
    LogBox.Value := ""
    ;写入设置
    WriteSettings()
    ;设置窗口标题匹配模式为完全匹配
    SetTitleMatchMode 3
    if g_settings["Login"] {
        if g_settings["AutoStartNikke"] {
            if g_numeric_settings["UserLevel"] >= 3 {
                AutoStartNikke()
            }
            else {
                MsgBox("当前用户组不支持定时启动，请点击左上角赞助按钮升级会员组或取消勾选该功能，脚本即将暂停")
                Pause
            }
        }
    }
    Initialization
    if !g_settings["AutoCheckUserGroup"]
        CheckUserGroup(true)
    if g_settings["Login"]
        Login()
    if g_settings["AutoSwitchLanguage"]
        AutoSwitchLanguage()
    if g_settings["Shop"] {
        if g_settings["ShopCashFree"]
            ShopCash()
        if g_settings["ShopGeneral"] or g_settings["ShopArena"] or g_settings["ShopRecycling"] {
            Shop()
        }
        if g_settings["ShopGeneral"]
            ShopGeneral()
        if g_settings["ShopArena"]
            ShopArena()
        if g_settings["ShopRecycling"]
            ShopRecycling()
        BackToHall
    }
    if g_settings["SimulationRoom"] {
        if g_settings["SimulationNormal"]
            SimulationNormal()
        if g_settings["SimulationOverClock"]
            SimulationOverClock()
        GoBack
    }
    if g_settings["Arena"] {
        if g_settings["AwardArena"]
            AwardArena()
        if g_settings["ArenaRookie"] or g_settings["ArenaSpecial"] or g_settings["ArenaChampion"] {
            EnterToArk()
            EnterToArena()
            if g_settings["ArenaRookie"]
                ArenaRookie()
            if g_settings["ArenaSpecial"]
                ArenaSpecial()
            if g_settings["ArenaChampion"]
                ArenaChampion()
            GoBack
        }
    }
    if g_settings["Tower"] {
        if g_settings["TowerCompany"]
            TowerCompany()
        if g_settings["TowerUniversal"]
            TowerUniversal()
        GoBack
    }
    if g_settings["Interception"] {
        if g_settings["InterceptionNormal"]
            InterceptionNormal()
        if g_settings["InterceptionAnomaly"]
            InterceptionAnomaly()
    }
    BackToHall
    if g_settings["Award"] {
        if g_settings["AwardOutpost"]
            AwardOutpost()
        if g_settings["AwardAdvise"]
            AwardAdvise()
        if g_settings["AwardFriendPoint"]
            AwardFriendPoint()
        if g_settings["AwardMail"]
            AwardMail()
        if g_settings["AwardRanking"]
            AwardRanking()
        if g_settings["AwardDaily"]
            AwardDaily()
        if g_settings["AwardPass"]
            AwardPass()
        if g_settings["AwardFreeRecruit"]
            AwardFreeRecruit()
        if g_settings["AwardCooperate"]
            AwardCooperate()
        if g_settings["AwardSoloRaid"]
            AwardSoloRaid()
    }
    if g_settings["Event"] {
        if g_numeric_settings["UserLevel"] < 2 {
            MsgBox("当前用户组不支持活动，请点击赞助按钮升级会员组")
            Pause
        }
        if g_settings["EventSmall"] {
            EventSmall()
            if g_settings["EventSmallChallenge"] {
                EventSmallChallenge()
            }
            if g_settings["EventSmallStory"] {
                EventSmallStory()
            }
            if g_settings["EventSmallMission"] {
                EventSmallMission()
            }
            BackToHall
        }
        if g_settings["EventLarge"] {
            EventLarge()
            if g_settings["EventLargeSign"] {
                EventLargeSign()
            }
            if g_settings["EventLargeChallenge"] {
                EventLargeChallenge()
            }
            if g_settings["EventLargeStory"] {
                EventLargeStory()
            }
            if g_settings["EventLargeCooperate"] {
                EventLargeCooperate()
            }
            if g_settings["EventLargeMinigame"] {
                EventLargeMinigame()
            }
            if g_settings["EventLargeDaily"] {
                EventLargeDaily()
            }
            BackToHall
            if g_settings["AwardPass"] {
                AwardPass()
            }
        }
        if g_settings["EventSpecial"] {
            EventSpecial()
        }
    }
    if g_settings["ClearRed"] {
        if g_numeric_settings["UserLevel"] < 3 {
            MsgBox("当前用户组不支持清除红点，请点击赞助按钮升级会员组")
            Pause
        }
        if g_settings["ClearRedRecycling"] {
            ClearRedRecycling()
        }
        if g_settings["ClearRedSynchro"] {
            ClearRedSynchro()
        }
        if g_settings["ClearRedLimit"] {
            ClearRedLimit()
        }
        if g_settings["ClearRedCube"] {
            ClearRedCube()
        }
        if g_settings["ClearRedNotice"] {
            ClearRedNotice()
        }
        if g_settings["ClearRedWallpaper"] {
            ClearRedWallpaper()
        }
        if g_settings["ClearRedProfile"] {
            ClearRedProfile()
        }
        if g_settings["ClearRedBla"] {
            ClearRedBla()
        }
        BackToHall
    }
    if g_settings["AutoSwitchLanguage"]
        AutoSwitchLanguage()
    if g_settings["LoopMode"] {
        WinClose winID
        SaveAndRestart
    }
    if g_settings["CheckEvent"] {
        CheckEvent()
    }
    CalculateAndShowSpan()
    finalMessageTitle := "DoroHelper任务完成！"
    finalMessageText := "Doro完成任务！" . outputText
    if g_numeric_settings["UserLevel"] < 1 or !g_settings["CloseAdvertisement"] {
        finalMessageText .= "`n可以支持一下Doro吗"
        Result := MsgBox(finalMessageText, finalMessageTitle, "YesNo IconI")
        if Result = "Yes"
            MsgSponsor
    }
    else if g_numeric_settings["UserLevel"] < 10 {
        ; 普通会员
        finalMessageText .= "`n感谢你的支持～"
        MsgBox(finalMessageText, finalMessageTitle, "IconI")
    }
    else {
        ; 管理员
        finalMessageText .= "`n感谢你的辛苦付出～"
        MsgBox(finalMessageText, finalMessageTitle, "IconI")
    }
    if g_settings["OpenBlablalink"]
        Run("https://www.blablalink.com/")
    if g_settings["DoroClosing"] {
        if InStr(currentVersion, "beta") {
            MsgBox ("测试版本禁用自动关闭！", "DoroHelper提示", "IconW")
            Pause
        }
        ExitApp
    }
}
;region 启动辅助函数
;tag 脚本启动NIKKE
AutoStartNikke() {
    global NikkeX
    global NikkeY
    global NikkeW
    global NikkeH
    targetExe := "nikke.exe"
    if WinExist("ahk_exe " . targetExe) {
        AddLog("NIKKE已经在运行中，跳过启动")
        return
    }
    while g_numeric_settings["StartupPath"] != "" {
        SetTitleMatchMode 2
        targetExe := "nikke_launcher.exe"
        gameExe := "nikke.exe"
        ; 尝试找到标题包含"NIKKE"的主窗口
        mainWindowID := WinExist("NIKKE ahk_exe " . targetExe)
        if mainWindowID {
            AddLog("找到了NIKKE主窗口！ID: " mainWindowID)
            actualWinTitle := WinGetTitle(mainWindowID)
            AddLog("实际窗口标题是: " actualWinTitle)
            ; 激活该窗口
            WinActivate(mainWindowID)
            WinGetClientPos &NikkeX, &NikkeY, &NikkeW, &NikkeH, mainWindowID
            TrueRatio := NikkeH / stdScreenH
            ; 设置超时时间（例如2分钟）
            startTime := A_TickCount
            timeout := 120000
            ; 循环点击直到游戏启动或超时
            while (A_TickCount - startTime < timeout) {
                ; 检查游戏是否已经启动
                if ProcessExist(gameExe) {
                    AddLog("检测到游戏进程 " gameExe " 已启动，停止点击")
                    Sleep 10000
                    break 2
                }
                ; 执行点击启动按钮
                AddLog("点击启动按钮……")
                UserClick(594, 1924, TrueRatio)
                ; 等待一段时间再次点击（例如3-5秒）
                Sleep 3000
            }
            ; 检查是否超时
            if (A_TickCount - startTime >= timeout) {
                AddLog("启动超时，未能检测到游戏进程", "Red")
            }
            break
        }
        else if WinExist("ahk_exe " . targetExe) {
            AddLog("启动器已运行但未找到主窗口，等待主窗口出现……")
            ; 等待主窗口出现
            startTime := A_TickCount
            timeout := 30000
            while (A_TickCount - startTime < timeout) {
                if WinExist("NIKKE ahk_exe " . targetExe) {
                    AddLog("主窗口出现，重新检测")
                    break
                }
                Sleep 1000
            }
            if (A_TickCount - startTime >= timeout) {
                AddLog("等待主窗口超时，尝试重新启动启动器")
                Run(g_numeric_settings["StartupPath"])
                sleep 5000
            }
        }
        else {
            AddLog("正在启动NIKKE启动器，请稍等……")
            Run(g_numeric_settings["StartupPath"])
            sleep 5000
        }
    }
}
;tag 初始化
Initialization() {
    global NikkeX, NikkeY, NikkeW, NikkeH
    LogBox.SetText()
    targetExe := "nikke.exe"
    if WinExist("ahk_exe " . targetExe) {
        global winID := WinExist("ahk_exe " . targetExe)
        actualWinTitle := WinGetTitle(winID)
        if WinGetCount("ahk_exe " . targetExe) > 1 {
            MsgBox("金Doro会员支持多开自动运行")
        }
        AddLog("找到了进程为 '" . targetExe . "' 的窗口！实际窗口标题是: " . actualWinTitle)
        if actualWinTitle = "胜利女神：新的希望" {
            MsgBox ("不支持国服，自动关闭！")
            MsgBox ("为了各自生活的便利，请不要在公开场合发布本软件国服相关的修改版本，谢谢配合！")
            ExitApp
        }
        ;激活该窗口
        WinActivate(winID)
    }
    else {
        ;没有找到该进程的窗口
        MsgBox("没有找到进程为 '" . targetExe . "' 的窗口，初始化失败！")
        Pause
    }
    nikkeID := winID
    WinGetClientPos &NikkeX, &NikkeY, &NikkeW, &NikkeH, nikkeID
    WinGetPos &NikkeXP, &NikkeYP, &NikkeWP, &NikkeHP, nikkeID
    global TrueRatio := NikkeH / stdScreenH
    GameRatio := Round(NikkeW / NikkeH, 3)
    AddLog("项目地址https://github.com/1204244136/DoroHelper")
    AddLog("当前的doro版本是" currentVersion)
    AddLog("屏幕宽度是" A_ScreenWidth)
    AddLog("屏幕高度是" A_ScreenHeight)
    AddLog("游戏画面比例是" GameRatio)
    AddLog("图片缩放系数是" Round(TrueRatio, 3))
    if GameRatio = 1.779 or GameRatio = 1.778 or GameRatio = 1.777 {
        AddLog("游戏是标准的16：9尺寸", "Green")
    }
    else MsgBox("请在nikke设置中将画面比例调整为16:9")
    ; 尝试归类为2160p (4K) 及其变种
    if (A_ScreenWidth >= 3840 and A_ScreenHeight >= 2160) {
        if (A_ScreenWidth = 3840 and A_ScreenHeight = 2160) {
            AddLog("显示器是标准4K分辨率 (2160p)")
        } else if (A_ScreenWidth = 5120 and A_ScreenHeight = 2160) {
            AddLog("显示器是4K 加宽 (21:9 超宽屏)")
        } else if (A_ScreenWidth = 3840 and A_ScreenHeight = 2400) {
            AddLog("显示器是4K 增高 (16:10 宽屏)")
        } else {
            AddLog("显示器是4K 及其它变种分辨率")
        }
    }
    ; 尝试归类为1440p (2K) 及其变种
    else if (A_ScreenWidth >= 2560 and A_ScreenHeight >= 1440) {
        if (A_ScreenWidth = 2560 and A_ScreenHeight = 1440) {
            AddLog("显示器是标准2K分辨率 (1440p)")
        } else if (A_ScreenWidth = 3440 and A_ScreenHeight = 1440) {
            AddLog("显示器是2K 加宽 (21:9 超宽屏)")
        } else if (A_ScreenWidth = 5120 and A_ScreenHeight = 1440) {
            AddLog("显示器是2K 超宽 (32:9 超级带鱼屏)")
        } else if (A_ScreenWidth = 2560 and A_ScreenHeight = 1600) {
            AddLog("显示器是2K 增高 (16:10 宽屏)")
        } else {
            AddLog("显示器是2K 及其它变种分辨率")
        }
    }
    ; 尝试归类为1080p 及其变种
    else if (A_ScreenWidth >= 1920 and A_ScreenHeight >= 1080) {
        if (A_ScreenWidth = 1920 and A_ScreenHeight = 1080) {
            AddLog("显示器是标准1080p分辨率")
            if NikkeW < 1920 and NikkeH < 1080 {
                MsgBox("NIKKE尺寸过小，请尝试全屏运行")
            }
        } else if (A_ScreenWidth = 2560 and A_ScreenHeight = 1080) {
            AddLog("显示器是1080p 加宽 (21:9 超宽屏)")
        } else if (A_ScreenWidth = 3840 and A_ScreenHeight = 1080) {
            AddLog("显示器是1080p 超宽 (32:9 超级带鱼屏)")
        } else if (A_ScreenWidth = 1920 and A_ScreenHeight = 1200) {
            AddLog("显示器是1080p 增高 (16:10 宽屏)")
        } else {
            AddLog("显示器是1080p 及其它变种分辨率")
        }
    }
    else {
        AddLog("显示器不足1080p分辨率")
    }
    if TrueRatio < 0.5 {
        Result := MsgBox("检测到NIKKE窗口尺寸过小，建议按ctrl+3调整游戏画面并重启脚本，是否暂停程序？", , "YesNo")
        if Result = "Yes"
            Pause
    }
}
;tag 定时启动
StartDailyTimer() {
    ; 1. 获取目标时间字符串，例如 "080000"
    target_time_string := g_numeric_settings["StartupTime"]
    ; 2. 创建一个表示今天目标时间的时间戳，例如 "20250806080000"
    today_target_time := A_YYYY . A_MM . A_DD . target_time_string
    ; 声明 next_run_time 为局部变量，并初始化，避免“未赋值”错误
    local next_run_time := ""
    ; 3. 比较当前时间 A_Now 和今天目标时间
    if (A_Now > today_target_time) {
        ; 如果当前时间已过，则将目标设置为明天的同一时间
        ; 首先，使用 DateAdd 获取 24 小时后的时间戳
        tomorrow_timestamp := DateAdd(A_Now, 1, "d")
        ; 然后，提取出明天的日期部分 (YYYYMMDD)
        tomorrow_date_part := SubStr(tomorrow_timestamp, 1, 8)
        ; 最后，将明天的日期和目标时间拼接起来
        next_run_time := tomorrow_date_part . target_time_string
    } else {
        ; 如果当前时间未到，则设置定时器到今天
        next_run_time := today_target_time
    }
    ; 4.使用 DateDiff() 精确计算距离下一次执行还有多少秒
    seconds_until_next_run := DateDiff(next_run_time, A_Now, "Seconds")
    ; 5. 将秒转换为毫秒
    milliseconds := seconds_until_next_run * 1000
    ; 计算小时、分钟和秒
    hours_until := seconds_until_next_run // 3600
    minutes_until := Mod(seconds_until_next_run, 3600) // 60
    seconds_until := Mod(seconds_until_next_run, 60)
    ; 6. 格式化日志输出，方便阅读和调试
    AddLog("定时器已设置。下一次执行时间："
        . SubStr(next_run_time, 1, 4) . "-"
        . SubStr(next_run_time, 5, 2) . "-"
        . SubStr(next_run_time, 7, 2) . " "
        . SubStr(next_run_time, 9, 2) . ":"
        . SubStr(next_run_time, 11, 2) . ":"
        . SubStr(next_run_time, 13, 2)
        . " (在 " . hours_until . " 小时 " . minutes_until . " 分 " . seconds_until . " 秒后)")
    ; 7. 使用负值来设置一个只执行一次的定时器
    SetTimer(ClickOnDoro, -milliseconds)
}
;endregion 启动辅助函数
;region 更新辅助函数
;tag 统一检查更新
CheckForUpdate(isManualCheck) {
    global currentVersion, usr, repo, latestObj, g_settings, g_numeric_settings, scriptExtension
    ; 重置 latestObj 以确保每次检查都是新的状态
    if (!IsObject(latestObj) || Type(latestObj) != "Map") {
        AddLog("警告: latestObj 未初始化或类型错误，重新初始化。", "Red")
        latestObj := Map("version", "", "change_notes", "无更新说明", "download_url", "", "source", "", "display_name", "")
    } else {
        ; 重置 latestObj 以确保每次检查都是新的状态
        ; 此处不直接重建Map，而是清空内容，以避免垃圾回收开销和可能的引用问题。
        for k, v in latestObj {
            latestObj.Delete(k)
        }
    }
    checkSucceeded := false
    channelInfo := (g_numeric_settings.Get("UpdateChannels") == "测试版") ? "测试版" : "正式版"
    ; 新增变量以追踪A_ScriptFullPath和lib库是否需要重启
    ahkScriptNeedsReload := false
    libResourcesNeedsReload := false
    ; ==================== AHK 文件更新检查 (脚本本体更新) =====================
    if (scriptExtension = "ahk") {
        AddLog("开始检查 DoroHelper.ahk 本体更新……")
        ahkResult := CheckForUpdate_AHK_File(isManualCheck)
        if (ahkResult.Get("success", false)) {
            AddLog("DoroHelper.ahk 本体更新检查成功: " . ahkResult.Get("message", "本地版本已是最新或已修改。"), "Green")
            if (ahkResult.Get("needsReload", false)) {
                ahkScriptNeedsReload := true
            }
        } else {
            AddLog("DoroHelper.ahk 本体更新检查失败或被跳过: " . ahkResult.Get("message", "未知错误"), "Red")
        }
        AddLog("开始检查函数库文件更新 (资源更新)……")
        resourceUpdateResult := CheckForResourceUpdate(isManualCheck)
        if (resourceUpdateResult.Get("success", false)) {
            AddLog("函数库文件更新检查完成。")
            if (resourceUpdateResult.Get("updatedCount", 0) > 0) {
                AddLog("已更新 " . resourceUpdateResult.Get("updatedCount") . " 个函数库文件。", "Green")
                libResourcesNeedsReload := true
            } else {
                AddLog("所有函数库文件更新检查成功: 本地版本已是最新或已修改，无需下载。", "Green")
                if (isManualCheck) {
                    MsgBox("所有函数库文件均已是最新版本。", "资源更新", "IconI")
                }
            }
        } else {
            AddLog("函数库文件更新检查失败: " . resourceUpdateResult.Get("message", "未知错误"), "Red")
            if (isManualCheck) {
                MsgBox("函数库文件更新检查失败: " . resourceUpdateResult.Get("message", "未知错误"), "资源更新错误", "IconX")
            }
        }
        ; 如果任何部分需要重启，则执行一次重启
        if (ahkScriptNeedsReload || libResourcesNeedsReload) {
            AddLog("检测到 AHK 脚本本体或函数库文件已更新，DoroHelper 将重启。")
            if (isManualCheck) {
                MsgBox("检测到 DoroHelper.ahk 本体或函数库文件已更新，脚本将重启以加载新版本。", "更新完成，即将重启", "IconI")
            }
            Reload()
        } else if (isManualCheck) {
            MsgBox("当前已是最新版本，无需更新。", "AHK更新提示", "IconI")
        }
        return
    }
    ; ==================== EXE 版本更新检查（Mirror酱 或 Github） ====================
    ; 确定更新来源是 Mirror酱 还是 Github (只针对 EXE 版本)
    latestObj.Set("version", "")
    latestObj.Set("change_notes", "无更新说明")
    latestObj.Set("download_url", "")
    latestObj.Set("foundNewVersion", false)
    if (g_numeric_settings.Get("DownloadSource") == "Mirror酱") {
        latestObj.Set("source", "mirror")
        latestObj.Set("display_name", "Mirror酱")
        checkSucceeded := CheckForUpdate_Mirror(isManualCheck, channelInfo, &latestObj)
    } else {
        latestObj.Set("source", "github")
        latestObj.Set("display_name", "Github")
        checkSucceeded := CheckForUpdate_Github(isManualCheck, channelInfo, &latestObj)
    }
    ; ==================== 处理最终检查结果 (适用于 EXE 版本) ====================
    if (checkSucceeded && latestObj.Get("foundNewVersion", false)) {
        ; 直接使用 latestObj，因为它已通过引用被填充
        AddLog(latestObj.Get("display_name") . " 更新检查：发现新版本 " . latestObj.Get("version") . "，准备提示用户", "Green")
        downloadUrl := latestObj.Get("download_url", "")
        if (downloadUrl == "" && isManualCheck) {
            MsgBox("已检测到新版本 " . latestObj.Get("version") . "，但未能获取到下载链接。请检查 " . latestObj.Get("display_name") . " 库或手动下载", "更新提示", "IconWarning")
        }
        DisplayUpdateNotification()
    } else if (checkSucceeded && latestObj.Get("version", "") != "") {
        AddLog(latestObj.Get("display_name") . " 更新检查：当前已是最新版本 " . currentVersion, "Green")
        if (isManualCheck) {
            MsgBox("当前通道为:" . channelInfo . "通道 - " . latestObj.Get("display_name") . "`n最新版本为:" . latestObj.Get("version") "`n当前版本为:" . currentVersion "`n当前已是最新版本", "检查更新", "IconI")
        }
    } else {
        ; 如果 checkSucceeded 为 false，表示发生错误，或者即使成功但版本为空（现在不太可能）
        displayMessage := latestObj.Get("message", "")
        if (displayMessage == "") {
            displayMessage := (latestObj.Get("display_name") ? latestObj.Get("display_name") : "更新") . " 更新检查：未能获取到有效的版本信息或检查被中止"
        }
        AddLog(displayMessage, "Red")
        if (isManualCheck) {
            MsgBox(displayMessage, "检查更新", "IconX")
        }
    }
}
;tag AHK文件更新检查子函数
CheckForUpdate_AHK_File(isManualCheck) {
    global currentVersion, usr, repo, scriptExtension
    result := Map("success", false, "message", "未知错误", "needsReload", false)
    if (scriptExtension = "exe") {
        result.Set("message", "exe版本不可直接更新至ahk版本，请查看群公告下载完整的ahk版本文件")
        if (isManualCheck) {
            MsgBox result.Get("message")
        }
        return result
    }
    path := "DoroHelper.ahk"
    remoteSha := ""
    remoteLastModified := ""
    localScriptPath := A_ScriptDir "\DoroHelper.ahk"
    localSha := ""
    localLastModified := ""
    localLastModifiedUTC := ""
    shouldDownload := false
    ; --- 1. 获取远程文件信息 ---
    try {
        AddLog("正在从 GitHub API 获取最新版本文件哈希值及修改时间……")
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        apiUrl := "https://api.github.com/repos/" . usr . "/" . repo . "/contents/" . path
        whr.Open("GET", apiUrl, false)
        whr.SetRequestHeader("User-Agent", "DoroHelper-AHK-Script")
        whr.Send()
        if (whr.Status != 200) {
            throw Error("API请求失败", -1, "状态码: " . whr.Status)
        }
        try {
            lastModifiedHeader := whr.GetResponseHeader("Last-Modified")
            if (lastModifiedHeader != "") {
                parsedTime := ParseDateTimeString(lastModifiedHeader)
                if (parsedTime != "") {
                    remoteLastModified := parsedTime
                } else {
                    AddLog("警告: 无法解析 Last-Modified HTTP头时间: " . lastModifiedHeader, "MAROON")
                }
            } else {
                AddLog("警告: 未在HTTP头中找到 Last-Modified。")
            }
        } catch as e_header {
            AddLog("警告: 获取 Last-Modified HTTP头失败: " . e_header.Message)
        }
        responseText := whr.ResponseText
        shaMatch := ""
        if (RegExMatch(responseText, '"sha"\s*:\s*"(.*?)"', &shaMatch)) {
            remoteSha := shaMatch[1]
        } else {
            throw Error("JSON解析失败", -1, "未能从API响应中找到'sha'字段。")
        }
        if (remoteLastModified = "") {
            commitDateMatch := ""
            if (RegExMatch(responseText, '"commit":\s*\{.*?\"author\":\s*\{.*?\"date\":\s*\"(.*?)\"', &commitDateMatch)) {
                commitDateStr := commitDateMatch[1]
                parsedCommitTime := ParseDateTimeString(commitDateStr)
                if (parsedCommitTime != "") {
                    remoteLastModified := parsedCommitTime
                } else {
                    AddLog("警告: 无法解析JSON commit日期: " . commitDateStr)
                }
            } else {
                AddLog("警告: 未能从GitHub API响应的JSON commit信息中找到日期。")
            }
        }
    } catch as e {
        AddLog("获取远程文件信息失败，错误信息: " . e.Message, "Red")
        result.Set("message", "无法检查更新，请检查网络或稍后再试。")
        return result
    }
    if (remoteSha == "") {
        AddLog("无法获取远程文件哈希值，更新中止。", "Red")
        result.Set("message", "无法获取远程文件信息，无法检查更新。")
        return result
    }
    ; --- 2. 获取本地文件信息并转换为UTC ---
    try {
        if !FileExist(localScriptPath) {
            localSha := ""
            localLastModified := "0"
            localLastModifiedUTC := "0"
        } else {
            localSha := HashGitSHA1(localScriptPath)
            localLastModified := FileGetTime(localScriptPath, "M")
            ; 将本地时间转换为UTC时间进行比较
            ; A_TimeZone 是本地时间与UTC时间的分钟差。
            ; UTC = 本地时间 + A_TimeZone。例如，如果本地时区是 GMT+8，A_TimeZone 是 -480 分钟。
            ; 所以 localLastModifiedUTC = DateAdd(localLastModified, A_TimeZone, "minutes")
            A_TimeZone := DateDiff(A_NowUTC, A_Now, "Minutes")
            localLastModifiedUTC := DateAdd(localLastModified, A_TimeZone, "minutes")
        }
    } catch as e {
        AddLog("计算本地文件哈希、获取修改时间或转换时区失败，错误信息: " . e.Message, "Red")
        result.Set("message", "计算本地文件哈希或获取修改时间时出错，无法检查更新。")
        return result
    }
    AddLog("远程文件哈希值: " remoteSha)
    AddLog("本地文件哈希值: " localSha)
    ; 修改日志和MsgBox说明，以清晰指出是以UTC时间进行比较
    AddLog("远程文件修改时间 (UTC): " (remoteLastModified != "" ? remoteLastModified : "未获取到"))
    AddLog("本地文件修改时间 (UTC): " localLastModifiedUTC)
    ; --- 3. 比较并决定是否更新 ---
    ; 情况 1: 哈希一致 -> 已是最新版本
    if (remoteSha = localSha) {
        AddLog("文件哈希一致，当前已是最新版本。", "Green")
        ; 不再弹出MsgBox，统一由CheckForUpdate处理
        result.Set("success", true)
        result.Set("message", "AHK脚本已是最新版本。")
        return result
    }
    ; 情况 2: 哈希不一致 -> 可能有更新，需要进一步判断
    else {
        ; 确保 remoteLastModified 和 localLastModifiedUTC 都已有效获取
        if (remoteLastModified != "" && localLastModifiedUTC != "0") {
            if (remoteLastModified > localLastModifiedUTC) {
                ; 远程文件的时间戳更新，这是正常的更新情况
                AddLog("检测到远程 AHK 文件版本 (" . remoteSha . ") 较新，本地版本 (" . localSha . ") 较旧。", "BLUE")
                shouldDownload := true
            } else {
                ; 哈希不一致，但本地文件的时间戳更近或相同 (在UTC下)。
                ; 这通常意味着本地文件被修改过，或者远程的时间戳有问题。
                AddLog("警告: 检测到 AHK 脚本哈希不匹配，但本地文件修改时间 (UTC: " . localLastModifiedUTC . ") 晚于或等于远程 (UTC: " . remoteLastModified . ")。", "Red")
                if (isManualCheck) {
                    userChoice := MsgBox("检测到 AHK 脚本哈希不匹配，但本地文件修改时间 (UTC) 晚于或等于线上版本。这可能意味着您本地做过更改，或者线上有新更新但时间戳较老`n`n远程哈希 (截短): " . SubStr(remoteSha, 1, 7)
                    . "`n本地哈希 (截短): " . SubStr(localSha, 1, 7)
                    . "`n远程修改时间 (UTC): " . remoteLastModified
                    . "`n本地修改时间 (UTC): " . localLastModifiedUTC
                    . "`n`n是否强制更新本地脚本为线上版本？(建议在备份后操作)", "AHK强制更新提示", "YesNo")
                    if (userChoice == "Yes") {
                        AddLog("用户选择强制更新 AHK 脚本。", "Red")
                        shouldDownload := true
                    } else {
                        AddLog("用户取消强制更新 AHK 脚本。", "Blue")
                        result.Set("success", true)
                        result.Set("message", "用户选择不强制更新 AHK 脚本。")
                        return result
                    }
                } else {
                    AddLog("自动检查中检测到 AHK 文件哈希不匹配但本地修改时间问题，跳过自动更新。", "Red")
                    result.Set("success", false)
                    result.Set("message", "自动检查中 AHK 脚本哈希不匹配且本地修改时间晚于或等于远程 (UTC)，跳过。")
                    return result
                }
            }
        } else {
            ; 无法可靠获取一个或两个修改时间。由于哈希不一致，假定需要更新。
            AddLog("警告: 无法获取完整的修改时间信息，但检测到 AHK 文件哈希不匹配。准备下载新版本。", "Red")
            shouldDownload := true
        }
    }
    ; --- 4. 执行下载和替换（如果 `shouldDownload` 旗帜为真）---
    if (shouldDownload) {
        AddLog("准备下载 AHK 脚本新版本。", "Green")
        url := "https://raw.githubusercontent.com/" . usr . "/" . repo . "/main/" . path
        currentScriptDir := A_ScriptDir
        NewFileName := "DoroHelper_new_" . A_Now . ".ahk"
        localNewFilePath := currentScriptDir . "\" . NewFileName
        try {
            AddLog("正在下载最新 AHK 版本，请稍等……")
            Download(url, localNewFilePath)
            AddLog("文件下载成功！已保存到: " . localNewFilePath, "Green")
        } catch as e {
            MsgBox "下载失败，错误信息: " . e.Message, "错误", "IconX"
            result.Set("message", "下载失败: " . e.Message)
            return result
        }
        ; 不再此处立即重启，而是设置 needsReload 标志
        OldFileName := "DoroHelper_old_" . A_Now . ".ahk"
        try {
            FileMove A_ScriptFullPath, A_ScriptDir . "\" . OldFileName, 1
            FileMove localNewFilePath, A_ScriptDir . "\DoroHelper.ahk"
            AddLog("AHK 脚本更新成功。旧版本已备份为 '" . OldFileName . "'。", "Green")
            result.Set("needsReload", true)
        } catch as e {
            MsgBox "更新后的文件重命名失败: " . e.Message . "`n请手动将下载的 '" . NewFileName . "' 文件重命名为 'DoroHelper.ahk' 并替换现有文件。", "错误", "IconX"
            AddLog("更新后的文件重命名失败: " . e.Message, "Red")
            result.Set("message", "重命名失败: " . e.Message)
            return result
        }
    } else {
        ; 如果 shouldDownload 为 false，表示不需要下载或用户已取消
        AddLog("AHK 脚本无需更新或用户选择取消。", "Blue")
    }
    result.Set("success", true)
    result.Set("message", "AHK 脚本更新流程完成。")
    return result
}
;tag AHK资源文件更新检查子函数
CheckForResourceUpdate(isManualCheck) {
    global usr, repo
    result := Map("success", false, "message", "未知错误", "updatedCount", 0, "needsReload", false)
    libDir := A_ScriptDir "\lib"
    updatedFiles := []
    failedFiles := []
    updatedCount := 0
    AddLog("开始检查函数库文件更新 (lib 目录)……")
    if !DirExist(libDir) {
        AddLog("本地 lib 目录不存在，尝试创建: " . libDir)
        try {
            DirCreate(libDir)
        } catch as e {
            AddLog("创建 lib 目录失败: " . e.Message, "Red")
            result.Set("message", "无法创建 lib 目录: " . e.Message)
            return result
        }
    }
    apiUrl := "https://api.github.com/repos/" . usr . "/" . repo . "/contents/lib"
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    try {
        whr.Open("GET", apiUrl, false)
        whr.SetRequestHeader("User-Agent", "DoroHelper-AHK-Script-ResourceChecker")
        whr.Send()
        if (whr.Status != 200) {
            errorMsg := "GitHub API 请求失败，状态码: " . whr.Status . ", URL: " . apiUrl
            try {
                errorJson := Json.Load(whr.ResponseText)
                if (errorJson is Object && errorJson.Get("message", "") != "") {
                    errorMsg .= "。API 消息: " . errorJson.Get("message", "")
                }
            } catch {
                ; JSON解析失败，忽略
            }
            throw Error("GitHub API 请求失败", -1, errorMsg)
        }
        responseText := whr.ResponseText
        remoteFilesData := Json.Load(&responseText)
        if (!(remoteFilesData is Array)) {
            AddLog("错误: GitHub API 返回的 lib 目录内容不是预期的数组类型或为空。原始响应 (前500字符): " . SubStr(responseText, 1, 500) . "……", "Red")
            result.Set("message", "GitHub API 返回数据格式错误，可能远程 lib 目录不存在或API限速。")
            return result
        }
        if (!remoteFilesData.Length) {
            AddLog("警告: GitHub API 返回的 lib 目录内容为空。")
            result.Set("success", true)
            result.Set("message", "lib 目录远程无文件。")
            return result
        }
        for _, fileData in remoteFilesData {
            remoteFileName := (fileData is Object) ? fileData.Get("name", "") : ""
            remoteFileType := (fileData is Object) ? fileData.Get("type", "") : ""
            remoteSha := (fileData is Object) ? fileData.Get("sha", "") : ""
            remoteDownloadUrl := (fileData is Object) ? fileData.Get("download_url", "") : ""
            if (remoteFileName == "" || remoteFileType == "" || remoteSha == "" || remoteDownloadUrl == "") {
                AddLog("警告: 远程文件数据缺少关键属性或属性值无效，跳过此项: " . (remoteFileName != "" ? remoteFileName : "未知文件"), "MAROON")
                continue
            }
            currentFileExtension := ""
            SplitPath remoteFileName, , , &currentFileExtension
            currentFileExtension := StrLower(currentFileExtension)
            if (remoteFileType == "file" && currentFileExtension == "ahk") {
                localFilePath := libDir . "\" . remoteFileName
                localSha := ""
                localLastModified := "0"
                localLastModifiedUTC := "0"
                if FileExist(localFilePath) {
                    try {
                        localSha := HashGitSHA1(localFilePath)
                        localLastModified := FileGetTime(localFilePath, "M")
                        ; 转换为UTC时间进行比较
                        A_TimeZone := DateDiff(A_NowUTC, A_Now, "Minutes")
                        localLastModifiedUTC := DateAdd(localLastModified, A_TimeZone, "minutes")
                    } catch as e {
                        AddLog("错误: 计算本地文件 " . remoteFileName . " 哈希、获取修改时间或转换时区失败: " . e.Message, "Red")
                        failedFiles.Push(remoteFileName)
                        continue
                    }
                }
                remoteFileDetails := Map()
                commitObj := (fileData is Object) ? fileData.Get("commit", "") : ""
                if (commitObj is Object) {
                    authorObj := commitObj.Get("author", "")
                    if (authorObj is Object) {
                        commitDateStr := authorObj.Get("date", "")
                        if (commitDateStr != "") {
                            remoteFileDetails.Set("remoteLastModified", ParseDateTimeString(commitDateStr))
                        }
                    }
                }
                remoteLastModifiedFromDetails := remoteFileDetails.Get("remoteLastModified", "")
                needsUpdate := false
                if (localSha != remoteSha) {
                    AddLog("文件 " . remoteFileName . ": 本地哈希 (" . (localSha != "" ? SubStr(localSha, 1, 7) : "无") . ") 与远程哈希 (" . SubStr(remoteSha, 1, 7) . ") 不一致。", "BLUE")
                    needsUpdate := true
                } else if (!FileExist(localFilePath)) {
                    AddLog("文件 " . remoteFileName . ": 本地文件缺失，需要下载。", "BLUE")
                    needsUpdate := true
                } else if (remoteLastModifiedFromDetails != "" && localLastModifiedUTC != "0" && remoteLastModifiedFromDetails > localLastModifiedUTC) {
                    ; 使用UTC时间进行比较
                    AddLog("文件 " . remoteFileName . ": 远程修改时间 (UTC: " . remoteLastModifiedFromDetails . ") 晚于本地 (UTC: " . localLastModifiedUTC . ")。", "BLUE")
                    needsUpdate := true
                }
                if (needsUpdate) {
                    AddLog("正在下载更新文件: " . remoteFileName . "……")
                    try {
                        Download(remoteDownloadUrl, localFilePath)
                        AddLog("成功更新文件: " . remoteFileName, "Green")
                        updatedFiles.Push(remoteFileName)
                        updatedCount++
                        result.Set("needsReload", true)
                    } catch as e {
                        AddLog("下载或替换文件 " . remoteFileName . " 失败: " . e.Message, "Red")
                        failedFiles.Push(remoteFileName)
                    }
                }
            }
        }
    } catch as e {
        AddLog("获取远程函数库文件列表失败，错误信息: " . e.Message, "Red")
        result.Set("message", "获取远程函数库文件列表失败: " . e.Message)
        return result
    }
    result.Set("updatedCount", updatedCount)
    if (updatedCount > 0) {
        result.Set("success", true)
        result.Set("message", "成功更新 " . updatedCount . " 个函数库文件。")
        result.Set("updatedFiles", updatedFiles)
    } else if (failedFiles.Length > 0) {
        result.Set("success", false)
        result.Set("message", "部分函数库文件更新失败。")
        result.Set("failedFiles", failedFiles)
    } else {
        result.Set("success", true)
        result.Set("message", "所有函数库文件均已是最新版本。")
    }
    return result
}
;tag 日期时间解析辅助函数
ParseDateTimeString(dateTimeStr) {
    dateTimeStr := Trim(dateTimeStr)
    isoMatch := ""
    if RegExMatch(dateTimeStr, "(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2}):(\d{2})", &isoMatch) {
        year := isoMatch[1], month := isoMatch[2], day := isoMatch[3]
        hour := isoMatch[4], minute := isoMatch[5], second := isoMatch[6]
        return year . month . day . hour . minute . second
    }
    rfcMatch := ""
    if RegExMatch(dateTimeStr, "\d{1,2}\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{4}\s+\d{2}:\d{2}:\d{2}", &rfcMatch) {
        datePart := rfcMatch[0]
        parts := StrSplit(datePart, " ")
        day := parts[1]
        monthStr := parts[2]
        year := parts[3]
        timeStr := parts[4]
        monthMap := Map(
            "Jan", "01", "Feb", "02", "Mar", "03", "Apr", "04", "May", "05", "Jun", "06",
            "Jul", "07", "Aug", "08", "Sep", "09", "Oct", "10", "Nov", "11", "Dec", "12"
        )
        monthNum := monthMap.Get(monthStr, "")
        if (monthNum == "") {
            return ""
        }
        if (StrLen(day) == 1) {
            day := "0" . day
        }
        finalDateTime := year . monthNum . day . StrReplace(timeStr, ":", "")
        return finalDateTime
    }
    return ""
}
;tag Mirror酱更新检查子函数
CheckForUpdate_Mirror(isManualCheck, channelInfo, &latestObjMapOut) {
    global currentVersion, g_numeric_settings
    sourceName := "Mirror酱"
    latestObjMapOut.Set("message", "")
    latestObjMapOut.Set("foundNewVersion", false)
    AddLog(sourceName . " 更新检查：开始 (" . channelInfo . " 渠道)……")
    if Trim(g_numeric_settings.Get("MirrorCDK")) == "" {
        latestObjMapOut.Set("message", "Mirror酱 CDK 为空，无法检查更新")
        if (isManualCheck) {
            MsgBox(latestObjMapOut.Get("message"), sourceName . "检查更新错误", "IconX")
        }
        AddLog(latestObjMapOut.Get("message"), "Red")
        return false
    }
    apiUrl := "https://mirrorchyan.com/api/resources/DoroHelper/latest?"
    apiUrl .= "cdk=" . g_numeric_settings.Get("MirrorCDK")
    if (g_numeric_settings.Get("UpdateChannels") == "测试版") {
        apiUrl .= "&channel=beta"
    }
    HttpRequest := ""
    ResponseStatus := 0
    ResponseBody := ""
    try {
        HttpRequest := ComObject("WinHttp.WinHttpRequest.5.1")
        HttpRequest.Open("GET", apiUrl, false)
        HttpRequest.SetRequestHeader("User-Agent", "DoroHelper-AHK-Script/" . currentVersion)
        HttpRequest.Send()
        ResponseStatus := HttpRequest.Status
        if (ResponseStatus == 200) {
            ResponseBody := HttpRequest.ResponseBody
        }
    } catch as e {
        latestObjMapOut.Set("message", sourceName . " API 请求失败: " . e.Message)
        if (isManualCheck) {
            MsgBox(latestObjMapOut.Get("message"), sourceName . "检查更新错误", "IconX")
        }
        AddLog(latestObjMapOut.Get("message"), "Red")
        return false
    }
    ResponseTextForJson := ""
    if (ResponseStatus == 200) {
        ; 检查 ResponseBody 是否为 SafeArray 类型 (二进制数据)
        if (IsObject(ResponseBody) && (ComObjType(ResponseBody) & 0x2000)) {
            try {
                dataPtr := 0, lBound := 0, uBound := 0
                DllCall("OleAut32\SafeArrayGetLBound", "Ptr", ComObjValue(ResponseBody), "UInt", 1, "Int64*", &lBound)
                DllCall("OleAut32\SafeArrayGetUBound", "Ptr", ComObjValue(ResponseBody), "UInt", 1, "Int64*", &uBound)
                actualSize := uBound - lBound + 1
                if (actualSize > 0) {
                    DllCall("OleAut32\SafeArrayAccessData", "Ptr", ComObjValue(ResponseBody), "Ptr*", &dataPtr)
                    ResponseTextForJson := StrGet(dataPtr, actualSize, "UTF-8")
                    DllCall("OleAut32\SafeArrayUnaccessData", "Ptr", ComObjValue(ResponseBody))
                } else {
                    AddLog(sourceName . " 警告: SafeArray 大小为0或无效")
                }
            } catch as e_sa {
                AddLog(sourceName . " 错误: 处理 ResponseBody (SafeArray) 失败: " . e_sa.Message . ". 类型: " . ComObjType(ResponseBody, "Name"), "Red")
                ResponseTextForJson := HttpRequest.ResponseText
                AddLog(sourceName . " 警告: SafeArray 处理失败，回退到 HttpRequest.ResponseText，可能存在编码问题")
            }
        }
        ; 如果 ResponseBody 是其他类型的 COM 对象 (例如 ADODB.Stream 可能在某些旧系统或特定配置下返回)
        else if (IsObject(ResponseBody)) {
            AddLog(sourceName . " 警告: ResponseBody 是对象但不是 SafeArray (类型: " . ComObjType(ResponseBody, "Name") . ")，尝试 ADODB.Stream")
            try {
                Stream := ComObject("ADODB.Stream")
                Stream.Type := 1
                Stream.Open()
                Stream.Write(ResponseBody)
                Stream.Position := 0
                Stream.Type := 2
                Stream.Charset := "utf-8"
                ResponseTextForJson := Stream.ReadText()
                Stream.Close()
            } catch as e_adodb {
                AddLog(sourceName . " 错误: ADODB.Stream 处理 ResponseBody (非 SafeArray COM 对象) 失败: " . e_adodb.Message, "Red")
                ResponseTextForJson := HttpRequest.ResponseText
                AddLog(sourceName . " 警告: ADODB.Stream 失败，回退到 HttpRequest.ResponseText，可能存在编码问题")
            }
        }
        ; 如果 ResponseBody 既不是 COM 对象也不是 SafeArray，直接使用 ResponseText (可能存在编码问题)
        else {
            AddLog(sourceName . " 警告: ResponseBody 不是 COM 对象，或请求未成功。将直接使用 HttpRequest.ResponseText")
            ResponseTextForJson := HttpRequest.ResponseText
        }
        try {
            JsonData := Json.Load(&ResponseTextForJson)
            if (!IsObject(JsonData)) {
                latestObjMapOut.Set("message", sourceName . " API 响应格式错误")
                if (isManualCheck) MsgBox(latestObjMapOut.Get("message"), sourceName . "检查更新错误", "IconX")
                    AddLog(latestObjMapOut.Get("message") . ". ResponseText (前200字符): " . SubStr(ResponseTextForJson, 1, 200), "Red")
                return false
            }
            jsonDataCode := JsonData.Get("code", -1)
            potentialData := JsonData.Get("data", unset)
            if (jsonDataCode != 0) {
                errorMsg := sourceName . " API 返回错误。 Code: " . jsonDataCode . "."
                if (JsonData.Has("msg") && Trim(JsonData.Get("msg")) != "") {
                    errorMsg .= " 消息: " . JsonData.Get("msg")
                } else {
                    errorMsg .= " (API未提供详细错误消息)"
                }
                latestObjMapOut.Set("message", errorMsg)
                if (isManualCheck) {
                    MsgBox(latestObjMapOut.Get("message"), sourceName . "检查更新错误", "IconX")
                }
                AddLog(errorMsg, "Red")
                return false
            }
            if (!IsSet(potentialData) || !IsObject(potentialData)) {
                errorMsg := sourceName . " API 响应成功 (code 0)，但 'data' 字段缺失或非对象类型"
                if (JsonData.Has("msg") && Trim(JsonData.Get("msg")) != "") {
                    errorMsg .= " API 消息: " . JsonData.Get("msg")
                }
                latestObjMapOut.Set("message", errorMsg)
                if (isManualCheck) {
                    MsgBox(latestObjMapOut.Get("message"), sourceName . "检查更新错误", "IconX")
                }
                AddLog(errorMsg . " 取回的 'data' 类型: " . Type(potentialData), "Red")
                return false
            }
            mirrorData := potentialData
            latestObjMapOut.Set("version", mirrorData.Get("version_name", ""))
            latestObjMapOut.Set("change_notes", mirrorData.Get("release_note", "无更新说明"))
            latestObjMapOut.Set("download_url", mirrorData.Get("url", ""))
            if latestObjMapOut.Get("version") == "" {
                latestObjMapOut.Set("message", sourceName . " API 响应中版本信息为空")
                if (isManualCheck) {
                    MsgBox(latestObjMapOut.Get("message"), sourceName . "检查更新错误", "IconX")
                }
                AddLog(sourceName . " 更新检查：API响应中版本信息为空", "Red")
                return false
            }
            AddLog(sourceName . " 更新检查：获取到版本 " . latestObjMapOut.Get("version"))
            if (CompareVersionsSemVer(latestObjMapOut.Get("version"), currentVersion) > 0) {
                latestObjMapOut.Set("foundNewVersion", true)
                AddLog(sourceName . " 版本比较：发现新版本", "Green")
            } else {
                latestObjMapOut.Set("foundNewVersion", false)
                AddLog(sourceName . " 版本比较：当前已是最新或更新", "Green")
            }
        } catch as e {
            errorDetails := "错误类型: " . Type(e) . ", 消息: " . e.Message
            if e.HasProp("What") errorDetails .= "`n触发对象/操作: " . e.What
                if e.HasProp("File") errorDetails .= "`n文件: " . e.File
                    if e.HasProp("Line") errorDetails .= "`n行号: " . e.Line
                        latestObjMapOut.Set("message", "处理 " . sourceName . " JSON 数据时发生内部错误: `n" . errorDetails)
            if (isManualCheck) MsgBox(latestObjMapOut.Get("message"), sourceName . "检查更新错误", "IconX")
                AddLog(sourceName . " 更新检查：处理JSON时发生内部错误: " . errorDetails, "Red")
            AddLog(sourceName . " 相关的 ResponseTextForJson (前1000字符): " . SubStr(ResponseTextForJson, 1, 1000))
            return false
        }
    } else {
        errorResponseText := HttpRequest.ResponseText
        responseTextPreview := SubStr(errorResponseText, 1, 300)
        latestObjMapOut.Set("message", sourceName . " API 请求失败！`n状态码: " . ResponseStatus . "`n响应预览:`n" . responseTextPreview)
        if (isManualCheck) {
            MsgBox(latestObjMapOut.Get("message"), sourceName . " API 错误", "IconX")
        }
        AddLog(latestObjMapOut.Get("message"), "Red")
        return false
    }
    return true
}
;tag Github更新检查子函数
CheckForUpdate_Github(isManualCheck, channelInfo, &latestObjMapOut) {
    global currentVersion, usr, repo, g_numeric_settings
    sourceName := "Github"
    latestObjMapOut.Set("message", "")
    latestObjMapOut.Set("foundNewVersion", false)
    AddLog(sourceName . " 更新检查：开始 (" . channelInfo . " 渠道)……")
    try {
        allReleaseAssets := Github.historicReleases(usr, repo)
        if !(allReleaseAssets is Array) || !allReleaseAssets.Length {
            latestObjMapOut.Set("message", "无法获取 Github 版本列表或库返回空数据（非Array或空），请检查网络或仓库信息。")
            if (isManualCheck) {
                MsgBox(latestObjMapOut.Get("message"), sourceName . "检查更新错误", "IconX")
            }
            AddLog(latestObjMapOut.Get("message"), "Red")
            return false
        }
        targetAssetEntry := ""
        if (g_numeric_settings.Get("UpdateChannels") == "测试版") {
            AddLog(sourceName . " 更新检查：测试版优先，已选定最新 Release Assets")
            targetAssetEntry := allReleaseAssets[1]
            if !IsObject(targetAssetEntry) || !targetAssetEntry.HasProp("version") {
                latestObjMapOut.Set("message", sourceName . " 更新检查：获取到的最新测试版 Release Assets 对象无效或缺少版本信息")
                if (isManualCheck) MsgBox(latestObjMapOut.Get("message"), sourceName . "检查更新错误", "IconX")
                    AddLog(latestObjMapOut.Get("message"), "Red")
                return false
            }
        } else {
            AddLog(sourceName . " 更新检查：正式版优先，正在查找……")
            for assetEntry in allReleaseAssets {
                if !IsObject(assetEntry) || !(assetEntry.HasProp("version")) {
                    continue
                }
                current_release_version := assetEntry.version
                if (assetEntry.HasProp("name") && InStr(assetEntry.name, "DoroHelper", false) && InStr(assetEntry.name, ".exe", false) && !(InStr(current_release_version, "beta", false) || InStr(current_release_version, "alpha", false) || InStr(current_release_version, "rc", false))) {
                    targetAssetEntry := assetEntry
                    AddLog(sourceName . " 更新检查：找到正式版下载文件 " . assetEntry.name . "，版本 " . current_release_version)
                    break
                }
            }
            if !IsObject(targetAssetEntry) {
                AddLog(sourceName . " 警告: 未找到任何符合条件的正式版 EXE 下载。回退到查找最新的任何 EXE。", "Red")
                for assetEntry in allReleaseAssets {
                    if !IsObject(assetEntry) || !(assetEntry.HasProp("version")) {
                        continue
                    }
                    if (assetEntry.HasProp("name") && InStr(assetEntry.name, "DoroHelper", false) && InStr(assetEntry.name, ".exe", false)) {
                        targetAssetEntry := assetEntry
                        AddLog(latestObjMapOut.Get("display_name") . " 警告: 回退到最新 EXE 文件 " . assetEntry.name . "，版本 " . assetEntry.version, "MAROON")
                        break
                    }
                }
                if !IsObject(targetAssetEntry) && allReleaseAssets.Length > 0 {
                    targetAssetEntry := allReleaseAssets[1]
                    AddLog(sourceName . " 警告: 无法匹配到 DoroHelper*.exe，回退到最新 Release 的第一个发现的资产。", "MAROON")
                }
                if !IsObject(targetAssetEntry) || !(targetAssetEntry.HasProp("version")) {
                    latestObjMapOut.Set("message", sourceName . " 更新检查：未找到任何有效的 Release Assets。")
                    if (isManualCheck) MsgBox(latestObjMapOut.Get("message"), sourceName . "检查更新错误", "IconX")
                        AddLog(latestObjMapOut.Get("message"), "Red")
                    return false
                }
            }
        }
        if !IsObject(targetAssetEntry) {
            latestObjMapOut.Set("message", sourceName . " 更新检查：未能确定有效的目标 Release Assets。")
            if (isManualCheck) MsgBox(latestObjMapOut.Get("message"), sourceName . "检查更新错误", "IconX")
                AddLog(latestObjMapOut.Get("message"), "Red")
            return false
        }
        latestObjMapOut.Set("version", Trim(targetAssetEntry.version))
        latestObjMapOut.Set("change_notes", Trim(targetAssetEntry.change_notes))
        latestObjMapOut.Set("download_url", Trim(targetAssetEntry.downloadURL))
        if (!targetAssetEntry.HasProp("version") || latestObjMapOut.Get("version") == "") {
            latestObjMapOut.Set("message", sourceName . " 更新检查：未能从选定的 Release Assets 获取到版本号")
            if (isManualCheck) MsgBox(latestObjMapOut.Get("message"), sourceName . "检查更新错误", "IconX")
                AddLog(latestObjMapOut.Get("message"), "Red")
            return false
        }
        if (!targetAssetEntry.HasProp("downloadURL") || latestObjMapOut.Get("download_url") == "") {
            AddLog(sourceName . " 警告: 未能为版本 " . latestObjMapOut.Get("version") . " 找到有效的下载链接。", "MAROON")
        }
        AddLog(sourceName . " 更新检查：获取到版本 " . latestObjMapOut.Get("version") . (latestObjMapOut.Get("download_url") ? "" : " (下载链接未找到)"))
        if (CompareVersionsSemVer(latestObjMapOut.Get("version"), currentVersion) > 0) {
            latestObjMapOut.Set("foundNewVersion", true)
            AddLog(sourceName . " 版本比较：发现新版本", "Green")
        } else {
            latestObjMapOut.Set("foundNewVersion", false)
            AddLog(sourceName . " 版本比较：当前已是最新或更新", "Green")
        }
    } catch as githubError {
        errorMessage := ""
        if (IsObject(githubError)) {
            msg := githubError.Message
            extra := githubError.Extra
            if (msg != "") {
                errorMessage .= msg
            }
            else {
                try {
                    tempStr := ""
                    if (githubError.HasMethod("ToString")) {
                        tempStr := githubError.ToString()
                    }
                    else {
                        tempStr := "对象无法通过标准ToString()方法获取详情。"
                    }
                    if (tempStr != "") {
                        errorMessage .= tempStr
                    }
                    else {
                        errorMessage .= "错误对象类型: " . Type(githubError)
                    }
                } catch {
                    errorMessage .= "无法获取原始错误对象详情（ToString()失败）。"
                }
            }
            if (extra != "") {
                errorMessage .= "`nExtra: " . extra
            }
        } else {
            errorMessage := "Github库返回了一个非对象错误: " . githubError
        }
        latestObjMapOut.Set("message", "Github 检查更新失败: `n" . errorMessage)
        if (isManualCheck) {
            MsgBox(latestObjMapOut.Get("message"), sourceName . "检查更新错误", "IconX")
        }
        AddLog(latestObjMapOut.Get("message"), "Red")
        return false
    }
    return true
}
;tag 显示更新通知GUI
DisplayUpdateNotification() {
    global currentVersion, latestObj, g_numeric_settings
    channelInfo := (g_numeric_settings.Get("UpdateChannels") == "测试版") ? "测试版" : "正式版"
    MyGui := Gui("+Resize", "更新提示 (" . latestObj.Get("display_name") . ")")
    MyGui.SetFont("s10", "Microsoft YaHei UI")
    MyGui.Add("Text", "w300 xm ym", "发现 DoroHelper 新版本 (" . channelInfo . " - " . latestObj.Get("display_name") . "):")
    MyGui.Add("Text", "xp+10 yp+25 w300", "最新版本: " . latestObj.Get("version"))
    MyGui.Add("Text", "xp yp+20 w300", "当前版本: " . currentVersion)
    MyGui.Add("Text", "xp yp+25 w300", "更新内容:")
    notes_for_edit := latestObj.Get("change_notes")
    notes_for_edit := StrReplace(notes_for_edit, "`r`n", "`n")
    notes_for_edit := StrReplace(notes_for_edit, "`r", "`n")
    notes_for_edit := StrReplace(notes_for_edit, "`n", "`r`n")
    MyGui.Add("Edit", "w250 h200 ReadOnly VScroll Border", notes_for_edit)
    MyGui.Add("Button", "xm+20 w100 h30 yp+220", "立即下载").OnEvent("Click", DownloadUpdate)
    MyGui.Add("Button", "x+20 w100 h30", "稍后提醒").OnEvent("Click", (*) => MyGui.Destroy())
    MyGui.Show("w320 h400 Center")
}
;tag 统一更新下载
DownloadUpdate(*) {
    global latestObj
    if (!IsObject(latestObj) || latestObj.Get("source", "") == "" || latestObj.Get("version", "") == "") {
        MsgBox("下载错误：更新信息不完整，无法开始下载", "下载错误", "IconX")
        AddLog("下载错误：latestObj 信息不完整。 Source: " . latestObj.Get("source", "N/A") . ", Version: " . latestObj.Get("version", "N/A"), "Red")
        return
    }
    downloadTempName := "DoroDownload.exe"
    finalName := "DoroHelper-" . latestObj.Get("version") . ".exe"
    downloadUrlToUse := latestObj.Get("download_url")
    if downloadUrlToUse == "" {
        MsgBox("错误：找不到有效的 " . latestObj.Get("display_name") . " 下载链接", "下载错误", "IconX")
        AddLog(latestObj.Get("display_name") . " 下载错误：下载链接为空", "Red")
        return
    }
    AddLog(latestObj.Get("display_name") . " 下载：开始下载 " . downloadUrlToUse . " 到 " . A_ScriptDir . "\" . finalName)
    downloadStatusCode := 0
    try {
        if latestObj.Get("source") == "github" {
            ErrorLevel := 0
            Github.Download(downloadUrlToUse, A_ScriptDir . "\" . downloadTempName)
            downloadStatusCode := ErrorLevel
            if downloadStatusCode != 0 {
                throw Error("Github 下载失败 (ErrorLevel: " . downloadStatusCode . "). 检查 Github.Download 库的内部提示或网络")
            }
        } else if latestObj.Get("source") == "mirror" {
            ErrorLevel := 0
            Download downloadUrlToUse, A_ScriptDir . "\" . downloadTempName
            downloadStatusCode := ErrorLevel
            if downloadStatusCode != 0 {
                throw Error("Mirror酱下载失败 (错误代码: " . downloadStatusCode . ")")
            }
        } else {
            throw Error("未知的下载源: " . latestObj.Get("source"))
        }
        FileMove A_ScriptDir . "\" . downloadTempName, A_ScriptDir . "\" . finalName, 1
        MsgBox("新版本已通过 " . latestObj.Get("display_name") . " 下载至当前目录: `n" . A_ScriptDir . "\" . finalName, "下载完成")
        AddLog(latestObj.Get("display_name") . " 下载：成功下载并保存为 " . finalName, "Green")
        ExitApp
    } catch as downloadError {
        MsgBox(latestObj.Get("display_name") . " 下载失败: `n" . downloadError.Message, "下载错误", "IconX")
        AddLog(latestObj.Get("display_name") . " 下载失败: " . downloadError.Message, "Red")
        if FileExist(A_ScriptDir . "\" . downloadTempName) {
            try {
                FileDelete(A_ScriptDir . "\" . downloadTempName)
            } catch {
            }
        }
    }
}
;tag 点击检查更新
ClickOnCheckForUpdate(*) {
    AddLog("手动检查更新")
    CheckForUpdate(true)
}
;tag 版本比较
CompareVersionsSemVer(v1, v2) {
    _IsNumericString(str) => RegExMatch(str, "^\d+$")
    v1 := RegExReplace(v1, "^v", "")
    v2 := RegExReplace(v2, "^v", "")
    v1Parts := StrSplit(v1, "+", , 2)
    v2Parts := StrSplit(v2, "+", , 2)
    v1Base := v1Parts[1]
    v2Base := v2Parts[1]
    v1CoreParts := StrSplit(v1Base, "-", , 2)
    v2CoreParts := StrSplit(v2Base, "-", , 2)
    v1Core := v1CoreParts[1]
    v2Core := v2CoreParts[1]
    v1Pre := v1CoreParts.Length > 1 ? v1CoreParts[2] : ""
    v2Pre := v2CoreParts.Length > 1 ? v2CoreParts[2] : ""
    v1CoreNums := StrSplit(v1Core, ".")
    v2CoreNums := StrSplit(v2Core, ".")
    loop 3 {
        seg1Str := A_Index <= v1CoreNums.Length ? Trim(v1CoreNums[A_Index]) : "0"
        seg2Str := A_Index <= v2CoreNums.Length ? Trim(v2CoreNums[A_Index]) : "0"
        if !_IsNumericString(seg1Str) {
            seg1Str := "0"
        }
        if !_IsNumericString(seg2Str) {
            seg2Str := "0"
        }
        num1 := Integer(seg1Str)
        num2 := Integer(seg2Str)
        if (num1 > num2) {
            return 1
        }
        if (num1 < num2) {
            return -1
        }
    }
    hasV1Pre := v1Pre != ""
    hasV2Pre := v2Pre != ""
    if (hasV1Pre && !hasV2Pre) {
        return -1
    }
    if (!hasV1Pre && hasV2Pre) {
        return 1
    }
    if (!hasV1Pre && !hasV2Pre) {
        return 0
    }
    v1PreSegments := StrSplit(v1Pre, ".")
    v2PreSegments := StrSplit(v2Pre, ".")
    maxLen := Max(v1PreSegments.Length, v2PreSegments.Length)
    loop maxLen {
        if (A_Index > v1PreSegments.Length) {
            return -1
        }
        if (A_Index > v2PreSegments.Length) {
            return 1
        }
        seg1 := Trim(v1PreSegments[A_Index])
        seg2 := Trim(v2PreSegments[A_Index])
        isNum1 := _IsNumericString(seg1)
        isNum2 := _IsNumericString(seg2)
        if (isNum1 && isNum2) {
            numSeg1 := Integer(seg1)
            numSeg2 := Integer(seg2)
            if (numSeg1 > numSeg2)
                return 1
            if (numSeg1 < numSeg2)
                return -1
        } else if (!isNum1 && !isNum2) {
            compareResult := StrCompare(seg1, seg2)
            if (compareResult > 0)
                return 1
            if (compareResult < 0)
                return -1
        } else {
            if (isNum1)
                return -1
            if (isNum2)
                return 1
        }
    }
    return 0
}
;tag 删除旧程序
DeleteOldFile(*) {
    currentScriptPath := A_ScriptFullPath
    scriptDir := A_ScriptDir
    foundAnyDeletableFile := false
    loop files, scriptDir . "\*.*" {
        currentFile := A_LoopFileFullPath
        fileName := A_LoopFileName
        if (InStr(fileName, "DoroHelper", false) && currentFile != currentScriptPath) {
            if (!foundAnyDeletableFile) {
                AddLog("开始在目录 " . scriptDir . " 中查找并删除旧版本文件")
                AddLog("当前正在运行的脚本路径: " . currentScriptPath)
                foundAnyDeletableFile := true
            }
            try {
                FileDelete currentFile
                AddLog("成功删除旧版本程序: " . currentFile)
            } catch as e {
                AddLog("删除文件失败: " . currentFile . " 错误: " . e.Message, "Red")
            }
        } else if (currentFile == currentScriptPath) {
            if (foundAnyDeletableFile) {
                AddLog("跳过当前运行的程序（自身）: " . currentFile)
            }
        }
    }
    if (foundAnyDeletableFile) {
        AddLog("旧版本文件删除操作完成")
    }
}
;endregion 更新辅助函数
;region 身份辅助函数
;tag 下载指定URL的内容
DownloadUrlContent(url) {
    ; 这个函数是获取纯文本内容，而不是下载文件到磁盘。
    ; 请注意与 Download 命令的区别。
    ; ----------------- 1. 尝试使用 WinHttp.WinHttpRequest.5.1 (首选) -----------------
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", url, true)
        whr.Send()
        whr.WaitForResponse(10) ; 10 秒超时
        if (whr.Status != 200) {
            ; 遇到非200状态码，抛出异常，触发下面的MSXML2备用方案
            throw Error("HTTP状态码非200 (WinHttp)", -1, "状态码: " . whr.Status)
        }
        ; ----------------- WinHttp 内容解码逻辑 -----------------
        responseBody := whr.ResponseBody
        if (IsObject(responseBody) && ComObjType(responseBody) & 0x2000) { ; SafeArray (VT_ARRAY)
            dataPtr := 0, lBound := 0, uBound := 0
            DllCall("OleAut32\SafeArrayGetLBound", "Ptr", ComObjValue(responseBody), "UInt", 1, "Int64*", &lBound)
            DllCall("OleAut32\SafeArrayGetUBound", "Ptr", ComObjValue(responseBody), "UInt", 1, "Int64*", &uBound)
            actualSize := uBound - lBound + 1
            if (actualSize > 0) {
                DllCall("OleAut32\SafeArrayAccessData", "Ptr", ComObjValue(responseBody), "Ptr*", &dataPtr)
                content := StrGet(dataPtr, actualSize, "UTF-8")
                DllCall("OleAut32\SafeArrayUnaccessData", "Ptr", ComObjValue(responseBody))
                return content
            } else {
                AddLog("下载 URL 内容警告: SafeArray 大小为0或无效，URL: " . url, "MAROON")
                return ""
            }
        } else if IsObject(responseBody) { ; Other COM object, try ADODB.Stream
            Stream := ComObject("ADODB.Stream")
            Stream.Type := 1 ; adTypeBinary
            Stream.Open()
            Stream.Write(responseBody)
            Stream.Position := 0
            Stream.Type := 2 ; adTypeText
            Stream.Charset := "utf-8"
            content := Stream.ReadText()
            Stream.Close()
            return content
        } else { ; Not a COM object, fallback to ResponseText (may have encoding issues)
            AddLog("下载 URL 内容警告: ResponseBody 不是预期类型，回退到 ResponseText，URL: " . url, "MAROON")
            return whr.ResponseText
        }
    } catch as e1 {
        AddLog("使用 WinHttp.WinHttpRequest.5.1 失败，尝试备用方案。错误: " . e1.Message . " URL: " . url, "RED")
        ; ----------------- 2. 尝试使用 MSXML2.XMLHTTP (备用) -----------------
        try {
            AddLog("尝试使用 MSXML2.XMLHTTP 备用方案下载...", "BLUE")
            xhr := ComObject("MSXML2.XMLHTTP")
            ; 备用方案使用同步请求 (false) 简化处理
            xhr.Open("GET", url, false)
            xhr.Send()
            if (xhr.Status != 200) {
                AddLog("备用方案下载 URL 内容失败，HTTP状态码: " . xhr.Status . " URL: " . url, "Red")
                return ""
            }
            ; ----------------- MSXML2 内容解码逻辑 (与 WinHttp 逻辑相同) -----------------
            responseBody := xhr.ResponseBody
            if (IsObject(responseBody) && ComObjType(responseBody) & 0x2000) { ; SafeArray (VT_ARRAY)
                dataPtr := 0, lBound := 0, uBound := 0
                DllCall("OleAut32\SafeArrayGetLBound", "Ptr", ComObjValue(responseBody), "UInt", 1, "Int64*", &lBound)
                DllCall("OleAut32\SafeArrayGetUBound", "Ptr", ComObjValue(responseBody), "UInt", 1, "Int64*", &uBound)
                actualSize := uBound - lBound + 1
                if (actualSize > 0) {
                    DllCall("OleAut32\SafeArrayAccessData", "Ptr", ComObjValue(responseBody), "Ptr*", &dataPtr)
                    content := StrGet(dataPtr, actualSize, "UTF-8")
                    DllCall("OleAut32\SafeArrayUnaccessData", "Ptr", ComObjValue(responseBody))
                    return content
                } else {
                    AddLog("下载 URL 内容警告 (备用): SafeArray 大小为0或无效，URL: " . url, "MAROON")
                    return ""
                }
            } else if IsObject(responseBody) { ; Other COM object, try ADODB.Stream
                Stream := ComObject("ADODB.Stream")
                Stream.Type := 1 ; adTypeBinary
                Stream.Open()
                Stream.Write(responseBody)
                Stream.Position := 0
                Stream.Type := 2 ; adTypeText
                Stream.Charset := "utf-8"
                content := Stream.ReadText()
                Stream.Close()
                return content
            } else { ; Not a COM object, fallback to ResponseText (may have encoding issues)
                AddLog("下载 URL 内容警告 (备用): ResponseBody 不是预期类型，回退到 ResponseText，URL: " . url, "MAROON")
                return xhr.ResponseText
            }
        } catch as e2 {
            ; MSXML2 备用方案也失败
            AddLog("下载 URL 内容时发生错误: 两次尝试均失败。WinHttp错误: " . e1.Message . " | MSXML2错误: " . e2.Message . " URL: " . url, "Red")
            return ""
        }
    }
}
;tag 计算SHA256哈希值
HashSHA256(input) {
    hProv := 0, hHash := 0
    if !DllCall("Advapi32\CryptAcquireContextW", "Ptr*", &hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xF0000000) {
        throw Error("CryptAcquireContext 失败", -1, "无法获取加密服务提供者句柄")
    }
    if !DllCall("Advapi32\CryptCreateHash", "Ptr", hProv, "UInt", 0x800C, "Ptr", 0, "UInt", 0, "Ptr*", &hHash) {
        DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
        throw Error("CryptCreateHash 失败", -1, "无法创建哈希对象")
    }
    if FileExist(input) {
        try {
            fileContent := FileRead(input, "UTF-8")
            normalizedContent := StrReplace(fileContent, "`r`n", "`n")
            normalizedContent := StrReplace(normalizedContent, "`r", "`n")
            strByteLen := StrPut(normalizedContent, "UTF-8") - 1
            if (strByteLen >= 0) {
                strBuf := Buffer(strByteLen)
                StrPut(normalizedContent, strBuf, "UTF-8")
                if !DllCall("Advapi32\CryptHashData", "Ptr", hHash, "Ptr", strBuf, "UInt", strByteLen, "UInt", 0) {
                    throw Error("CryptHashData (文件) 失败", -1, "更新文件哈希数据时出错")
                }
            }
        } catch as e {
            DllCall("Advapi32\CryptDestroyHash", "Ptr", hHash)
            DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
            throw e
        }
    } else {
        strByteLen := StrPut(input, "UTF-8") - 1
        if (strByteLen >= 0) {
            strBuf := Buffer(strByteLen)
            StrPut(input, strBuf, "UTF-8")
            if !DllCall("Advapi32\CryptHashData", "Ptr", hHash, "Ptr", strBuf, "UInt", strByteLen, "UInt", 0) {
                throw Error("CryptHashData (字符串) 失败", -1, "更新字符串哈希数据时出错")
            }
        }
    }
    hashSize := 32
    hashBuf := Buffer(hashSize)
    if !DllCall("Advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", hashBuf, "UInt*", &hashSize, "UInt", 0) {
        DllCall("Advapi32\CryptDestroyHash", "Ptr", hHash)
        DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
        throw Error("CryptGetHashParam 失败", -1, "无法获取最终的哈希值")
    }
    hexHash := ""
    loop hashSize {
        hexHash .= Format("{:02x}", NumGet(hashBuf, A_Index - 1, "UChar"))
    }
    DllCall("Advapi32\CryptDestroyHash", "Ptr", hHash)
    DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
    return hexHash
}
;tag 计算GitSHA-1哈希值 (已修正行尾序列问题，并正确处理BOM)
HashGitSHA1(filePath) {
    if !FileExist(filePath) {
        throw Error("文件不存在", -1, "指定的Git SHA-1哈希文件路径无效: " . filePath)
    }
    ; 使用 FileRead() 以 RAW 编码读取文件，获取原始字节流，包括 BOM（如果存在）。
    ; FileRead(Filename, Encoding, MaxBytes)
    ; 当 Encoding 为 "RAW" 时，FileRead 返回一个 Buffer 对象，包含文件的原始字节。
    try {
        fileContentRawBuffer := FileRead(filePath, "RAW")
    } catch as e {
        throw Error("读取文件失败", -1, "无法读取文件内容进行Git SHA-1哈希计算: " . filePath . " 错误: " . e.Message)
    }
    ; 创建一个新的 Buffer 来存储经过 Git 行尾标准化后的内容。
    ; 初始大小设置为原始 Buffer 的大小，以防万一内容全部是 LF。
    normalizedContentBuf := Buffer(fileContentRawBuffer.Size)
    newSize := 0
    i := 0
    ; 遍历原始字节流，进行 Git 风格的行尾标准化：
    ; 将 CRLF (`\r\n`) 转换为 LF (`\n`)
    ; 将单独的 CR (`\r`) 转换为 LF (`\n`)
    while i < fileContentRawBuffer.Size {
        byte := NumGet(fileContentRawBuffer, i, "UChar")
        if byte == 0x0D { ; 检测到回车符 (CR)
            ; 写入换行符 (LF)
            NumPut("UChar", 0x0A, normalizedContentBuf, newSize)
            newSize += 1
            ; 如果 CR 后面紧跟着 LF，则跳过这个 LF，因为我们已经写入了一个 LF
            if (i + 1 < fileContentRawBuffer.Size && NumGet(fileContentRawBuffer, i + 1, "UChar") == 0x0A) {
                i += 1 ; 跳过 LF
            }
        } else { ; 非 CR 字节，直接复制
            NumPut("UChar", byte, normalizedContentBuf, newSize)
            newSize += 1
        }
        i += 1
    }
    ; 调整标准化后 Buffer 的实际大小
    normalizedContentBuf.Size := newSize
    ; Git SHA-1 哈希计算需要一个特定的头部："blob <size>\0"
    gitHeaderStr := "blob " . newSize . Chr(0)
    ; 计算头部字符串的 UTF-8 字节长度
    ; StrPut 返回写入的字节数（包括 null 终止符），减去 1 得到实际内容长度
    gitHeaderLen := StrPut(gitHeaderStr, "UTF-8") - 1
    ; 创建一个 Buffer 来存储 Git 头部
    gitHeaderBuf := Buffer(gitHeaderLen)
    StrPut(gitHeaderStr, gitHeaderBuf, "UTF-8")
    ; 初始化加密上下文和哈希对象
    hProv := 0, hHash := 0
    if !DllCall("Advapi32\CryptAcquireContextW", "Ptr*", &hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xF0000000) {
        throw Error("CryptAcquireContext 失败", -1, "无法获取加密服务提供者句柄")
    }
    ; 使用 SHA-1 算法 (0x8004)
    if !DllCall("Advapi32\CryptCreateHash", "Ptr", hProv, "UInt", 0x8004, "Ptr", 0, "UInt", 0, "Ptr*", &hHash) {
        DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
        throw Error("CryptCreateHash 失败", -1, "无法创建哈希对象")
    }
    try {
        ; 1. 哈希 Git 头部
        if !DllCall("Advapi32\CryptHashData", "Ptr", hHash, "Ptr", gitHeaderBuf, "UInt", gitHeaderLen, "UInt", 0) {
            throw Error("CryptHashData (头部) 失败", -1, "更新头部哈希数据时出错")
        }
        ; 2. 哈希标准化后的文件内容
        if !DllCall("Advapi32\CryptHashData", "Ptr", hHash, "Ptr", normalizedContentBuf, "UInt", newSize, "UInt", 0) {
            throw Error("CryptHashData (内容) 失败", -1, "更新文件内容哈希数据时出错")
        }
    } catch as e {
        DllCall("Advapi32\CryptDestroyHash", "Ptr", hHash)
        DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
        throw e
    }
    ; 获取最终的 SHA-1 哈希值 (20 字节)
    hashSize := 20
    hashBuf := Buffer(hashSize)
    if !DllCall("Advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", hashBuf, "UInt*", &hashSize, "UInt", 0) {
        DllCall("Advapi32\CryptDestroyHash", "Ptr", hHash)
        DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
        throw Error("CryptGetHashParam 失败", -1, "无法获取最终的哈希值")
    }
    ; 将字节数组转换为十六进制字符串
    hexHash := ""
    loop hashSize {
        hexHash .= Format("{:02x}", NumGet(hashBuf, A_Index - 1, "UChar"))
    }
    ; 清理资源
    DllCall("Advapi32\CryptDestroyHash", "Ptr", hHash)
    DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
    return hexHash
}
;tag 获取主板序列号的函数
GetMainBoardSerial() {
    wmi := ComObjGet("winmgmts:\\.\root\cimv2")
    query := "SELECT * FROM Win32_BaseBoard"
    for board in wmi.ExecQuery(query) {
        return board.SerialNumber
    }
    return "未找到序列号"
}
;tag 获取CPU序列号的函数
GetCpuSerial() {
    wmi := ComObjGet("winmgmts:\\.\root\cimv2")
    query := "SELECT * FROM Win32_Processor"
    for cpu in wmi.ExecQuery(query) {
        return cpu.ProcessorID
    }
    return "未找到序列号"
}
;tag 获取第一块硬盘序列号的函数
GetDiskSerial() {
    wmi := ComObjGet("winmgmts:\\.\root\cimv2")
    query := "SELECT * FROM Win32_DiskDrive"
    for disk in wmi.ExecQuery(query) {
        return disk.SerialNumber
    }
    return "未找到序列号"
}
;tag 获取所有硬盘序列号的函数
GetDiskSerialsForValidation() {
    wmi := ComObjGet("winmgmts:\\.\root\cimv2")
    query := "SELECT * FROM Win32_DiskDrive"
    diskSerials := []
    for disk in wmi.ExecQuery(query) {
        diskSerials.Push(disk.SerialNumber)
    }
    return diskSerials
}
;tag 返回:剩余价值(数字)
CalculateUserMembershipDollars(membershipType, expiryDate, unitPrice) {
    global g_MembershipLevels
    remainingValue := 0
    if (!g_MembershipLevels.Has(membershipType)) {
        return 0 ; 无效会员类型
    }
    levelInfo := g_MembershipLevels.Get(membershipType)
    monthlyCost := levelInfo.monthlyCost
    ; 将 YYYYMMDD 格式的过期日期转换为 AHK 内部时间戳，补足时分秒，与 A_Now 进行比较
    ; 假定过期日期的结束是当天的最后一秒
    currentExpiryTimestamp := expiryDate . "235959" ; YYYYMMDDHHmmss
    ; 如果当前时间已超过或等于过期时间，则没有剩余价值
    if (A_Now >= currentExpiryTimestamp) {
        return 0
    }
    secondsRemaining := DateDiff(currentExpiryTimestamp, A_Now, "Seconds")
    daysRemaining := Floor(secondsRemaining / (24 * 3600)) ; 精确到天
    ; 这里按月计算价值 (向下取整)，不足一月不算
    remainingMonthsFloor := Floor(daysRemaining / 30) ; 假设一个月30天，简化计算
    ; 或者可以尝试更精确的月数计算，但 "向下取整" 对于不足一个月的部分会丢弃
    ; remainingMonthsRaw := DateDiff(currentExpiryTimestamp, A_Now, "Months")
    ; remainingMonthsFloor := Floor(remainingMonthsRaw)
    if (remainingMonthsFloor > 0) {
        remainingValue := monthlyCost * unitPrice * remainingMonthsFloor
    }
    return remainingValue
}
; --- 新增私有辅助函数 ---
; 私有函数：获取并解析用户组数据
; 成功返回 Map 对象，失败抛出 Error
_FetchAndParseGroupData() {
    AddLog("正在从网络获取用户组数据……", "Blue")
    jsonUrl := "https://gitee.com/con_sul/DoroHelper/raw/main/group/GroupArrayV3.json"
    jsonContent := DownloadUrlContent(jsonUrl)
    if (jsonContent = "") {
        AddLog("无法获取用户组信息，请检查网络。", "Red")
        throw Error("无法获取用户组信息", -1, "网络或Gitee访问失败")
    }
    try {
        groupData := Json.Load(&jsonContent)
        if !IsObject(groupData) {
            AddLog("解析用户组 JSON 文件失败或格式不正确。", "Red")
            throw Error("解析 JSON 文件失败", -1, "JSON格式不正确")
        }
        return groupData
    } catch as e {
        AddLog("解析用户组 JSON 文件时发生错误: " . e.Message, "Red")
        throw Error("解析 JSON 文件时发生错误", -1, e.Message)
    }
}
; 私有函数：根据哈希值从用户组数据中获取会员信息
; 返回一个 Map: {MembershipType: "...", UserLevel: N, ExpirationTime: "YYYYMMDD"}
_GetMembershipInfoForHash(targetHash, groupData) {
    local result := Map(
        "MembershipType", "普通用户",
        "UserLevel", 0,
        "ExpirationTime", "19991231" ; 默认过期日期
    )
    local CurrentDate := A_YYYY A_MM A_DD
    for _, memberInfo in groupData {
        if IsObject(memberInfo) && memberInfo.Has("hash") && (memberInfo["hash"] == targetHash) {
            if memberInfo.Has("expiry_date") && memberInfo.Has("tier") {
                local memberExpiryDate := memberInfo["expiry_date"]
                local memberTier := memberInfo["tier"]
                local level := 0
                if (memberTier == "管理员") {
                    level := 10
                } else if (memberTier == "金Doro会员") {
                    level := 3
                } else if (memberTier == "银Doro会员") {
                    level := 2
                } else if (memberTier == "铜Doro会员") {
                    level := 1
                }
                ; 如果是管理员，直接设为最高等级且永不过期
                if (level == 10) {
                    result["MembershipType"] := "管理员"
                    result["UserLevel"] := 10
                    result["ExpirationTime"] := "99991231"
                    return result ; 管理员是最高优先级，直接返回
                }
                ; 只有当找到的会员等级更高时才更新结果
                if (level > result["UserLevel"]) {
                    if (memberExpiryDate >= CurrentDate) {
                        result["MembershipType"] := memberTier
                        result["UserLevel"] := level
                        result["ExpirationTime"] := memberExpiryDate
                    } else {
                        AddLog("哈希 '" . targetHash . "' 匹配，但会员 " . memberTier . " 已过期 (到期日: " . memberExpiryDate . ").", "MAROON")
                    }
                }
            } else {
                AddLog("警告: 在JSON中找到哈希 '" . targetHash . "'，但会员信息不完整 (缺少tier或expiry_date)。", "MAROON")
            }
        }
    }
    return result
}
;tag 确定用户组
CheckUserGroup(forceUpdate := false) {
    global VariableUserGroup, g_numeric_settings, g_MembershipLevels
    static cachedUserGroupInfo := false
    ; 首次运行时，cachedUserGroupInfo 是 false，需要初始化
    if (!IsObject(cachedUserGroupInfo)) {
        cachedUserGroupInfo := Map(
            "MembershipType", g_numeric_settings.Get("UserGroup", "普通用户"),
            "UserLevel", g_numeric_settings.Get("UserLevel", 0),
            "ExpirationTime", "19991231"
        )
        if (cachedUserGroupInfo["MembershipType"] == "管理员") {
            cachedUserGroupInfo["ExpirationTime"] := "99991231"
        }
    }
    ; 检查缓存是否过期
    cachedExpiryTimestamp := cachedUserGroupInfo["ExpirationTime"] . "235959"
    if (!forceUpdate && cachedUserGroupInfo["UserLevel"] >= g_numeric_settings["UserLevel"] && A_Now < cachedExpiryTimestamp) {
        if (IsSet(VariableUserGroup) && IsObject(VariableUserGroup)) {
            VariableUserGroup.Value := cachedUserGroupInfo["MembershipType"]
        }
        g_numeric_settings["UserGroup"] := cachedUserGroupInfo["MembershipType"]
        g_numeric_settings["UserLevel"] := cachedUserGroupInfo["UserLevel"]
        return cachedUserGroupInfo
    }
    AddLog(!forceUpdate ? "首次运行或强制更新，正在检查用户组信息……" : "强制检查用户组信息……", "Blue")
    try {
        groupData := _FetchAndParseGroupData()
    } catch as e {
        AddLog("用户组检查失败: " . e.Message, "Red")
        ; 失败时返回默认普通用户状态
        cachedUserGroupInfo := Map("MembershipType", "普通用户", "UserLevel", 0, "ExpirationTime", "19991231")
        g_numeric_settings["UserGroup"] := cachedUserGroupInfo["MembershipType"]
        g_numeric_settings["UserLevel"] := cachedUserGroupInfo["UserLevel"]
        return cachedUserGroupInfo
    }
    ; 2. 获取硬件信息
    local mainBoardSerial, cpuSerial, diskSerials
    try {
        mainBoardSerial := GetMainBoardSerial()
        cpuSerial := GetCpuSerial()
        diskSerials := GetDiskSerialsForValidation()
        if (diskSerials.Length = 0) {
            AddLog("警告: 未检测到任何硬盘序列号，可能影响用户组验证。", "MAROON")
        }
    } catch as e {
        AddLog("获取硬件信息失败: " . e.Message, "Red")
        cachedUserGroupInfo := Map("MembershipType", "普通用户", "UserLevel", 0, "ExpirationTime", "19991231")
        g_numeric_settings["UserGroup"] := cachedUserGroupInfo["MembershipType"]
        g_numeric_settings["UserLevel"] := cachedUserGroupInfo["UserLevel"]
        return cachedUserGroupInfo
    }
    ; 3. 校验用户组成员资格
    local highestMembership := Map(
        "MembershipType", "普通用户",
        "UserLevel", 0,
        "ExpirationTime", "19991231"
    )
    for diskSerial in diskSerials {
        local Hashed := HashSHA256(mainBoardSerial . cpuSerial . diskSerial)
        local currentHashInfo := _GetMembershipInfoForHash(Hashed, groupData)
        ; 如果找到管理员，直接更新并跳出所有循环
        if (currentHashInfo["UserLevel"] == 10) {
            highestMembership := currentHashInfo
            break
        }
        ; 如果当前哈希对应的会员等级更高，则更新最高会员信息
        if (currentHashInfo["UserLevel"] > highestMembership["UserLevel"]) {
            highestMembership := currentHashInfo
        }
    }
    ; 更新全局设置和GUI显示
    g_numeric_settings["UserGroup"] := highestMembership["MembershipType"]
    if (IsSet(VariableUserGroup) && IsObject(VariableUserGroup)) {
        VariableUserGroup.Value := g_numeric_settings["UserGroup"]
    }
    g_numeric_settings["UserLevel"] := highestMembership["UserLevel"]
    ; 根据 g_numeric_settings["UserLevel"] 重新计算 IsPremium 和 IsAdmin
    highestMembership["IsPremium"] := g_numeric_settings["UserLevel"] > 0
    highestMembership["IsAdmin"] := g_numeric_settings["UserLevel"] >= 10
    if (highestMembership["IsPremium"] || highestMembership["IsAdmin"]) {
        if (highestMembership["IsAdmin"]) {
            ; TrySetIcon "icon\AdminDoro.ico"
            AddLog("当前用户组：管理员", "Green")
        } else {
            local formattedExpiryDate := SubStr(highestMembership["ExpirationTime"], 1, 4) . "-" . SubStr(highestMembership["ExpirationTime"], 5, 2) . "-" . SubStr(highestMembership["ExpirationTime"], 7, 2)
            if (g_numeric_settings["UserLevel"] == 3) {
                try TraySetIcon("icon\GoldDoro.ico")
            } else if (g_numeric_settings["UserLevel"] == 2) {
                try TraySetIcon("icon\SilverDoro.ico")
            } else if (g_numeric_settings["UserLevel"] == 1) {
                try TraySetIcon("icon\CopperDoro.ico")
            }
            AddLog("当前用户组：" . g_numeric_settings["UserGroup"] . " (有效期至 " . formattedExpiryDate . ") ", "Green")
        }
        AddLog("欢迎加入会员qq群759311938", "Green")
    } else {
        AddLog("当前用户组：普通用户 (免费用户)")
        try TraySetIcon("doro.ico")
    }
    AddLog("欢迎加入反馈qq群584275905")
    cachedUserGroupInfo := highestMembership
    return highestMembership
}
;tag 根据输入的哈希值检查用户组 (重构后)
CheckUserGroupByHash(inputHash) {
    global g_MembershipLevels
    AddLog("开始检查输入哈希值 '" . inputHash . "' 的用户组信息……", "Blue")
    if (Trim(inputHash) == "") {
        MsgBox("请输入要查询的设备哈希值。", "输入错误", "IconW")
        AddLog("用户未输入哈希值。", "MAROON")
        return
    }
    try {
        groupData := _FetchAndParseGroupData()
        memberInfo := _GetMembershipInfoForHash(inputHash, groupData)
        local resultMessage := "查询哈希值: " . inputHash . "`n"
        if (memberInfo["UserLevel"] > 0) {
            local formattedExpiryDate := memberInfo["ExpirationTime"]
            if (formattedExpiryDate != "永不过期") {
                formattedExpiryDate := SubStr(formattedExpiryDate, 1, 4) . "-" . SubStr(formattedExpiryDate, 5, 2) . "-" . SubStr(formattedExpiryDate, 7, 2)
            }
            resultMessage .= "用户组: " . memberInfo["MembershipType"] . "`n"
            resultMessage .= "用户级别: " . memberInfo["UserLevel"] . "`n"
            resultMessage .= "有效期至: " . formattedExpiryDate
            MsgBox(resultMessage, "用户组查询结果", "IconI")
            AddLog("哈希值 '" . inputHash . "' 的用户组信息查询成功。", "Green")
        } else {
            resultMessage .= "未找到匹配的用户组信息或已过期。"
            MsgBox(resultMessage, "用户组查询结果", "IconW")
            AddLog("哈希值 '" . inputHash . "' 未找到匹配的用户组信息或已过期。", "MAROON")
        }
    } catch as e {
        MsgBox("检查用户组失败: " . e.Message, "错误", "IconX")
        AddLog("检查用户组失败: " . e.Message, "Red")
    }
}
;endregion 身份辅助函数
;region GUI辅助函数
;tag 保存并重启
SaveAndRestart(*) {
    WriteSettings() ; 保存设置到文件
    AddLog("设置已保存，正在重启 DoroHelper……")
    Reload() ; 重启脚本
}
;tag 全选任务列表
CheckAllTasks(*) {
    for cb in g_taskListCheckboxes {
        cb.Value := 1 ; 视觉上勾选
        g_settings[cb.settingKey] := 1 ; 同步数据
    }
}
;tag 全不选任务列表
UncheckAllTasks(*) {
    for cb in g_taskListCheckboxes {
        cb.Value := 0 ; 视觉上取消勾选
        g_settings[cb.settingKey] := 0 ; 同步数据
    }
}
;tag 展示MirrorCDK输入框
ShowMirror(Ctrl, Info) {
    ; 正确的写法是获取控件的 .Value 属性（或 .Text 属性）
    g_numeric_settings["DownloadSource"] := cbDownloadSource.Text
    if Ctrl.Value = 2 {
        MirrorText.Visible := true
        MirrorEditControl.Visible := true
    } else {
        MirrorText.Visible := false
        MirrorEditControl.Visible := false
    }
}
;tag 隐藏所有二级设置
HideAllSettings() {
    global g_settingPages
    ; 遍历Map中的每一个页面（键值对）
    for pageName, controlsArray in g_settingPages {
        ; 遍历该页面的所有控件
        for control in controlsArray {
            control.Visible := false
        }
    }
}
;tag 展示二级设置页面
ShowSetting(pageName) {
    global g_settingPages
    ; 步骤1: 先隐藏所有设置页面的控件
    HideAllSettings()
    ; 步骤2: 再显示指定页面的控件
    if g_settingPages.Has(pageName) {
        targetControls := g_settingPages[pageName]
        for control in targetControls {
            control.Visible := true
        }
    } else {
        AddLog("错误：尝试显示的设置页面 '" . pageName . "' 未定义")
    }
}
;endregion GUI辅助函数
;region 消息辅助函数
;tag 活动结束提醒
CheckEvent(*) {
    MyFileShortHash := SubStr(A_Now, 1, 8)
    if MyFileShortHash = "20251021" {
        MsgBox "REBORN EVIL活动将在今天结束，请尽快完成活动！记得捡垃圾、搬空商店！"
    }
    if MyFileShortHash = "20251015" {
        MsgBox "单人突击将在今天结束，请没凹的尽快凹分！"
    }
    if MyFileShortHash = "20250903" {
        MsgBox "小活动ABSOLUTE将在今天结束，请尽快搬空商店！"
    }
}
;tag 获取系统区域设置
GetUserLocaleName() {
    MaxLen := 85
    BufferSize := MaxLen * 2
    LocaleBuffer := Buffer(BufferSize, 0)
    Result := DllCall("Kernel32\GetUserDefaultLocaleName", "Ptr", LocaleBuffer, "UInt", MaxLen, "UInt")
    if (Result == 0) {
        return ""
    }
    LocaleName := StrGet(LocaleBuffer, "UTF-16")
    return LocaleName
}
;tag 赞助界面
MsgSponsor(*) {
    global guiTier, guiDuration, guiSponsor, guiPriceText, guiCurrentMembership, guiCurrentExpiry
    global g_PriceMap, g_DefaultRegionPriceData, g_MembershipLevels, LocaleName
    guiSponsor := Gui("+Resize +Owner" doroGui.Hwnd, "赞助") ; 添加 +Owner 指定所属窗口
    guiSponsor.Opt("+DPIScale") ; 确保赞助窗口也支持 DPI 缩放
    guiSponsor.Tips := GuiCtrlTips(guiSponsor)
    guiSponsor.Tips.SetBkColor(0xFFFFFF)
    guiSponsor.Tips.SetTxColor(0x000000)
    guiSponsor.Tips.SetMargins(3, 3, 3, 3)
    guiSponsor.Tips.SetDelayTime("AUTOPOP", 10000)
    guiSponsor.SetFont('s10', 'Microsoft YaHei UI')
    Text1 := guiSponsor.Add("Text", "w400 +0x0100 Wrap", "现在 DoroHelper 的绝大部分维护和新功能的添加都是我在做，这耗费了我大量时间和精力，希望有条件的小伙伴们能支持一下")
    guiSponsor.Tips.SetTip(Text1, "Currently, I am the primary contributor to DoroHelper, handling most of the maintenance and new feature development. `nThis demands a significant amount of my time and energy. `nIf you find it valuable and are in a position to help, your support would be greatly appreciated.")
    Text2 := guiSponsor.Add("Text", "xm w400 +0x0100 Wrap", "赞助信息与当前设备绑定。需要注意的是，赞助并不构成实际上的商业行为，如果遇到不可抗力因素，本人有权随时停止维护，最终解释权归本人所有")
    guiSponsor.Tips.SetTip(Text2, "Sponsorship information is tied to the current device. `nPlease note that sponsorship does not constitute a commercial transaction. `nIn the event of unforeseen circumstances, I reserve the right to discontinue maintenance at any time. `nThe final interpretation rights belong to me.")
    ; ========================= 显示当前会员信息 =========================
    ; 显式地给变量赋默认初始值，消除静态分析器警告
    currentType := "普通用户", currentExpDate := "19991231"
    userGroupInfo := CheckUserGroup() ; 获取当前用户会员信息 (使用缓存，更快)
    ; 确保变量被赋值为从 CheckUserGroup 获取的实际值
    currentType := userGroupInfo["MembershipType"]
    currentExpDate := userGroupInfo["ExpirationTime"]
    currentExpDateFormatted := "N/A"
    ; 如果当前会员组不是普通用户且未过期
    if (userGroupInfo["UserLevel"] > 0 && A_Now < currentExpDate . "235959") {
        currentExpDateFormatted := SubStr(currentExpDate, 1, 4) . "-" . SubStr(currentExpDate, 5, 2) . "-" . SubStr(currentExpDate, 7, 2)
    } else if (userGroupInfo["UserLevel"] > 0 && A_Now >= currentExpDate . "235959") {
        currentType := "普通用户(已过期)" ; 确保显示过期状态，这会更新到 guiCurrentMembership
    }
    LVZH := guiSponsor.Add("ListView", "xm w400 h180", ["　　　　　　　　", "普通用户", "铜 Doro", "银 Doro", "金 Doro"])
    LVZH.Add(, "每月价格", "免费", "1欧润吉", "3欧润吉", "5欧润吉")
    LVZH.Add(, "大部分功能", "✅️", "✅️", "✅️", "✅️")
    LVZH.Add(, "移除广告提示", "", "✅️", "✅️", "✅️")
    LVZH.Add(, "轮换活动", "", "", "✅️", "✅️")
    LVZH.Add(, "路径和定时启动", "", "", "", "✅️")
    LVZH.Add(, "自动推图", "", "", "", "✅️")
    LVZH.Add(, "其他最新功能", "", "", "", "✅️")
    Text3 := guiSponsor.Add("Text", "xm w400 +0x0100 Wrap", "总结：铜Doro免除广告、银Doro能做活动、金Doro能用全部功能")
    guiSponsor.Tips.SetTip(Text3, "Summary: `nCopper Doro removes ads and the price is 1 ORANGE per month.`nSilver Doro enables event features and the price is 3 ORANGE per month.`nGold Doro unlocks all functionalities and the price is 5 ORANGE per month.")
    ; ahk版
    if (scriptExtension = "ahk") {
        picUrl1 := "img\weixin.png"
        picUrl2 := "img\alipay.png"
        tempFile1 := picUrl1
        tempFile2 := picUrl2
    }
    ; exe版
    else {
        picUrl1 := "https://s1.imagehub.cc/images/2025/09/12/c3fd38a9b6ae2e677b4e2f411ebc49a8.jpg"
        picUrl2 := "https://s1.imagehub.cc/images/2025/09/12/f69df12697d7bb2a98ef61108e46e787.jpg"
        tempFile1 := A_Temp . "\weixin.jpg"
        tempFile2 := A_Temp . "\alipay.jpg"
        ; 仅在文件不存在时下载，避免重复操作
        if (!FileExist(tempFile1)) {
            try {
                Download picUrl1, tempFile1
            } catch as e {
                AddLog("下载微信支付二维码失败: " . e.Message, "Red")
            }
        }
        if (!FileExist(tempFile2)) {
            try {
                Download picUrl2, tempFile2
            } catch as e {
                AddLog("下载支付宝支付二维码失败: " . e.Message, "Red")
            }
        }
    }
    try {
        pic_ctr_1 := guiSponsor.Add("Picture", "x10 w200 h200", tempFile1)
        pic_ctr_2 := guiSponsor.Add("Picture", "yp w200 h200", tempFile2)
        guiSponsor.Tips.SetTip(pic_ctr_1, "微信/WeChat") ; 为图片添加 tooltip
        guiSponsor.Tips.SetTip(pic_ctr_2, "支付宝/Alipay") ; 为图片添加 tooltip
    }
    catch {
        guiSponsor.Add("Text", "w400 h200 Center", "无法加载赞助图片，请检查本地文件或网络连接。")
    }
    btn1 := guiSponsor.Add("Button", "xm+120", "我无法使用以上支付方式")
    guiSponsor.Tips.SetTip(btn1, "I am unable to use the above payment methods")
    btn1.OnEvent("Click", (*) => Run("https://github.com/1204244136/DoroHelper?tab=readme-ov-file#%E6%94%AF%E6%8C%81%E5%92%8C%E9%BC%93%E5%8A%B1"))
    guiCurrentMembership := guiSponsor.Add("Text", "xm+130 y+10  +0x0100", "您当前的会员组：" . currentType)
    guiCurrentExpiry := guiSponsor.Add("Text", "xm+130 y+5  +0x0100", "有效期至：" . currentExpDateFormatted)
    ; 从 g_MembershipLevels 获取可选择的会员类型，排除 "普通用户" 和 "管理员"
    availableTiers := []
    for tierName, levelInfo in g_MembershipLevels {
        if (tierName != "普通用户" && tierName != "管理员") {
            availableTiers.Push(tierName)
        }
    }
    ; ; 手动添加管理员选项，设为特殊情况（测试用）
    ; availableTiers.Push("管理员") ; <-- 注释掉这行以移除管理员选项
    ; 添加 Choose1 确保默认选中第一个
    guiTier := guiSponsor.Add("DropDownList", "Choose1 x125 w100", availableTiers)
    guiSponsor.Tips.SetTip(guiTier, "铜:Copper|银:Silver|金:Gold")
    guiDuration := guiSponsor.Add("DropDownList", "x+10 yp Choose1 w80", ["1个月", "3个月", "6个月", "12个月", "36个月"])
    guiSponsor.Tips.SetTip(guiDuration, "月: Month")
    ; 确定当地货币单位和符号
    PriceData := g_PriceMap.Get(LocaleName, g_DefaultRegionPriceData)
    unitPrice := PriceData.Unitprice
    currency := PriceData.Currency
    text5 := guiSponsor.Add("Text", "xm+90 r1 +0x0100", "您所在的地区 " . LocaleName . " 欧润吉单价为：" . unitPrice . " " . currency)
    guiSponsor.Tips.SetTip(text5, "Your current region is: " . LocaleName . ". The unit price of ORANGE is: " . unitPrice . " " . currency)
    ; 修改价格显示 Text 控件，使其能显示更多信息
    guiPriceText := guiSponsor.Add("Text", "xm+70 w300 h60 Center +0x0100", "计算中……")
    guiSponsor.Tips.SetTip(guiPriceText, "您将支付的金额以及计算详情。")
    btn2 := guiSponsor.Add("Button", "xm+135 h30 +0x0100", "  我已赞助，生成信息")
    guiSponsor.Tips.SetTip(btn2, "I have sponsored, generate information")
    ; 确保回调函数正确绑定
    guiTier.OnEvent("Change", (Ctrl, Info) => UpdateSponsorPrice(userGroupInfo))
    guiDuration.OnEvent("Change", (Ctrl, Info) => UpdateSponsorPrice(userGroupInfo))
    btn2.OnEvent("Click", CalculateSponsorInfo) ; 放在所有OnEvent之后绑定
    ; 初始化价格显示
    UpdateSponsorPrice(userGroupInfo)
    guiSponsor.Show("Center")
}
;tag 根据选择更新价格显示
UpdateSponsorPrice(userGroupInfo_param := unset) { ; <-- 接受 userGroupInfo 参数
    global guiTier, guiDuration, guiPriceText, guiCurrentMembership, guiCurrentExpiry
    global g_MembershipLevels, g_PriceMap, LocaleName
    global g_numeric_settings ; 需要访问 UserLevel
    ; 如果赞助 GUI 控件还未完全初始化，则提前退出
    if (!IsObject(guiPriceText) || !guiPriceText.Hwnd || !IsObject(guiTier) || !guiTier.Hwnd || !IsObject(guiDuration) || !guiDuration.Hwnd) {
        return
    }
    ; 获取当前选中的赞助选项
    tierSelected := guiTier.Text
    durationSelected := guiDuration.Text
    if (tierSelected = "" || durationSelected = "") {
        guiPriceText.Text := "请选择会员类型和时长"
        return
    }
    ; 获取当前区域的单价和货币名称
    priceData := g_PriceMap.Get(LocaleName, g_DefaultRegionPriceData)
    unitPrice := priceData.Unitprice
    currencyName := priceData.Currency
    ; 检查是否传入了 userGroupInfo_param，如果传入则使用，否则调用 CheckUserGroup()
    if (IsObject(userGroupInfo_param)) {
        userGroupInfo := userGroupInfo_param
    } else {
        ; 理论上 MsgSponsor 应该已经传入了，这里是备用，避免重复在线检查
        userGroupInfo := CheckUserGroup()
    }
    currentType := userGroupInfo["MembershipType"]
    currentExpDate := userGroupInfo["ExpirationTime"] ; YYYYMMDD格式
    currentLevel := userGroupInfo["UserLevel"]
    ; 更新赞助界面顶部的当前会员信息 (为了实时性)
    currentExpDateFormatted := "N/A"
    if (currentLevel > 0 && A_Now < currentExpDate . "235959") {
        currentExpDateFormatted := SubStr(currentExpDate, 1, 4) . "-" . SubStr(currentExpDate, 5, 2) . "-" . SubStr(currentExpDate, 7, 2)
        guiCurrentMembership.Text := "您当前的会员组：" . currentType
    } else if (currentLevel > 0 && A_Now >= currentExpDate . "235959") {
        ; 用户是会员但已过期
        currentType := "普通用户(已过期)" ; 确保后续逻辑中处理为普通用户状态
        currentLevel := 0 ; 过期则视为普通用户
        guiCurrentMembership.Text := "您当前的会员组：" . "普通用户 (已过期)"
    } else {
        ; 普通用户
        guiCurrentMembership.Text := "您当前的会员组：" . currentType
    }
    guiCurrentExpiry.Text := "有效期至：" . currentExpDateFormatted
    ; 1. 计算目标会员的总月数和每月成本
    targetMonthsText := StrReplace(durationSelected, "个月")
    if (!IsNumber(targetMonthsText)) {
        guiPriceText.Text := "错误：无效的赞助时长。"
        return
    }
    targetMonths := Integer(targetMonthsText)
    targetMonthlyCost := 0
    targetUserLevel := 0
    targetLevelInfo := g_MembershipLevels.Get(tierSelected)
    if (!IsObject(targetLevelInfo)) {
        ; 如果 tierSelected 是 "管理员" (虽然现在已移除选项，但以防万一) 或其他未定义类型
        if (tierSelected == "管理员") {
            targetMonthlyCost := 999 ; 管理员的特殊价格
            targetUserLevel := 10
            ; 创建一个临时的 Map 对象，以便后续逻辑可以安全访问
            targetLevelInfo := Map("monthlyCost", targetMonthlyCost, "userLevel", targetUserLevel)
        } else {
            guiPriceText.Text := "错误：无效的会员类型数据。"
            AddLog("错误: 在 UpdateSponsorPrice 中，tierSelected '" . tierSelected . "' 未在 g_MembershipLevels 中找到。", "Red")
            return
        }
    }
    ; 确保 targetLevelInfo 此时是一个有效的 Map 对象
    targetMonthlyCost := targetLevelInfo.monthlyCost
    targetUserLevel := targetLevelInfo.userLevel
    fullValueForTarget := targetMonthlyCost * unitPrice * targetMonths ; 没有任何减免的理论全价
    ; 2. 计算当前会员的剩余价值 (如果存在且未过期)
    remainingValue := 0
    if (currentLevel > 0 && currentExpDate . "235959" > A_Now) {
        remainingValue := CalculateUserMembershipDollars(currentType, currentExpDate, unitPrice)
    }
    displayMessage := ""
    if (currentLevel == targetUserLevel) {
        ; 购买类型与当前相同 (续费或普通用户新购同类型)
        formattedPrice := Format("{:0.2f}", fullValueForTarget) . " " . currencyName
        if (currentLevel > 0) {
            displayMessage := "您当前是 " . currentType . "`n"
                . "选择续费 " . tierSelected . " " . targetMonths . "个月`n"
                . "总计需支付：" . formattedPrice
        } else {
            displayMessage := "您当前是普通用户`n"
                . "选择开通 " . tierSelected . " " . targetMonths . "个月`n"
                . "总计需支付：" . formattedPrice
        }
    } else if (currentLevel < targetUserLevel) {
        ; 升级场景
        upgradePrice := fullValueForTarget - remainingValue
        if (upgradePrice > 0) {
            ; 需要补差价
            formattedUpgradePrice := Format("{:0.2f}", upgradePrice) . " " . currencyName
            formattedRemainingValue := Format("{:0.2f}", remainingValue) . " " . currencyName
            displayMessage := "您当前是 " . currentType . " (剩余价值 " . formattedRemainingValue . ")`n"
                . "选择升级到 " . tierSelected . " " . targetMonths . "个月`n"
                . "扣除当前剩余价值后，您需支付：" . formattedUpgradePrice
        } else {
            ; 虽然是升级，但由于剩余价值较高，无需补差价甚至为负数
            ; 按照你说的逻辑，这里会显示目标会员的全额价格，并给出提示
            formattedFullPrice := Format("{:0.2f}", fullValueForTarget) . " " . currencyName
            formattedRemainingValue := Format("{:0.2f}", remainingValue) . " " . currencyName
            displayMessage := "您当前是 " . currentType . " (剩余价值 " . formattedRemainingValue . ")`n"
                . "选择升级到 " . tierSelected . " " . targetMonths . "个月`n"
                . "您的剩余价值已足以覆盖升级，但系统暂不支持完全抵扣，`n"
                . "建议支付全额作为新开通费用：" . formattedFullPrice
        }
    } else {
        ; 降级场景 (用户选择的会员类型低于当前类型)
        displayMessage := "无法降级：您当前是 " . currentType . "，`n请选择与当前会员组一致或更高级别的会员组。"
    }
    guiPriceText.Text := displayMessage
}
;tag 计算并生成赞助信息
CalculateSponsorInfo(thisGuiButton, info) {
    global guiTier, guiDuration, guiSponsor ; guiPriceText now read-only for final display
    global g_MembershipLevels, g_PriceMap, LocaleName
    mainBoardSerial := GetMainBoardSerial()
    cpuSerial := GetCpuSerial()
    diskSerial := GetDiskSerial()
    Hashed := HashSHA256(mainBoardSerial . cpuSerial . diskSerial)
    tierSelected := guiTier.Text
    durationSelected := guiDuration.Text
    if (tierSelected == "管理员") {
        MsgBox("管理员等级不能通过此方式赞助。", "赞助无效") ; 恢复无图标
        return
    }
    targetMonthsText := StrReplace(durationSelected, "个月")
    if (!IsNumber(targetMonthsText)) {
        MsgBox("请选择有效的赞助时长。", "赞助信息错误") ; 恢复无图标
        return
    }
    targetMonths := Integer(targetMonthsText)
    currentUserInfo := CheckUserGroup(true)
    currentMembershipType := currentUserInfo["MembershipType"]
    currentExpiryDate := currentUserInfo["ExpirationTime"] ; YYYYMMDD
    currentLevel := currentUserInfo["UserLevel"]
    targetLevelInfo := g_MembershipLevels.Get(tierSelected)
    if (!IsObject(targetLevelInfo)) {
        ; 如果 tierSelected 是 "管理员" (虽然现在已移除选项，但以防万一) 或其他未定义类型
        if (tierSelected == "管理员") {
            ; 为管理员创建一个临时的 Map 对象，以便后续逻辑可以安全访问
            targetLevelInfo := Map("monthlyCost", 999, "userLevel", 10)
        } else {
            MsgBox("错误：无效的会员类型数据。", "赞助信息错误")
            AddLog("错误: 在 CalculateSponsorInfo 中，tierSelected '" . tierSelected . "' 未在 g_MembershipLevels 中找到。", "Red")
            return
        }
    }
    targetUserLevel := targetLevelInfo.userLevel
    newExpiryDateTimestamp := "" ; Ahk时间戳格式 YYYYMMDDHHmmss
    UserStatus := ""
    ; 确保当前选择不是降级，因为UpdateSponsorPrice应该已经拦截了
    if (currentLevel > targetUserLevel && targetMonths > 0) { ; 如果用户尝试生成降级信息
        MsgBox("您不能将您的会员组从 " . currentMembershipType . " 降级到 " . tierSelected . "。", "赞助无效") ; 恢复无图标
        return
    }
    ; 根据当前用户状态和目标选择决定到期日和 UserStatus
    if (currentLevel == targetUserLevel) {
        ; 续费或普通用户新购同类型
        ; 检查是否为普通用户或已过期，如果不是，则视为续费
        if (currentLevel == 0 || A_Now >= currentExpiryDate . "235959") {
            UserStatus := "新用户开通"
            newExpiryDateTimestamp := DateAdd(A_Now, 30 * targetMonths, "days")
        } else {
            UserStatus := "老用户续费"
            newExpiryDateTimestamp := DateAdd(currentExpiryDate . "235959", 30 * targetMonths, "days")
        }
    } else if (currentLevel < targetUserLevel) {
        ; 升级
        UserStatus := "用户组升级"
        ; 升级的到期时间从当前开始计算
        newExpiryDateTimestamp := DateAdd(A_Now, 30 * targetMonths, "days")
    } else {
        ; 不正常情况 (降级且未被前端拦截), 理论上不应发生
        MsgBox("发生意外错误：不允许降级。", "错误") ; 恢复无图标
        return
    }
    ; 确保 JSON 中的日期依然是 YYYYMMDD 格式
    finalExpiryDate := SubStr(newExpiryDateTimestamp, 1, 8)
    jsonString := UserStatus "`n"
    jsonString .= "(请将这段文字替换成您的付款截图，邮件的图片请以附件形式发送)`n"
    jsonString .= "  {" . "`n"
    jsonString .= "    `"hash`": `"" Hashed "`"," . "`n"
    jsonString .= "`"tier`": `"" tierSelected "`"," . "`n"
    jsonString .= "`"expiry_date`": `"" finalExpiryDate "`"" . "`n"
    jsonString .= "},"
    A_Clipboard := jsonString
    newExpiryDateFormatted := SubStr(finalExpiryDate, 1, 4) . "-" . SubStr(finalExpiryDate, 5, 2) . "-" . SubStr(finalExpiryDate, 7, 2)
    MsgBox("赞助信息已生成并复制到剪贴板，请将其连同付款记录发给我`n"
        . "状态: " . UserStatus . "`n"
        . "您将获得的会员类型: " . tierSelected . "`n"
        . "新会员到期日: " . newExpiryDateFormatted . "`n`n"
        . "请将此剪贴板中的内容与付款截图私发给我，我将在24小时内为您登记`n"
        . "QQ群: 584275905`n"
        . "QQ邮箱: 1204244136@qq.com`n"
        . "海外邮箱: zhi.11@foxmail.com"
        , "赞助信息已复制！") ; 恢复无图标
    guiSponsor.Destroy() ; 赞助信息生成后关闭赞助GUI
}
;tag 帮助
ClickOnHelp(*) {
    MyHelp := Gui(, "帮助")
    MyHelp.SetFont('s10', 'Microsoft YaHei UI')
    MyHelp.Add("Text", "w600", "- 如有问题请先尝试将更新渠道切换至AHK版并进行更新（需要优质网络）。如果无法更新或仍有问题请加入反馈qq群584275905，反馈必须附带日志和录屏")
    MyHelp.Add("Text", "w600", "- 使用前请先完成所有特殊任务（例如珍藏品任务），以防图标错位")
    MyHelp.Add("Text", "w600", "- 游戏分辨率需要设置成**16:9**的分辨率，小于1080p可能有问题，暂不打算特殊支持")
    MyHelp.Add("Text", "w600", "- 由于使用的是图像识别，请确保游戏画面完整在屏幕内，且**游戏画面没有任何遮挡**")
    MyHelp.Add("Text", "w600", "- 多显示器请支持的显示器作为主显示器，将游戏放在主显示器内")
    MyHelp.Add("Text", "w600", "- 未激活正版Windows会有水印提醒，请激活正版Windows")
    MyHelp.Add("Text", "w600", "- 不要使用微星小飞机、游戏加加等悬浮显示数据的软件")
    MyHelp.Add("Text", "w600", "- 游戏帧数建议保持60，帧数过低时，部分场景的行动可能会被吞，导致问题")
    MyHelp.Add("Text", "w600", "- 如遇到识别问题，请尝试关闭会改变画面颜色相关的功能或设置，例如")
    MyHelp.Add("Text", "w600", "- 软件层面：各种驱动的色彩滤镜，部分笔记本的真彩模式")
    MyHelp.Add("Text", "w600", "- 设备层面：显示器的护眼模式、色彩模式、色温调节、HDR等")
    MyHelp.Add("Text", "w600", "- 游戏语言设置为**简体中文**，设定-画质-开启光晕效果，设定-画质-开启颜色分级，不要使用太亮的大厅背景")
    MyHelp.Add("Text", "w600", "- 反馈任何问题前，请先尝试复现，如能复现再进行反馈，反馈时必须有录屏和全部日志")
    MyHelp.Add("Text", "w600", "- 鼠标悬浮在控件上会有对应的提示和详细信息，请勾选或点击前仔细阅读！")
    MyHelp.Add("Text", "w600", "- ctrl+1关闭程序、ctrl+2暂停程序、ctrl+3~7调整游戏大小")
    MyHelp.Add("Text", "w600", "- 如果遇到启动了但毫无反应的情况，请检查杀毒软件(如360、火绒等)是否拦截了DoroHelper的运行，请将其添加信任")
    MyHelp.Add("Text", "w600", "- 如果遇到ACE安全中心提示，请尝试卸载wegame")
    AddCheckboxSetting(MyHelp, "CloseHelp", "我已认真阅读以上内容，并保证出现问题反馈前会再次检查，现在我想让这个弹窗不再主动显示", "")
    MyHelp.Show()
}
;tag 广告
Advertisement() {
    adTitle := "AD"
    MyAd := Gui(, adTitle)
    MyAd.SetFont('s10', 'Microsoft YaHei UI')
    MyAd.Add("Text", "w300", "====广告位招租====")
    MyAd.Add("Text", , "可以通过赞助免除启动时的广告，设置-移除启动广告")
    MyAd.Add("Text", , "详情见左上角的「赞助」按钮")
    MyAd.Add("Link", , '<a href="https://pan.baidu.com/s/1pAq-o6fKqUPkRcgj_xVcdA?pwd=2d1q">ahk版和exe版的网盘下载链接</a>')
    MyAd.Add("Link", , '<a href="https://nikke.hayasa.link/">====Nikke CDK Tool====</a>')
    MyAd.Add("Text", "w500", "一个用于管理《胜利女神：NIKKE》CDK 的现代化工具网站，支持支持国际服、国服、港澳台服多服务器、多账号的CDK一键兑换")
    MyAd.Add("Link", , '<a href="https://mirrorchyan.com/">===Mirror酱===</a>')
    MyAd.Add("Text", "w500", "Mirror酱是一个第三方应用分发平台，可以让你更方便地下载和更新应用现已支持 DoroHelper 的自动更新下载，和DoroHelper本身的会员功能无关")
    MyAd.Show()
    Sleep 500
    if not WinExist(adTitle) {
        MsgBox("警告：广告窗口已被拦截或阻止！请关闭您的广告拦截软件，以确保程序正常运行", "警告")
        ExitApp
    }
}
;tag 复制日志
CopyLog(*) {
    A_Clipboard := LogBox.GetText()
    ; 给出提示
    MsgBox("日志内容已复制到剪贴板，请将其连同录屏发到群里")
}
;endregion 消息辅助函数
;region 数据辅助函数
;tag 写入数据
WriteSettings(*) {
    ; 写入当前坐标
    try {
        WinGetPos(&x, &y, &w, &h)
        g_numeric_settings["doroGuiX"] := x
        g_numeric_settings["doroGuiY"] := y
    }
    ;从 g_settings Map 写入开关设置
    for key, value in g_settings {
        IniWrite(value, "settings.ini", "Toggles", key)
    }
    for key, value in g_numeric_settings {
        IniWrite(value, "settings.ini", "NumericSettings", key)
    }
}
;tag 读出数据
LoadSettings() {
    default_settings := g_settings.Clone()
    ;从 Map 加载开关设置
    for key, defaultValue in default_settings {
        readValue := IniRead("settings.ini", "Toggles", key, defaultValue)
        g_settings[key] := readValue
    }
    default_numeric_settings := g_numeric_settings.Clone()
    for key, defaultValue in default_numeric_settings {
        ; 读取并赋值到 g_numeric_settings Map
        readValue := IniRead("settings.ini", "NumericSettings", key, defaultValue)
        g_numeric_settings[key] := readValue
    }
    if (g_numeric_settings["UserLevel"] > 0) {
        AddLog("从本地设置加载用户组: " . g_numeric_settings["UserGroup"] . " (级别: " . g_numeric_settings["UserLevel"] . ")", "Blue")
    }
}
;tag 保存数据
SaveSettings(*) {
    WriteSettings()
    MsgBox "设置已保存！"
}
IsCheckedToString(foo) {
    if foo
        return "Checked"
    else
        return ""
}
/**
 * 添加一个与 g_settings Map 关联的复选框到指定的 GUI 对象.
 * @param guiObj Gui - 要添加控件的 GUI 对象.
 * @param settingKey String - 在 g_settings Map 中对应的键名.
 * @param displayText String - 复选框旁边显示的文本标签.
 * @param options String - (可选) AutoHotkey GUI 布局选项字符串 (例如 "R1 xs+15").
 * @param addToTaskList Boolean - (可选) 如果为 true, 则将此复选框添加到全局任务列表数组中.
 */
AddCheckboxSetting(guiObj, settingKey, displayText, options := "", addToTaskList := false) {
    global g_settings, g_taskListCheckboxes
    ;检查 settingKey 是否存在于 g_settings 中
    if !g_settings.Has(settingKey) {
        MsgBox("错误: Setting key '" settingKey "' 在 g_settings 中未定义!", "添加控件错误", "IconX")
        return
    }
    ;构建选项字符串，确保 Checked/空字符串 在选项之后，文本之前
    initialState := IsCheckedToString(g_settings[settingKey])
    fullOptions := options (options ? " " : "") initialState
    ;添加复选框控件，并将 displayText 作为第三个参数
    cbCtrl := guiObj.Add("Checkbox", fullOptions, displayText)
    ;给控件附加 settingKey，方便后面识别，并保存 displayText
    cbCtrl.settingKey := settingKey
    cbCtrl.displayText := displayText
    ;绑定 Click 事件，使用胖箭头函数捕获当前的 settingKey 和 displayText
    cbCtrl.OnEvent("Click", (guiCtrl, eventInfo) => ToggleSetting(settingKey, guiCtrl.displayText, guiCtrl))
    ;如果指定，则添加到任务列表数组
    if (addToTaskList) {
        g_taskListCheckboxes.Push(cbCtrl)
    }
    ;返回创建的控件对象 (可选，如果需要进一步操作)
    return cbCtrl
}
;通用函数，用于切换 g_settings Map 中的设置值，并进行会员等级检测
ToggleSetting(settingKey, displayText, guiCtrl, *) {
    global g_settings, g_numeric_settings
    ; 如果用户正在尝试勾选本选项 (即当前复选框的值将从0变为1)
    if (guiCtrl.Value == 0) {
        requiredLevel := 0
        memberType := ""
        ; 检查 displayText 是否包含会员等级信息
        if InStr(displayText, "[金Doro]") {
            requiredLevel := 3
            memberType := "金Doro会员"
        } else if InStr(displayText, "[银Doro]") {
            requiredLevel := 2
            memberType := "银Doro会员"
        } else if InStr(displayText, "[铜Doro]") {
            requiredLevel := 1
            memberType := "铜Doro会员"
        }
        ; 如果检测到会员限制
        if (requiredLevel > 0) {
            ; 检查当前用户等级是否足够
            if (g_numeric_settings["UserLevel"] < requiredLevel) {
                MsgBox("当前用户组 (" . g_numeric_settings["UserGroup"] . ") 不足，需要 " . memberType . " 才能使用此功能。请点击左上角的“赞助”按钮升级会员组。", "会员功能限制", "")
                ; 阻止勾选操作：在 Click 事件中，如果返回0或不修改控件值，将阻止状态改变
                ; 但AutoHotkey GUI的Checkbox控件在Click事件中已经改变了值，所以需要手动改回去
                guiCtrl.Value := 0
                g_settings[settingKey] := 0
                AddLog("用户尝试勾选限制功能 '" . displayText . "' 失败，等级不足。", "Red")
                WriteSettings()
                return
            }
        }
    }
    ; 如果通过了会员检测 (或没有会员限制)，则正常切换值
    g_settings[settingKey] := 1 - g_settings[settingKey]
    ; 每次勾选后都保存数据
    WriteSettings()
    ;可选: 如果需要，可以在这里添加日志记录
    ; AddLog("切换 " settingKey . " 为 " . g_settings[settingKey])
}
;endregion 数据辅助函数
;region 坐标辅助函数
;tag 点击
UserClick(sX, sY, k) {
    uX := Round(sX * k) ;计算转换后的坐标
    uY := Round(sY * k)
    CoordMode "Mouse", "Client"
    Send "{Click " uX " " uY "}" ;点击转换后的坐标
}
;tag 按住
UserPress(sX, sY, k) {
    uX := Round(sX * k) ;计算转换后的坐标
    uY := Round(sY * k)
    CoordMode "Mouse", "Client"
    Send "{Click " uX " " uY " " 0 "}" ;点击转换后的坐标
    Send "Click " "Down" "}"
}
;tag 移动
UserMove(sX, sY, k) {
    uX := Round(sX * k) ;计算转换后的坐标
    uY := Round(sY * k)
    CoordMode "Mouse", "Client"
    Send "{Click " uX " " uY " " 0 "}" ;点击转换后的坐标
}
;tag 颜色判断
IsSimilarColor(targetColor, color) {
    tr := Format("{:d}", "0x" . substr(targetColor, 3, 2))
    tg := Format("{:d}", "0x" . substr(targetColor, 5, 2))
    tb := Format("{:d}", "0x" . substr(targetColor, 7, 2))
    pr := Format("{:d}", "0x" . substr(color, 3, 2))
    pg := Format("{:d}", "0x" . substr(color, 5, 2))
    pb := Format("{:d}", "0x" . substr(color, 7, 2))
    distance := sqrt((tr - pr) ** 2 + (tg - pg) ** 2 + (tb - pb) ** 2)
    if (distance < 15)
        return true
    return false
}
;tag 颜色
UserCheckColor(sX, sY, sC, k) {
    loop sX.Length {
        uX := Round(sX[A_Index] * k)
        uY := Round(sY[A_Index] * k)
        uC := PixelGetColor(uX, uY)
        if (!IsSimilarColor(uC, sC[A_Index]))
            return 0
    }
    return 1
}
;tag 画面调整
AdjustSize(TargetX, TargetY) {
    Initialization()
    WinGetPos(&X, &Y, &Width, &Height, nikkeID)
    WinGetClientPos(&ClientX, &ClientY, &ClientWidth, &ClientHeight, nikkeID)
    ; 计算非工作区（标题栏和边框）的高度和宽度
    NonClientHeight := Height - ClientHeight
    NonClientWidth := Width - ClientWidth
    NewClientX := (A_ScreenWidth / 2) - (NikkeWP / 2)
    NewClientY := (A_ScreenHeight / 2) - (NikkeHP / 2)
    NewClientWidth := TargetX
    NewClientHeight := TargetY
    ; 计算新的窗口整体大小，以适应新的工作区大小
    NewWindowX := NewClientX
    NewWindowY := NewClientY
    NewWindowWidth := NewClientWidth + NonClientWidth
    NewWindowHeight := NewClientHeight + NonClientHeight
    ; 使用 WinMove 移动和调整窗口大小
    WinMove 0, 0, NewWindowWidth, NewWindowHeight, nikkeID
}
;endregion 坐标辅助函数
;region 日志辅助函数
;tag 添加日志
AddLog(text, color := "black") {
    ; 静态变量用于存储在 LogBox 控件创建之前的日志
    static logBuffer := []
    ; 静态变量指示 LogBox 是否已准备好
    static logBoxReady := false
    ; 检查 LogBox 是否已创建并准备好
    ; 使用 IsSet() 优先检查，避免对 unset 变量调用 IsObject() 报错
    ; 并且确保 LogBox.Hwnd 存在，表示控件已实际创建
    if (!logBoxReady && IsSet(LogBox) && IsObject(LogBox) && LogBox.Hwnd) {
        logBoxReady := true
        ; LogBox 刚刚准备好，现在可以清空缓冲并写入
        if (logBuffer.Length > 0) {
            for bufferedLog in logBuffer {
                AddLogToControl(bufferedLog.text, bufferedLog.color)
            }
            logBuffer := [] ; 清空缓冲
        }
    }
    ; 如果 LogBox 已经准备好，则直接写入当前日志
    if (logBoxReady) {
        AddLogToControl(text, color)
    } else {
        ; 如果 LogBox 尚未准备好，则将日志添加到缓冲
        logBuffer.Push({ text: text, color: color })
    }
}
; 辅助函数：实际将日志写入 RichEdit 控件
; 这个函数不应该直接被外部调用，只由 AddLog 调用
AddLogToControl(text, color) {
    ; 确保 LogBox 控件存在且有效
    ; 理论上，由于 logBoxReady 检查，这里 LogBox 应该总是有效的
    if (!IsObject(LogBox) || !LogBox.Hwnd) {
        ; 如果 LogBox 意外地变得无效，可以打印到控制台或简单返回
        ; FileAppend "Error: AddLogToControl called with invalid LogBox.`n", "*"
        return
    }
    ;静态变量保存上一条内容，这里应该在 AddLogToControl 内部，因为它是实际写入的函数
    static lastText := ""
    ;如果内容与上一条相同则跳过
    if (text = lastText)
        return
    lastText := text  ;保存当前内容供下次比较
    ; 将光标移到文本末尾
    LogBox.SetSel(-1, -1)
    ; 保存当前选择位置
    sel := LogBox.GetSel()
    start := sel.S
    ; 插入时间戳
    timestamp := FormatTime(, "HH:mm:ss")
    timestamp_text := timestamp "  "
    LogBox.ReplaceSel(timestamp_text)
    ; 设置时间戳为灰色
    sel_before := LogBox.GetSel()
    LogBox.SetSel(start, start + StrLen(timestamp_text))
    font_gray := {}
    font_gray.Color := "gray"
    LogBox.SetFont(font_gray)
    LogBox.SetSel(sel_before.S, sel_before.S) ; 恢复光标位置
    ; 保存时间戳后的位置
    text_start := sel_before.S
    ; 插入文本内容
    LogBox.ReplaceSel(text "`r`n")
    ; 计算文本内容的长度
    text_length := StrLen(text)
    ; 只选择文本内容部分（不包括时间戳）
    LogBox.SetSel(text_start, text_start + text_length)
    ; 使用库提供的 SetFont 方法设置文本颜色
    font := {}
    font.Color := color
    LogBox.SetFont(font)
    ; 设置悬挂缩进 - 使用段落格式
    PF2 := RichEdit.PARAFORMAT2()
    PF2.Mask := 0x05 ; PFM_STARTINDENT | PFM_OFFSET
    PF2.StartIndent := 0
    PF2.Offset := 940
    SendMessage(0x0447, 0, PF2.Ptr, LogBox.Hwnd) ; EM_SETPARAFORMAT
    ; 取消选择并将光标移到底部
    LogBox.SetSel(-1, -1)
    ; 自动滚动到底部
    LogBox.ScrollCaret()
}
;tag 日志的时间戳转换
TimeToSeconds(timeStr) {
    ;期望 "HH:mm:ss" 格式
    parts := StrSplit(timeStr, ":")
    if (parts.Length != 3) {
        return -1 ;格式错误
    }
    ;确保部分是数字
    if (!IsInteger(parts[1]) || !IsInteger(parts[2]) || !IsInteger(parts[3])) {
        return -1 ;格式错误
    }
    hours := parts[1] + 0 ;强制转换为数字
    minutes := parts[2] + 0
    seconds := parts[3] + 0
    ;简单的验证范围（不严格）
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59 || seconds < 0 || seconds > 59) {
        return -1 ;无效时间
    }
    return hours * 3600 + minutes * 60 + seconds
}
;tag 读取日志框内容 根据 HH:mm:ss 时间戳推算跨度，输出到日志框
CalculateAndShowSpan(ExitReason := "", ExitCode := "") {
    global outputText
    logContent := LogBox.GetText()
    ; 使用正则表达式提取所有时间戳
    timestamps := []
    pos := 1
    match := ""
    while (pos := RegExMatch(logContent, "(?<time>\d{2}:\d{2}:\d{2})\s{2,}", &match, pos)) {
        timestamps.Push(match["time"])
        pos += match.Len
    }
    ; 检查是否有足够的时间戳
    if (timestamps.Length < 2) {
        AddLog("推算跨度失败：需要至少两个时间戳")
        return
    }
    earliestTimeStr := timestamps[1]
    latestTimeStr := timestamps[timestamps.Length]
    earliestSeconds := TimeToSeconds(earliestTimeStr)
    latestSeconds := TimeToSeconds(latestTimeStr)
    if (earliestSeconds = -1 || latestSeconds = -1) {
        AddLog("推算跨度失败：日志时间格式错误")
        return
    }
    ; 计算时间差（正确处理跨天）
    spanSeconds := latestSeconds - earliestSeconds
    ; 如果差值为负，说明可能跨天了
    if (spanSeconds < 0) {
        spanSeconds += 24 * 3600  ; 加上一天的秒数
    }
    spanMinutes := Floor(spanSeconds / 60)
    remainingSeconds := Mod(spanSeconds, 60)
    outputText := "已帮你节省时间: "
    if (spanMinutes > 0) {
        outputText .= spanMinutes " 分 "
    }
    outputText .= remainingSeconds " 秒"
    AddLog(outputText)
    if (spanSeconds < 5) {
        MsgBox("没怎么运行就结束了，任务列表勾了吗？还是没有进行详细的任务设置呢？")
    }
}
;endregion 日志辅助函数
;region 流程辅助函数
;tag 点左下角的小房子的对应位置的右边（不返回）
Confirm() {
    UserClick(474, 2028, TrueRatio)
    Sleep 500
}
;tag 按Esc
GoBack() {
    if (ok := FindText(&X, &Y, NikkeX + 0.658 * NikkeW . " ", NikkeY + 0.639 * NikkeH . " ", NikkeX + 0.658 * NikkeW + 0.040 * NikkeW . " ", NikkeY + 0.639 * NikkeH + 0.066 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("方舟的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
        return
    }
    ; AddLog("返回")
    Send "{Esc}"
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.518 * NikkeW . " ", NikkeY + 0.609 * NikkeH . " ", NikkeX + 0.518 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.609 * NikkeH + 0.033 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
    }
    Send "{]}"
    Sleep 500
}
;tag 结算招募
Recruit() {
    AddLog("结算招募")
    while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.944 * NikkeW . " ", NikkeY + 0.011 * NikkeH . " ", NikkeX + 0.944 * NikkeW + 0.015 * NikkeW . " ", NikkeY + 0.011 * NikkeH + 0.029 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("招募·SKIP的图标"), , 0, , , , , TrueRatio, TrueRatio)) { ;如果没找到SKIP就一直点左下角（加速动画）
        Confirm
    }
    FindText().Click(X, Y, "L") ;找到了就点
    Sleep 1000
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.421 * NikkeW . " ", NikkeY + 0.889 * NikkeH . " ", NikkeX + 0.421 * NikkeW + 0.028 * NikkeW . " ", NikkeY + 0.889 * NikkeH + 0.027 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("确认"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
}
;tag 点掉推销
RefuseSale() {
    if (ok := FindText(&X, &Y, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.853 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.124 * NikkeW . " ", NikkeY + 0.853 * NikkeH + 0.048 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("黄色的小时"), , , , , , , TrueRatio, TrueRatio)) {
        UserClick(333, 2041, TrueRatio)
        Sleep 500
        if (ok := FindText(&X, &Y, NikkeX + 0.504 * NikkeW . " ", NikkeY + 0.594 * NikkeH . " ", NikkeX + 0.504 * NikkeW + 0.127 * NikkeW . " ", NikkeY + 0.594 * NikkeH + 0.065 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 500
        }
    }
}
;tag 判断是否开启自动
CheckAuto() {
    if (ok := FindText(&X, &Y, NikkeX + 0.005 * NikkeW . " ", NikkeY + 0.012 * NikkeH . " ", NikkeX + 0.005 * NikkeW + 0.073 * NikkeW . " ", NikkeY + 0.012 * NikkeH + 0.043 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("灰色的AUTO图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("检测到未开启自动爆裂，已开启")
        Send "{Tab}"
    }
    if (ok := FindText(&X, &Y, NikkeX + 0.005 * NikkeW . " ", NikkeY + 0.012 * NikkeH . " ", NikkeX + 0.005 * NikkeW + 0.073 * NikkeW . " ", NikkeY + 0.012 * NikkeH + 0.043 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的射击图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("检测到未开启自动射击，已开启")
        Send "{LShift}"
    }
}
;tag 跳过boss入场动画
Skipping() {
    while true {
        UserClick(2123, 1371, TrueRatio)
        Sleep 500
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 500
            FindText().Click(X, Y, "L")
            AddLog("跳过动画")
            break
        }
        if (A_Index > 30) {
            break
        }
    }
}
;tag 进入战斗
EnterToBattle() {
    ;是否能战斗
    global BattleActive
    ;是否能跳过动画
    global BattleSkip
    ;是否能快速战斗
    global QuickBattle
    QuickBattle := 0
    ; AddLog("尝试进入战斗")
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.826 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.145 * NikkeW . " ", NikkeY + 0.826 * NikkeH + 0.065 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("快速战斗的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击快速战斗")
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        BattleActive := 1
        QuickBattle := 1
        Sleep 500
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.553 * NikkeW . " ", NikkeY + 0.683 * NikkeH . " ", NikkeX + 0.553 * NikkeW + 0.036 * NikkeW . " ", NikkeY + 0.683 * NikkeH + 0.040 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("MAX"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 500
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.470 * NikkeW . " ", NikkeY + 0.733 * NikkeH . " ", NikkeX + 0.470 * NikkeW + 0.157 * NikkeW . " ", NikkeY + 0.733 * NikkeH + 0.073 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("进行战斗的进"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 500
        }
        BattleSkip := 0
    }
    else if (ok := FindText(&X, &Y, NikkeX + 0.499 * NikkeW . " ", NikkeY + 0.786 * NikkeH . " ", NikkeX + 0.499 * NikkeW + 0.155 * NikkeW . " ", NikkeY + 0.786 * NikkeH + 0.191 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("进入战斗的进"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击进入战斗")
        BattleActive := 1
        BattleSkip := 1
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        Sleep 500
    }
    else if (ok := FindText(&X, &Y, NikkeX + 0.519 * NikkeW . " ", NikkeY + 0.831 * NikkeH . " ", NikkeX + 0.519 * NikkeW + 0.134 * NikkeW . " ", NikkeY + 0.831 * NikkeH + 0.143 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的进"), , , , , , , TrueRatio, TrueRatio)) {
        BattleActive := 2
    }
    else {
        BattleActive := 0
        AddLog("无法战斗")
    }
}
;tag 战斗结算
BattleSettlement(modes*) {
    global Victory
    Screenshot := false
    RedCircle := false
    Exit7 := false
    EventStory := false
    if (BattleActive = 0 or BattleActive = 2) {
        AddLog("由于无法战斗，跳过战斗结算")
        if BattleActive = 2 {
            Send "{Esc}"
        }
        return
    }
    for mode in modes {
        switch mode {
            case "Screenshot":
            {
                Screenshot := true
                if BattleSkip := 1
                    AddLog("截图功能已启用", "Green")
            }
            case "RedCircle":
            {
                RedCircle := true
                if BattleSkip := 1
                    AddLog("红圈功能已启用", "Green")
            }
            case "Exit7":
            {
                Exit7 := true
                if BattleSkip := 1
                    AddLog("满7自动退出功能已启用", "Green")
            }
            case "EventStory":
            {
                EventStory := true
                if BattleSkip := 1
                    AddLog("剧情跳过功能已启用", "Green")
            }
            default: MsgBox "格式输入错误，你输入的是" mode
        }
    }
    AddLog("等待战斗结算")
    while true {
        if Exit7 {
            if (ok := FindText(&X, &Y, NikkeX + 0.512 * NikkeW . " ", NikkeY + 0.072 * NikkeH . " ", NikkeX + 0.512 * NikkeW + 0.020 * NikkeW . " ", NikkeY + 0.072 * NikkeH + 0.035 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("拦截战·红色框的7"), , , , , , , TrueRatio, TrueRatio)) {
                Send "{Esc}"
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.382 * NikkeW . " ", NikkeY + 0.890 * NikkeH . " ", NikkeX + 0.382 * NikkeW + 0.113 * NikkeW . " ", NikkeY + 0.890 * NikkeH + 0.067 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("放弃战斗的图标"), , , , , , , TrueRatio, TrueRatio)) {
                    Sleep 500
                    FindText().Click(X, Y, "L")
                    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.518 * NikkeW . " ", NikkeY + 0.609 * NikkeH . " ", NikkeX + 0.518 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.609 * NikkeH + 0.033 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                        Sleep 500
                        FindText().Click(X, Y, "L")
                    }
                    AddLog("满7自动退出")
                }
            }
        }
        if RedCircle {
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.12 * PicTolerance, 0.13 * PicTolerance, FindText().PicLib("红圈的上边缘黄边"), , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("检测到红圈的上边缘黄边")
                FindText().Click(X, Y + 70 * TrueRatio, 0)
                Sleep 100
                Click "down left"
                Sleep 700
                Click "up left"
                Sleep 100
            }
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.12 * PicTolerance, 0.13 * PicTolerance, FindText().PicLib("红圈的下边缘黄边"), , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("检测到红圈的下边缘黄边")
                FindText().Click(X, Y - 70 * TrueRatio, 0)
                Sleep 100
                Click "down left"
                Sleep 700
                Click "up left"
                Sleep 100
            }
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.12 * PicTolerance, 0.11 * PicTolerance, FindText().PicLib("红圈的左边缘黄边"), , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("检测到红圈的左边缘黄边")
                FindText().Click(X + 70 * TrueRatio, Y, 0)
                Sleep 100
                Click "down left"
                Sleep 700
                Click "up left"
                Sleep 100
            }
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.12 * PicTolerance, 0.13 * PicTolerance, FindText().PicLib("红圈的右边缘黄边"), , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("检测到红圈的右边缘黄边")
                FindText().Click(X - 70 * TrueRatio, Y, 0)
                Sleep 100
                Click "down left"
                Sleep 700
                Click "up left"
                Sleep 100
            }
        }
        if EventStory {
            ; 跳过剧情
            Send "{]}"
            ; 区域变化的提示
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.445 * NikkeW . " ", NikkeY + 0.561 * NikkeH . " ", NikkeX + 0.445 * NikkeW + 0.111 * NikkeW . " ", NikkeY + 0.561 * NikkeH + 0.056 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("前往区域的图标"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y + 400 * TrueRatio, "L")
            }
        }
        ; 检测自动战斗和爆裂
        if g_settings["CheckAuto"] {
            CheckAuto
        }
        ;无限之塔的位置
        if (ok := FindText(&X, &Y, NikkeX + 0.855 * NikkeW . " ", NikkeY + 0.907 * NikkeH . " ", NikkeX + 0.855 * NikkeW + 0.031 * NikkeW . " ", NikkeY + 0.907 * NikkeH + 0.081 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("TAB的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("[无限之塔胜利]TAB已命中")
            break
        }
        ; 无限之塔失败的位置
        else if (ok := FindText(&X, &Y, NikkeX + 0.784 * NikkeW . " ", NikkeY + 0.895 * NikkeH . " ", NikkeX + 0.784 * NikkeW + 0.031 * NikkeW . " ", NikkeY + 0.895 * NikkeH + 0.078 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("TAB的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("[无限之塔失败]TAB已命中")
            break
        }
        ; 新人竞技场+模拟室+异常拦截的位置
        else if (ok := FindText(&X, &Y, NikkeX + 0.954 * NikkeW . " ", NikkeY + 0.913 * NikkeH . " ", NikkeX + 0.954 * NikkeW + 0.043 * NikkeW . " ", NikkeY + 0.913 * NikkeH + 0.080 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("TAB的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("[新人竞技场|模拟室|异常拦截|推图]TAB已命中")
            break
        }
        else if (ok := FindText(&X, &Y, NikkeX + 0.012 * NikkeW . " ", NikkeY + 0.921 * NikkeH . " ", NikkeX + 0.012 * NikkeW + 0.036 * NikkeW . " ", NikkeY + 0.921 * NikkeH + 0.072 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("重播的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("[竞技场快速战斗失败]重播的图标已命中", "MAROON")
            break
        }
        else if (ok := FindText(&X, &Y, NikkeX + 0.484 * NikkeW . " ", NikkeY + 0.877 * NikkeH . " ", NikkeX + 0.484 * NikkeW + 0.032 * NikkeW . " ", NikkeY + 0.877 * NikkeH + 0.035 * NikkeH . " ", 0.25 * PicTolerance, 0.25 * PicTolerance, FindText().PicLib("ESC"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("[扫荡|活动推关]ESC已命中")
            break
        }
        ; 基地防御等级提升的页面
        if (ok := FindText(&X, &Y, NikkeX + 0.424 * NikkeW . " ", NikkeY + 0.424 * NikkeH . " ", NikkeX + 0.424 * NikkeW + 0.030 * NikkeW . " ", NikkeY + 0.424 * NikkeH + 0.030 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("LV."), , , , , , , TrueRatio, TrueRatio)) {
            Confirm
        }
        ;间隔500ms
        Sleep 500
    }
    ;是否需要截图
    if Screenshot {
        Sleep 1000
        TimeString := FormatTime(, "yyyyMMdd_HHmmss")
        FindText().SavePic(A_ScriptDir "\Screenshot\" TimeString ".jpg", NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, ScreenShot := 1)
    }
    ;有灰色的锁代表赢了但次数耗尽
    if (ok := FindText(&X, &Y, NikkeX + 0.893 * NikkeW . " ", NikkeY + 0.920 * NikkeH . " ", NikkeX + 0.893 * NikkeW + 0.019 * NikkeW . " ", NikkeY + 0.920 * NikkeH + 0.039 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("灰色的锁"), , , , , , , TrueRatio, TrueRatio)) {
        Victory := Victory + 1
        if Victory > 1 {
            AddLog("共胜利" Victory "次")
        }
    }
    ;有编队代表输了，点Esc
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("编队的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("战斗失败！尝试返回", "MAROON")
        GoBack
        Sleep 1000
        return False
    }
    ;如果有下一关，就点下一关（爬塔的情况）
    else if (ok := FindText(&X, &Y, NikkeX + 0.889 * NikkeW . " ", NikkeY + 0.912 * NikkeH . " ", NikkeX + 0.889 * NikkeW + 0.103 * NikkeW . " ", NikkeY + 0.912 * NikkeH + 0.081 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("白色的下一关卡"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("战斗成功！尝试进入下一关", "GREEN")
        Victory := Victory + 1
        if Victory > 1 {
            AddLog("共胜利" Victory "次")
        }
        FindText().Click(X, Y + 20 * TrueRatio, "L")
        Sleep 5000
        if EventStory {
            BattleSettlement("EventStory")
        }
        else {
            BattleSettlement()
        }
    }
    ;没有编队也没有下一关就点Esc（普通情况或者爬塔次数用完了）
    else {
        AddLog("战斗结束！")
        GoBack
        Sleep 1000
        Send "{]}"
        Confirm
        return True
    }
    ;递归结束时清零
    Victory := 0
}
;tag 活动挑战
Challenge() {
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.005 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.063 * NikkeW . " ", NikkeY + 0.005 * NikkeH + 0.050 * NikkeH . " ", 0.35 * PicTolerance, 0.35 * PicTolerance, FindText().PicLib("挑战关卡"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("进入挑战关卡页面")
    }
    Sleep 2000
    if (ok := FindText(&X, &Y, NikkeX + 0.354 * NikkeW . " ", NikkeY + 0.344 * NikkeH . " ", NikkeX + 0.354 * NikkeW + 0.052 * NikkeW . " ", NikkeY + 0.344 * NikkeH + 0.581 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红色的关卡的循环图标"), , , , , , , TrueRatio, TrueRatio)) {
        Sleep 1000
        FindText().Click(X + 50 * TrueRatio, Y, "L")
    }
    else if (ok := FindText(&X, &Y, NikkeX + 0.354 * NikkeW . " ", NikkeY + 0.344 * NikkeH . " ", NikkeX + 0.354 * NikkeW + 0.052 * NikkeW . " ", NikkeY + 0.344 * NikkeH + 0.581 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("黄色的关卡的循环图标"), , , , , , 3, TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
    }
    EnterToBattle
    if BattleSkip = 1 {
        Skipping
    }
    BattleSettlement
}
;tag 返回大厅
BackToHall(AD := False) {
    ; AddLog("返回大厅")
    while true {
        if !WinActive(nikkeID) {
            MsgBox ("窗口未聚焦，程序已中止")
            Pause
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.658 * NikkeW . " ", NikkeY + 0.639 * NikkeH . " ", NikkeX + 0.658 * NikkeW + 0.040 * NikkeW . " ", NikkeY + 0.639 * NikkeH + 0.066 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("方舟的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            if AD = False {
                break
            }
            ; 点右上角的公告图标
            UserClick(3568, 90, TrueRatio)
            Sleep 500
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.477 * NikkeW . " ", NikkeY + 0.082 * NikkeH . " ", NikkeX + 0.477 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.082 * NikkeH + 0.042 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("公告的图标"), , , , , , , TrueRatio, TrueRatio)) {
                ; AddLog("已返回大厅")
                UserClick(333, 2041, TrueRatio)
                Sleep 500
                break
            }
            else RefuseSale
        } else {
            ; 点左下角的小房子的位置
            UserClick(333, 2041, TrueRatio)
            Sleep 500
            Send "{]}"
            RefuseSale
        }
        if A_Index > 40 {
            UserClick(1924, 1968, TrueRatio)
        }
        if A_Index > 50 {
            MsgBox ("返回大厅失败，程序已中止")
            Pause
        }
    }
    Sleep 1000
}
;tag 进入方舟
EnterToArk() {
    AddLog("进入方舟")
    while True {
        Sleep 500
        if (ok := FindText(&X, &Y, NikkeX + 0.014 * NikkeW . " ", NikkeY + 0.026 * NikkeH . " ", NikkeX + 0.014 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.026 * NikkeH + 0.021 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("左上角的方舟"), , , , , , , TrueRatio, TrueRatio)) {
            break
        }
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.658 * NikkeW . " ", NikkeY + 0.639 * NikkeH . " ", NikkeX + 0.658 * NikkeW + 0.040 * NikkeW . " ", NikkeY + 0.639 * NikkeH + 0.066 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("方舟的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X + 50 * TrueRatio, Y, "L") ;找得到就尝试进入
        }
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.014 * NikkeW . " ", NikkeY + 0.026 * NikkeH . " ", NikkeX + 0.014 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.026 * NikkeH + 0.021 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("左上角的方舟"), , , , , , , TrueRatio, TrueRatio)) {
            break
        }
        else BackToHall() ;找不到就先返回大厅
    }
    Sleep 2000
}
;tag 进入前哨基地
EnterToOutpost() {
    AddLog("进入前哨基地")
    while True {
        Sleep 500
        if (ok := FindText(&X, &Y, NikkeX + 0.004 * NikkeW . " ", NikkeY + 0.020 * NikkeH . " ", NikkeX + 0.004 * NikkeW + 0.043 * NikkeW . " ", NikkeY + 0.020 * NikkeH + 0.034 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("左上角的前哨基地"), , , , , , , TrueRatio, TrueRatio)) {
            break
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.240 * NikkeW . " ", NikkeY + 0.755 * NikkeH . " ", NikkeX + 0.240 * NikkeW + 0.048 * NikkeW . " ", NikkeY + 0.755 * NikkeH + 0.061 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("前哨基地的图标"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L") ;找得到就尝试进入
        }
        if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.004 * NikkeW . " ", NikkeY + 0.020 * NikkeH . " ", NikkeX + 0.004 * NikkeW + 0.043 * NikkeW . " ", NikkeY + 0.020 * NikkeH + 0.034 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("左上角的前哨基地"), , , , , , , TrueRatio, TrueRatio)) {
            break
        }
        else BackToHall() ;找不到就先返回大厅
    }
    Sleep 2000
}
;tag 自动填充加成妮姬
AutoFill() {
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.352 * NikkeW . " ", NikkeY + 0.713 * NikkeH . " ", NikkeX + 0.352 * NikkeW + 0.304 * NikkeW . " ", NikkeY + 0.713 * NikkeH + 0.107 * NikkeH . " ", 0.25 * PicTolerance, 0.25 * PicTolerance, FindText().PicLib("剧情活动·黑色十字"), , , , , , 1, TrueRatio, TrueRatio)) {
        if g_settings["AutoFill"] and g_numeric_settings["UserLevel"] >= 3 {
            AddLog("点击黑色的加号")
            FindText().Click(X, Y, "L")
            Sleep 500
            FindText().Click(X, Y, "L")
            Sleep 2000
            if (ok := FindText(&X, &Y, NikkeX + 0.034 * NikkeW . " ", NikkeY + 0.483 * NikkeH . " ", NikkeX + 0.034 * NikkeW + 0.564 * NikkeW . " ", NikkeY + 0.483 * NikkeH + 0.039 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("剧情活动·0%"), , , , , , 1, TrueRatio, TrueRatio)) {
                loop ok.Length {
                    AddLog("添加第" A_Index "个妮姬")
                    FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
                    Sleep 1000
                    if A_Index = 5
                        break
                }
            }
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.917 * NikkeW . " ", NikkeY + 0.910 * NikkeH . " ", NikkeX + 0.917 * NikkeW + 0.077 * NikkeW . " ", NikkeY + 0.910 * NikkeH + 0.057 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击储存")
                FindText().Click(X, Y, "L")
                Sleep 2000
            }
        } else {
            MsgBox ("请手动选择妮姬")
        }
    }
}
;tag 推关模式
AdvanceMode(Picture, Picture2?) {
    AddLog("进行活动推关")
    Failed := false
    while true {
        ok := ""
        currentPic := ""
        hasAutoFill := false
        ; 记录本轮是否需要跳过 Picture 的检查
        skipped := Failed
        ; 假设本轮能成功处理，先将标记重置为 false
        Failed := false
        ; 1. 尝试匹配 Picture (高优先级)
        ; 只有在 Picture 上一轮没有失败时，才进行识别
        if (!skipped && (ok_Pic := FindText(&X := "wait", &Y := 1, NikkeX + 0.305 * NikkeW . " ", NikkeY + 0.230 * NikkeH . " ", NikkeX + 0.305 * NikkeW + 0.388 * NikkeW . " ", NikkeY + 0.230 * NikkeH + 0.691 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib(Picture), , , , , , 4, TrueRatio, TrueRatio))) {
            ok := ok_Pic
            currentPic := Picture
            hasAutoFill := true
            AddLog("找到非扫荡关卡")
        }
        ; 2. 尝试匹配 Picture2 (低优先级，使用 else if 确保优先级)
        ; 无论 Picture 是否被跳过，如果 Picture 未找到，都会尝试 Picture2
        else if (Picture2 && (ok_Pic2 := FindText(&X := "wait", &Y := 1, NikkeX + 0.305 * NikkeW . " ", NikkeY + 0.230 * NikkeH . " ", NikkeX + 0.305 * NikkeW + 0.388 * NikkeW . " ", NikkeY + 0.230 * NikkeH + 0.691 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib(Picture2), , , , , , 4, TrueRatio, TrueRatio))) {
            ok := ok_Pic2
            currentPic := Picture2
            hasAutoFill := false
            AddLog("找到扫荡关卡")
        }
        else {
            AddLog("未找到可用关卡，结束推关模式")
            return
        }
        ; 3. 统一处理找到的图片逻辑
        if (ok && currentPic) {
            ; 3.1 点击图标进入关卡详情页
            try {
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
            ; 只有 Picture 有自动填充逻辑
            if (hasAutoFill) {
                AutoFill
            }
            ; 3.2 尝试进入战斗 (依赖 EnterToBattle 内部设置 BattleActive)
            EnterToBattle
            BattleSettlement("EventStory")
            ; 区域变化的提示
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.445 * NikkeW . " ", NikkeY + 0.561 * NikkeH . " ", NikkeX + 0.445 * NikkeW + 0.111 * NikkeW . " ", NikkeY + 0.561 * NikkeH + 0.056 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("前往区域的图标"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y + 400 * TrueRatio, "L")
            }
            ; 3.3 退出判断（仅扫荡成功时退出）
            if (QuickBattle = 1) {
                AddLog("扫荡完成，退出推关模式")
                return
            }
            ; 3.4 关键失败/耗尽处理
            ; 如果当前处理的是 Picture 且失败了，就设置标记，让下一轮跳过它。
            if (currentPic == Picture && BattleActive != 1) {
                Failed := true ; 标记失败，下一轮将跳过 Picture
            }
            if (BattleActive == 0) {
                AddLog("关卡无法进入，切换识图类型")
                continue
            }
            else if (BattleActive == 2) {
                AddLog("关卡次数耗尽")
                return
            }
            Sleep 1000
        }
        Sleep 3000
        Send "{]}" ;防止最后一关剧情卡死
    }
}
;endregion 流程辅助函数
;region 登录
Login() {
    check := 0
    while True {
        AddLog("正在登录")
        if (check = 3) {
            break
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.658 * NikkeW . " ", NikkeY + 0.639 * NikkeH . " ", NikkeX + 0.658 * NikkeW + 0.040 * NikkeW . " ", NikkeY + 0.639 * NikkeH + 0.066 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("方舟的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            check := check + 1
            Sleep 1000
            continue
        }
        else check := 0
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.533 * NikkeW . " ", NikkeY + 0.908 * NikkeH . " ", NikkeX + 0.533 * NikkeW + 0.115 * NikkeW . " ", NikkeY + 0.908 * NikkeH + 0.059 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("签到·全部领取"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("领取签到奖励")
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.443 * NikkeW . " ", NikkeY + 0.703 * NikkeH . " ", NikkeX + 0.443 * NikkeW + 0.116 * NikkeW . " ", NikkeY + 0.703 * NikkeH + 0.051 * NikkeH . " ", 0.25 * PicTolerance, 0.25 * PicTolerance, FindText().PicLib("确认的白色勾"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("确认服务器")
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            Sleep 1000
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.504 * NikkeW . " ", NikkeY + 0.610 * NikkeH . " ", NikkeX + 0.504 * NikkeW + 0.090 * NikkeW . " ", NikkeY + 0.610 * NikkeH + 0.056 * NikkeH . " ", 0.25 * PicTolerance, 0.25 * PicTolerance, FindText().PicLib("确认的白色勾"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("确认下载内容")
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            Sleep 1000
        }
        UserClick(330, 2032, TrueRatio)
        Sleep 1000
        if !WinActive(nikkeID) {
            MsgBox ("窗口未聚焦，程序已中止")
            Pause
        }
    }
    AddLog("已处于大厅页面，登录成功")
}
;endregion 登录
;region 语言切换
AutoSwitchLanguage() {
    UserClick(3770, 70, TrueRatio) ; 点右上角的SUB
    Sleep 1000
    if (ok := FindText(&X, &Y, NikkeX + 0.396 * NikkeW . " ", NikkeY + 0.454 * NikkeH . " ", NikkeX + 0.396 * NikkeW + 0.103 * NikkeW . " ", NikkeY + 0.454 * NikkeH + 0.069 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("账号的图标"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
        if (ok := FindText(&X, &Y, NikkeX + 0.595 * NikkeW . " ", NikkeY + 0.247 * NikkeH . " ", NikkeX + 0.595 * NikkeW + 0.029 * NikkeW . " ", NikkeY + 0.247 * NikkeH + 0.041 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("账号·向下的三角"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 1000
            ; 找得到中文，说明是非中文界面，应该改成中文之后重新运行
            if (ok := FindText(&X, &Y, NikkeX + 0.503 * NikkeW . " ", NikkeY + 0.242 * NikkeH . " ", NikkeX + 0.503 * NikkeW + 0.122 * NikkeW . " ", NikkeY + 0.242 * NikkeH + 0.377 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("(简体)"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
                if (ok := FindText(&X, &Y, NikkeX + 0.518 * NikkeW . " ", NikkeY + 0.609 * NikkeH . " ", NikkeX + 0.518 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.609 * NikkeH + 0.033 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    Login
                    return
                }
            }
            ; 找不到中文，说明已经是中文界面，应该改回原语言之后重新运行
            else {
                switch g_numeric_settings["LanguageList"] {
                    case 1:
                    {
                        language := FindText().PicLib("ENGLISH")
                    }
                    case 2:
                    {
                        language := FindText().PicLib("日本语")
                    }
                    case 3:
                    {
                        language := FindText().PicLib("(繁体)")
                    }
                    case 4:
                    {
                        language := FindText().PicLib("(简体)")
                    }
                }
                if (ok := FindText(&X, &Y, NikkeX + 0.505 * NikkeW . " ", NikkeY + 0.283 * NikkeH . " ", NikkeX + 0.505 * NikkeW + 0.116 * NikkeW . " ", NikkeY + 0.283 * NikkeH + 0.327 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, language, , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    if (ok := FindText(&X, &Y, NikkeX + 0.518 * NikkeW . " ", NikkeY + 0.609 * NikkeH . " ", NikkeX + 0.518 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.609 * NikkeH + 0.033 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                        FindText().Click(X, Y, "L")
                        Sleep 1000
                        Login
                        return
                    }
                }
            }
        }
    }
}
;endregion 语言切换
;region 商店
;tag 付费商店
ShopCash() {
    AddLog("开始任务：付费商店", "Fuchsia")
    AddLog("寻找付费商店")
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.250 * NikkeW . " ", NikkeY + 0.599 * NikkeH . " ", NikkeX + 0.250 * NikkeW + 0.027 * NikkeW . " ", NikkeY + 0.599 * NikkeH + 0.047 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("付费商店的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击付费商店")
        FindText().Click(X, Y, "L")
        Sleep 2000
        if g_settings["ShopCashFree"] {
            AddLog("领取免费珠宝")
            while true {
                if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.386 * NikkeW . " ", NikkeY + 0.632 * NikkeH . " ", NikkeX + 0.386 * NikkeW + 0.016 * NikkeW . " ", NikkeY + 0.632 * NikkeH + 0.025 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("灰色空心方框"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("发现日服特供的框")
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
                        AddLog("点击确认")
                        FindText().Click(X, Y, "L")
                    }
                }
                else if (ok := FindText(&X, &Y, NikkeX + 0.040 * NikkeW . " ", NikkeY + 0.178 * NikkeH . " ", NikkeX + 0.040 * NikkeW + 0.229 * NikkeW . " ", NikkeY + 0.178 * NikkeH + 0.080 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("礼物的下半"), , , , , , , TrueRatio, TrueRatio)) {
                    Sleep 500
                    AddLog("点击一级页面")
                    FindText().Click(X + 20 * TrueRatio, Y + 20 * TrueRatio, "L")
                    Sleep 500
                }
                else break
            }
            while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.010 * NikkeW . " ", NikkeY + 0.259 * NikkeH . " ", NikkeX + 0.010 * NikkeW + 0.351 * NikkeW . " ", NikkeY + 0.259 * NikkeH + 0.051 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击二级页面")
                FindText().Click(X - 20 * TrueRatio, Y + 20 * TrueRatio, "L")
                Sleep 1000
                if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.089 * NikkeW . " ", NikkeY + 0.334 * NikkeH . " ", NikkeX + 0.089 * NikkeW + 0.019 * NikkeW . " ", NikkeY + 0.334 * NikkeH + 0.034 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , 5, TrueRatio, TrueRatio)) {
                    AddLog("点击三级页面")
                    FindText().Click(X - 20 * TrueRatio, Y + 20 * TrueRatio, "L")
                    Sleep 1000
                    Confirm
                    Sleep 500
                    Confirm
                }
                if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("白色的叉叉"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    AddLog("检测到白色叉叉，尝试重新执行任务")
                    BackToHall
                    ShopCash
                }
            }
            else {
                AddLog("奖励已全部领取")
            }
        }
        if g_settings["ShopCashFreePackage"] {
            AddLog("领取免费礼包")
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.180 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.266 * NikkeW . " ", NikkeY + 0.180 * NikkeH + 0.077 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击一级页面")
                FindText().Click(X - 20 * TrueRatio, Y + 20 * TrueRatio, "L")
                Sleep 1000
                if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.010 * NikkeW . " ", NikkeY + 0.259 * NikkeH . " ", NikkeX + 0.010 * NikkeW + 0.351 * NikkeW . " ", NikkeY + 0.259 * NikkeH + 0.051 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击二级页面")
                    FindText().Click(X - 20 * TrueRatio, Y + 20 * TrueRatio, "L")
                    Sleep 1000
                    ;把鼠标移动到商品栏
                    UserMove(1918, 1060, TrueRatio)
                    Send "{WheelUp 3}"
                    Sleep 1000
                }
                if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.332 * NikkeW . " ", NikkeY + 0.443 * NikkeH . " ", NikkeX + 0.332 * NikkeW + 0.327 * NikkeW . " ", NikkeY + 0.443 * NikkeH + 0.466 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击三级页面")
                    FindText().Click(X - 20 * TrueRatio, Y + 20 * TrueRatio, "L")
                    Sleep 1000
                    Confirm
                }
            }
            AddLog("奖励已全部领取")
        }
        if g_settings["ClearRed"] {
            while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.001 * NikkeW . " ", NikkeY + 0.191 * NikkeH . " ", NikkeX + 0.001 * NikkeW + 0.292 * NikkeW . " ", NikkeY + 0.191 * NikkeH + 0.033 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , 0.83 * TrueRatio, 0.83 * TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
                while (ok := FindText(&X, &Y, NikkeX + 0.005 * NikkeW . " ", NikkeY + 0.254 * NikkeH . " ", NikkeX + 0.005 * NikkeW + 0.468 * NikkeW . " ", NikkeY + 0.254 * NikkeH + 0.031 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    UserClick(208, 608, TrueRatio)
                    Sleep 1000
                }
            }
        }
    }
    BackToHall
}
;tag 进入商店
Shop() {
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.236 * NikkeW . " ", NikkeY + 0.633 * NikkeH . " ", NikkeX + 0.236 * NikkeW + 0.118 * NikkeW . " ", NikkeY + 0.633 * NikkeH + 0.103 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("商店的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击商店图标")
        FindText().Click(X + 20 * TrueRatio, Y - 20 * TrueRatio, "L")
    }
    else {
        MsgBox("商店图标未找到")
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("左上角的百货商店"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("已进入百货商店")
    }
}
;tag 普通商店
ShopGeneral() {
    AddLog("开始任务：普通商店", "Fuchsia")
    if g_settings["ShopGeneralFree"] = False and g_settings["ShopGeneralDust"] = False and g_settings["ShopGeneralPackage"] = False {
        AddLog("普通商店购买选项均未启用，跳过此任务", "Fuchsia")
        return
    }
    Sleep 1000
    ; 定义所有可购买物品的信息 (使用 Map)
    PurchaseItems := Map(
        "免费商品", {
            Text: FindText().PicLib("红点"),
            Setting: g_settings["ShopGeneralFree"],
            Tolerance: 0.4 * PicTolerance },
        "芯尘盒", {
            Text: FindText().PicLib("芯尘盒"),
            Setting: g_settings["ShopGeneralDust"],
            Tolerance: 0.2 * PicTolerance },
        "简介个性化礼包", {
            Text: FindText().PicLib("简介个性化礼包"),
            Setting: g_settings["ShopGeneralPackage"],
            Tolerance: 0.2 * PicTolerance }
    )
    loop 2 {
        for Name, item in PurchaseItems {
            if (!item.Setting) {
                continue ; 如果设置未开启，则跳过此物品
            }
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.061 * NikkeW . " ", NikkeY + 0.493 * NikkeH . " ", NikkeX + 0.061 * NikkeW + 0.416 * NikkeW . " ", NikkeY + 0.493 * NikkeH + 0.038 * NikkeH . " ", item.Tolerance, item.Tolerance, item.Text, , , , , , , TrueRatio, TrueRatio)) {
                loop ok.Length {
                    AddLog("购买" . Name)
                    FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
                    Sleep 1000
                    if name = "芯尘盒" {
                        if (ok0 := FindText(&X := "wait", &Y := 2, NikkeX + 0.430 * NikkeW . " ", NikkeY + 0.716 * NikkeH . " ", NikkeX + 0.430 * NikkeW + 0.139 * NikkeW . " ", NikkeY + 0.716 * NikkeH + 0.034 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("信用点的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
                            AddLog("检测到信用点支付选项")
                        }
                        else {
                            AddLog("未检测到信用点支付选项")
                            Confirm
                            Sleep 1000
                            continue
                        }
                    }
                    if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.786 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.088 * NikkeW . " ", NikkeY + 0.786 * NikkeH + 0.146 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
                        FindText().Click(X, Y, "L")
                        Sleep 1000
                    }
                    while !(ok2 := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("左上角的百货商店"), , 0, , , , , TrueRatio, TrueRatio)) {
                        Confirm
                    }
                }
            } else {
                AddLog(Name . "未找到，跳过购买")
            }
        }
        while (ok := FindText(&X, &Y, NikkeX + 0.173 * NikkeW . " ", NikkeY + 0.423 * NikkeH . " ", NikkeX + 0.173 * NikkeW + 0.034 * NikkeW . " ", NikkeY + 0.423 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("FREE"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试刷新商店")
            FindText().Click(X - 100 * TrueRatio, Y + 30 * TrueRatio, "L")
            Sleep 500
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.504 * NikkeW . " ", NikkeY + 0.593 * NikkeH . " ", NikkeX + 0.504 * NikkeW + 0.127 * NikkeW . " ", NikkeY + 0.593 * NikkeH + 0.066 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 500
                AddLog("刷新成功")
            }
        } else {
            AddLog("没有免费刷新次数了，跳过刷新")
            break ; 退出外层 loop 2 循环，因为没有免费刷新了
        }
        Sleep 2000
    }
}
;tag 竞技场商店
ShopArena() {
    AddLog("开始任务：竞技场商店", "Fuchsia")
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.001 * NikkeW . " ", NikkeY + 0.355 * NikkeH . " ", NikkeX + 0.001 * NikkeW + 0.041 * NikkeW . " ", NikkeY + 0.355 * NikkeH + 0.555 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("竞技场商店的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("进入竞技场商店")
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    else {
        AddLog("竞技场商店图标未找到", "Red")
        return
    }
    ; 定义所有可购买物品的信息 (使用 Map)
    PurchaseItems := Map(
        "燃烧代码手册", {
            Text: FindText().PicLib("燃烧代码的图标"),
            Setting: g_settings["ShopArenaBookFire"],
            Tolerance: 0.2 * PicTolerance },
        "水冷代码手册", {
            Text: FindText().PicLib("水冷代码的图标"),
            Setting: g_settings["ShopArenaBookWater"],
            Tolerance: 0.2 * PicTolerance },
        "风压代码手册", {
            Text: FindText().PicLib("风压代码的图标"),
            Setting: g_settings["ShopArenaBookWind"],
            Tolerance: 0.3 * PicTolerance },
        "电击代码手册", {
            Text: FindText().PicLib("电击代码的图标"),
            Setting: g_settings["ShopArenaBookElec"],
            Tolerance: 0.2 * PicTolerance },
        "铁甲代码手册", {
            Text: FindText().PicLib("铁甲代码的图标"),
            Setting: g_settings["ShopArenaBookIron"],
            Tolerance: 0.2 * PicTolerance },
        "代码手册宝箱", {
            Text: FindText().PicLib("代码手册选择宝箱的图标"),
            Setting: g_settings["ShopArenaBookBox"],
            Tolerance: 0.3 * PicTolerance },
        "简介个性化礼包", {
            Text: FindText().PicLib("简介个性化礼包"),
            Setting: g_settings["ShopArenaPackage"],
            Tolerance: 0.3 * PicTolerance },
        "公司武器熔炉", {
            Text: FindText().PicLib("公司武器熔炉"),
            Setting: g_settings["ShopArenaFurnace"],
            Tolerance: 0.3 * PicTolerance }
    )
    ; 遍历并购买所有物品
    for Name, item in PurchaseItems {
        if (!item.Setting) {
            continue ; 如果设置未开启，则跳过此物品
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.061 * NikkeW . " ", NikkeY + 0.499 * NikkeH . " ", NikkeX + 0.061 * NikkeW + 0.499 * NikkeW . " ", NikkeY + 0.499 * NikkeH + 0.119 * NikkeH . " ", item.Tolerance, item.Tolerance, item.Text, , , , , , , TrueRatio, TrueRatio)) {
            ; 手册要根据找到个数多次执行
            loop ok.Length {
                FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
                if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.786 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.088 * NikkeW . " ", NikkeY + 0.786 * NikkeH + 0.146 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
                    Sleep 500
                    AddLog("购买" . Name)
                    FindText().Click(X, Y, "L")
                    Sleep 500
                    while !(ok2 := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("左上角的百货商店"), , 0, , , , , TrueRatio, TrueRatio)) {
                        Confirm
                    }
                }
            }
        }
        else {
            AddLog(Name . "未找到，跳过购买")
        }
    }
}
;tag 废铁商店
ShopRecycling() {
    Reopen := false
    AddLog("开始任务：废铁商店", "Fuchsia")
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.001 * NikkeW . " ", NikkeY + 0.355 * NikkeH . " ", NikkeX + 0.001 * NikkeW + 0.041 * NikkeW . " ", NikkeY + 0.355 * NikkeH + 0.555 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("废铁商店的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    ; 检查是否有限时商品
    if (ok := FindText(&X, &Y, NikkeX + 0.053 * NikkeW . " ", NikkeY + 0.482 * NikkeH . " ", NikkeX + 0.053 * NikkeW + 0.938 * NikkeW . " ", NikkeY + 0.482 * NikkeH + 0.236 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("商店·限时图标"), , 0, , , , , TrueRatio, TrueRatio)) {
        Reopen := true
    }
    ; 定义所有可购买物品的信息 (使用 Map)
    PurchaseItems := Map(
        "珠宝", {
            Text: FindText().PicLib("珠宝"),
            Setting: g_settings["ShopRecyclingGem"],
            Tolerance: 0.2 * PicTolerance },
        "好感券", {
            Text: FindText().PicLib("黄色的礼物图标"),
            Setting: g_settings["ShopRecyclingVoucher"],
            Tolerance: 0.3 * PicTolerance },
        "养成资源", {
            Text: FindText().PicLib("资源的图标"),
            Setting: g_settings["ShopRecyclingResources"],
            Tolerance: 0.2 * PicTolerance },
        "信用点", {
            Text: FindText().PicLib("黄色的信用点图标"),
            Setting: g_settings["ShopRecyclingResources"],
            Tolerance: 0.3 * PicTolerance },
        "团队合作宝箱", {
            Text: FindText().PicLib("团队合作宝箱图标"),
            Setting: g_settings["ShopRecyclingTeamworkBox"],
            Tolerance: 0.25 * PicTolerance },
        "保养工具箱", {
            Text: FindText().PicLib("保养工具箱图标"),
            Setting: g_settings["ShopRecyclingKitBox"],
            Tolerance: 0.3 * PicTolerance },
        "企业精选武装", {
            Text: FindText().PicLib("企业精选武装图标"),
            Setting: g_settings["ShopRecyclingArms"],
            Tolerance: 0.3 * PicTolerance }
    )
    ; 遍历并购买所有物品
    for Name, item in PurchaseItems {
        if (!item.Setting) {
            continue ; 如果设置未开启，则跳过此物品
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.049 * NikkeW . " ", NikkeY + 0.479 * NikkeH . " ", NikkeX + 0.049 * NikkeW + 0.940 * NikkeW . " ", NikkeY + 0.479 * NikkeH + 0.439 * NikkeH . " ", item.Tolerance, item.Tolerance, item.Text, , , , , , 1, TrueRatio, TrueRatio)) {
            ; 根据找到的同类图标数量进行循环购买
            loop ok.Length {
                FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
                AddLog("已找到" . Name)
                Sleep 1000
                if (okMax := FindText(&X := "wait", &Y := 2, NikkeX + 0.590 * NikkeW . " ", NikkeY + 0.595 * NikkeH . " ", NikkeX + 0.590 * NikkeW + 0.038 * NikkeW . " ", NikkeY + 0.595 * NikkeH + 0.070 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("MAX"), , 0, , , , , TrueRatio, TrueRatio)) {
                    ; AddLog("点击max")
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                }
                if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.786 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.088 * NikkeW . " ", NikkeY + 0.786 * NikkeH + 0.146 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
                    AddLog("购买" . Name)
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    while !(ok2 := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("左上角的百货商店"), , 0, , , , , TrueRatio, TrueRatio)) {
                        Confirm
                    }
                }
            }
        } else {
            AddLog(Name . "未找到，跳过购买")
        }
    }
    if Reopen {
        AddLog("存在限时商品")
        UserMove(384, 1244, TrueRatio)
        Send "{WheelDown 5}"
        Sleep 1000
        ShopRecycling
    }
}
;endregion 商店
;region 模拟室
;tag 模拟室
SimulationNormal() {
    EnterToArk
    AddLog("开始任务：模拟室", "Fuchsia")
    AddLog("查找模拟室入口")
    while (ok := FindText(&X, &Y, NikkeX + 0.370 * NikkeW . " ", NikkeY + 0.544 * NikkeH . " ", NikkeX + 0.370 * NikkeW + 0.069 * NikkeW . " ", NikkeY + 0.544 * NikkeH + 0.031 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("模拟室"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("进入模拟室")
        FindText().Click(X, Y - 50 * TrueRatio, "L")
        Sleep 1000
    }
    while true {
        if (ok := FindText(&X, &Y, NikkeX + 0.897 * NikkeW . " ", NikkeY + 0.063 * NikkeH . " ", NikkeX + 0.897 * NikkeW + 0.102 * NikkeW . " ", NikkeY + 0.063 * NikkeH + 0.060 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("结束模拟的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            MsgBox("请手动结束模拟后重新运行该任务")
            Pause
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.442 * NikkeW . " ", NikkeY + 0.535 * NikkeH . " ", NikkeX + 0.442 * NikkeW + 0.118 * NikkeW . " ", NikkeY + 0.535 * NikkeH + 0.101 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("开始模拟的开始"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("点击开始模拟")
            FindText().Click(X + 30 * TrueRatio, Y, "L")
            Sleep 500
            break
        }
        else Confirm
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.501 * NikkeW . " ", NikkeY + 0.830 * NikkeH . " ", NikkeX + 0.501 * NikkeW + 0.150 * NikkeW . " ", NikkeY + 0.830 * NikkeH + 0.070 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("快速模拟的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("点击快速模拟")
        Sleep 500
        FindText().Click(X + 100 * TrueRatio, Y, "L")
    }
    else {
        AddLog("没有解锁快速模拟，跳过该任务", "Olive")
        return
    }
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.474 * NikkeW . " ", NikkeY + 0.521 * NikkeH . " ", NikkeX + 0.474 * NikkeW + 0.052 * NikkeW . " ", NikkeY + 0.521 * NikkeH + 0.028 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("模拟室·不再显示"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("点击不再显示")
        Sleep 500
        FindText().Click(X, Y, "L")
        Sleep 500
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.441 * NikkeW . " ", NikkeY + 0.602 * NikkeH . " ", NikkeX + 0.441 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.602 * NikkeH + 0.050 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("确认快速模拟指南")
            Sleep 500
            FindText().Click(X, Y, "L")
        }
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.428 * NikkeW . " ", NikkeY + 0.883 * NikkeH . " ", NikkeX + 0.428 * NikkeW + 0.145 * NikkeW . " ", NikkeY + 0.883 * NikkeH + 0.069 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("跳过增益效果选择的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
        Sleep 500
        AddLog("跳过增益选择")
        FindText().Click(X + 100 * TrueRatio, Y, "L")
        Sleep 1000
    }
    EnterToBattle
    if BattleActive = 0 {
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.485 * NikkeW . " ", NikkeY + 0.681 * NikkeH . " ", NikkeX + 0.485 * NikkeW + 0.030 * NikkeW . " ", NikkeY + 0.681 * NikkeH + 0.048 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio * 1.25, TrueRatio * 1.25)) {
            FindText().Click(X, Y, "L")
            EnterToBattle
        }
    }
    BattleSettlement
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.364 * NikkeW . " ", NikkeY + 0.323 * NikkeH . " ", NikkeX + 0.364 * NikkeW + 0.272 * NikkeW . " ", NikkeY + 0.323 * NikkeH + 0.558 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("模拟结束的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击模拟结束")
        Sleep 500
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        Sleep 500
        FindText().Click(X + 50 * TrueRatio, Y, "L")
    }
    while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
        Confirm
    }
}
;tag 模拟室超频
SimulationOverClock(mode := "") {
    if mode != "force" {
        if !g_settings["SimulationNormal"] {
            EnterToArk
            AddLog("查找模拟室入口")
            while (ok := FindText(&X, &Y, NikkeX + 0.370 * NikkeW . " ", NikkeY + 0.544 * NikkeH . " ", NikkeX + 0.370 * NikkeW + 0.069 * NikkeW . " ", NikkeY + 0.544 * NikkeH + 0.031 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("模拟室"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("进入模拟室")
                FindText().Click(X, Y - 50 * TrueRatio, "L")
                Sleep 1000
            }
        }
        AddLog("开始任务：模拟室超频", "Fuchsia")
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.453 * NikkeW . " ", NikkeY + 0.775 * NikkeH . " ", NikkeX + 0.453 * NikkeW + 0.095 * NikkeW . " ", NikkeY + 0.775 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红框中的0"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("模拟室超频未完成")
            UserClick(1918, 1637, TrueRatio) ; 点击模拟室超频按钮
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
                Confirm
            }
        }
        else {
            AddLog("模拟室超频已完成！")
            return
        }
    }
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.434 * NikkeW . " ", NikkeY + 0.573 * NikkeH . " ", NikkeX + 0.434 * NikkeW + 0.132 * NikkeW . " ", NikkeY + 0.573 * NikkeH + 0.077 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("BIOS"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.376 * NikkeW . " ", NikkeY + 0.236 * NikkeH . " ", NikkeX + 0.376 * NikkeW + 0.047 * NikkeW . " ", NikkeY + 0.236 * NikkeH + 0.078 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("蓝色的25"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("难度正确")
    }
    else {
        AddLog("难度不是25，跳过", "MAROON")
        return
    }
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.373 * NikkeW . " ", NikkeY + 0.878 * NikkeH . " ", NikkeX + 0.373 * NikkeW + 0.253 * NikkeW . " ", NikkeY + 0.878 * NikkeH + 0.058 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("开始模拟"), , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 3000
    }
    final := false
    while true {
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.365 * NikkeW . " ", NikkeY + 0.552 * NikkeH . " ", NikkeX + 0.365 * NikkeW + 0.269 * NikkeW . " ", NikkeY + 0.552 * NikkeH + 0.239 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("模拟室超频·获得"), , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
        }
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.485 * NikkeW . " ", NikkeY + 0.681 * NikkeH . " ", NikkeX + 0.485 * NikkeW + 0.030 * NikkeW . " ", NikkeY + 0.681 * NikkeH + 0.048 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio * 1.25, TrueRatio * 1.25)) {
            final := True
            AddLog("挑战最后一关")
            FindText().Click(X, Y, "L")
        }
        EnterToBattle
        BattleSettlement
        if final = True {
            break
        }
        AddLog("模拟室超频第" A_Index "关已通关！")
        while true {
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.377 * NikkeW . " ", NikkeY + 0.345 * NikkeH . " ", NikkeX + 0.377 * NikkeW + 0.246 * NikkeW . " ", NikkeY + 0.345 * NikkeH + 0.419 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("模拟室·链接等级"), , , , , , 3, TrueRatio, TrueRatio)) {
                AddLog("获取增益")
                Sleep 1000
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.497 * NikkeW . " ", NikkeY + 0.714 * NikkeH . " ", NikkeX + 0.497 * NikkeW + 0.162 * NikkeW . " ", NikkeY + 0.714 * NikkeH + 0.278 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
            if A_Index > 1 {
                break
            }
        }
        if A_Index > 10 {
            MsgBox("循环次数异常！请勾选「禁止无关人员进入」和「好战型战术」")
            ExitApp
        }
    }
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.364 * NikkeW . " ", NikkeY + 0.323 * NikkeH . " ", NikkeX + 0.364 * NikkeW + 0.272 * NikkeW . " ", NikkeY + 0.323 * NikkeH + 0.558 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("模拟结束的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击模拟结束")
        Sleep 500
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        Sleep 500
        Confirm
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.367 * NikkeW . " ", NikkeY + 0.755 * NikkeH . " ", NikkeX + 0.367 * NikkeW + 0.267 * NikkeW . " ", NikkeY + 0.755 * NikkeH + 0.093 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("不选择的图标"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    Sleep 1000
}
;endregion 模拟室
;region 竞技场
;tag 竞技场收菜
AwardArena() {
    EnterToArk()
    AddLog("开始任务：竞技场收菜", "Fuchsia")
    AddLog("查找奖励")
    foundReward := false
    while (ok := FindText(&X, &Y, NikkeX + 0.568 * NikkeW . " ", NikkeY + 0.443 * NikkeH . " ", NikkeX + 0.568 * NikkeW + 0.015 * NikkeW . " ", NikkeY + 0.443 * NikkeH + 0.031 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("竞技场·收菜的图标"), , , , , , , TrueRatio, TrueRatio)) {
        foundReward := true
        AddLog("点击奖励")
        FindText().Click(X + 30 * TrueRatio, Y, "L")
        Sleep 1000
    }
    if foundReward {
        while (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("点击领取")
            FindText().Click(X + 50 * TrueRatio, Y, "L")
        }
        AddLog("尝试确认并返回方舟大厅")
        while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.014 * NikkeW . " ", NikkeY + 0.026 * NikkeH . " ", NikkeX + 0.014 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.026 * NikkeH + 0.021 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("左上角的方舟"), , , , , , , TrueRatio, TrueRatio)) {
            Confirm
        }
    }
    else AddLog("未找到奖励")
}
;tag 进入竞技场
EnterToArena() {
    if (ok := FindText(&X, &Y, NikkeX + 0.001 * NikkeW . " ", NikkeY + 0.002 * NikkeH . " ", NikkeX + 0.001 * NikkeW + 0.060 * NikkeW . " ", NikkeY + 0.002 * NikkeH + 0.060 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("左上角的竞技场"), , , , , , , TrueRatio, TrueRatio)) {
        return
    }
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.554 * NikkeW . " ", NikkeY + 0.640 * NikkeH . " ", NikkeX + 0.554 * NikkeW + 0.068 * NikkeW . " ", NikkeY + 0.640 * NikkeH + 0.029 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("方舟·竞技场"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击竞技场")
        FindText().Click(X, Y - 50 * TrueRatio, "L")
    }
    while !(ok := FindText(&X, &Y, NikkeX + 0.001 * NikkeW . " ", NikkeY + 0.002 * NikkeH . " ", NikkeX + 0.001 * NikkeW + 0.060 * NikkeW . " ", NikkeY + 0.002 * NikkeH + 0.060 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("左上角的竞技场"), , , , , , , TrueRatio, TrueRatio)) {
        Confirm
    }
    AddLog("进入竞技场")
    Sleep 1000
}
;tag 新人竞技场
ArenaRookie() {
    AddLog("开始任务：新人竞技场", "Fuchsia")
    AddLog("查找新人竞技场")
    while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.372 * NikkeW . " ", NikkeY + 0.542 * NikkeH . " ", NikkeX + 0.372 * NikkeW + 0.045 * NikkeW . " ", NikkeY + 0.542 * NikkeH + 0.024 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("蓝色的新人"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击新人竞技场")
        FindText().Click(X + 20 * TrueRatio, Y, "L")
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("已进入新人竞技场")
            break
        }
        if A_Index > 3 {
            AddLog("新人竞技场未在开放期间，跳过任务")
            return
        }
    }
    AddLog("检测免费次数")
    skip := false
    while True {
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.578 * NikkeW . " ", NikkeY + 0.804 * NikkeH . " ", NikkeX + 0.578 * NikkeW + 0.059 * NikkeW . " ", NikkeY + 0.804 * NikkeH + 0.045 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("免费"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("有免费次数，尝试进入战斗")
            FindText().Click(X, Y + 10 * TrueRatio, "L")
        }
        else {
            AddLog("没有免费次数，尝试返回")
            break
        }
        if skip = false {
            Sleep 1000
            if (ok := FindText(&X, &Y, NikkeX + 0.393 * NikkeW . " ", NikkeY + 0.815 * NikkeH . " ", NikkeX + 0.393 * NikkeW + 0.081 * NikkeW . " ", NikkeY + 0.815 * NikkeH + 0.041 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("ON"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("快速战斗已开启")
                skip := true
            }
            else if (ok := FindText(&X, &Y, NikkeX + 0.393 * NikkeW . " ", NikkeY + 0.815 * NikkeH . " ", NikkeX + 0.393 * NikkeW + 0.081 * NikkeW . " ", NikkeY + 0.815 * NikkeH + 0.041 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("OFF"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("有笨比没开快速战斗，帮忙开了！")
                FindText().Click(X, Y, "L")
            }
        }
        EnterToBattle
        BattleSettlement
        while !(ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
            Confirm
        }
    }
    while (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
        GoBack
        Sleep 1000
    }
    AddLog("已返回竞技场页面")
}
;tag 特殊竞技场
ArenaSpecial() {
    AddLog("开始任务：特殊竞技场", "Fuchsia")
    AddLog("查找特殊竞技场")
    while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.516 * NikkeW . " ", NikkeY + 0.543 * NikkeH . " ", NikkeX + 0.516 * NikkeW + 0.045 * NikkeW . " ", NikkeY + 0.543 * NikkeH + 0.022 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("蓝色的特殊"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击特殊竞技场")
        FindText().Click(X + 20 * TrueRatio, Y, "L")
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("已进入特殊竞技场")
            break
        }
        if A_Index > 3 {
            AddLog("特殊竞技场未在开放期间，跳过任务")
            return
        }
    }
    AddLog("检测免费次数")
    skip := false
    while True {
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.578 * NikkeW . " ", NikkeY + 0.804 * NikkeH . " ", NikkeX + 0.578 * NikkeW + 0.059 * NikkeW . " ", NikkeY + 0.804 * NikkeH + 0.045 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("免费"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("有免费次数，尝试进入战斗")
            FindText().Click(X, Y + 10 * TrueRatio, "L")
            Sleep 1000
        }
        else {
            AddLog("没有免费次数，尝试返回")
            break
        }
        if skip = false {
            Sleep 1000
            if (ok := FindText(&X, &Y, NikkeX + 0.393 * NikkeW . " ", NikkeY + 0.815 * NikkeH . " ", NikkeX + 0.393 * NikkeW + 0.081 * NikkeW . " ", NikkeY + 0.815 * NikkeH + 0.041 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("ON"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("快速战斗已开启")
                skip := true
            }
            else if (ok := FindText(&X, &Y, NikkeX + 0.393 * NikkeW . " ", NikkeY + 0.815 * NikkeH . " ", NikkeX + 0.393 * NikkeW + 0.081 * NikkeW . " ", NikkeY + 0.815 * NikkeH + 0.041 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("OFF"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("有笨比没开快速战斗，帮忙开了！")
                FindText().Click(X, Y, "L")
            }
        }
        EnterToBattle
        BattleSettlement
        while !(ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
            Confirm
        }
    }
    while (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
        GoBack
        Sleep 1000
    }
    AddLog("已返回竞技场页面")
}
;tag 冠军竞技场
ArenaChampion() {
    AddLog("开始任务：冠军竞技场", "Fuchsia")
    AddLog("查找冠军竞技场")
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.567 * NikkeW . " ", NikkeY + 0.621 * NikkeH . " ", NikkeX + 0.567 * NikkeW + 0.075 * NikkeW . " ", NikkeY + 0.621 * NikkeH + 0.047 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        AddLog("已找到红点")
        Sleep 1000
    }
    else {
        AddLog("未在应援期间")
        GoBack
        return
    }
    while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.373 * NikkeW . " ", NikkeY + 0.727 * NikkeH . " ", NikkeX + 0.373 * NikkeW + 0.255 * NikkeW . " ", NikkeY + 0.727 * NikkeH + 0.035 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("内部的紫色应援"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("已找到二级应援文本")
        FindText().Click(X, Y - 200 * TrueRatio, "L")
        Sleep 1000
    }
    else {
        AddLog("未在应援期间")
        GoBack
        Sleep 2000
        return
    }
    while !(ok := FindText(&X, &Y, NikkeX + 0.443 * NikkeW . " ", NikkeY + 0.869 * NikkeH . " ", NikkeX + 0.443 * NikkeW + 0.117 * NikkeW . " ", NikkeY + 0.869 * NikkeH + 0.059 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("晋级赛内部的应援"), , , , , , , TrueRatio, TrueRatio)) {
        Confirm
        Sleep 1000
        if A_Index > 10 {
            AddLog("无法应援", "red")
            GoBack
            Sleep 2000
            return
        }
    }
    AddLog("已找到三级应援文本")
    FindText().Click(X, Y, "L")
    Sleep 4000
    if UserCheckColor([1926], [1020], ["0xF2762B"], TrueRatio) {
        AddLog("左边支持的人多")
        UserClick(1631, 1104, TrueRatio)
    }
    else {
        AddLog("右边支持的人多")
        UserClick(2097, 1096, TrueRatio)
    }
    Sleep 1000
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.503 * NikkeW . " ", NikkeY + 0.837 * NikkeH . " ", NikkeX + 0.503 * NikkeW + 0.096 * NikkeW . " ", NikkeY + 0.837 * NikkeH + 0.058 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    loop 2 {
        GoBack
        Sleep 2000
    }
}
;endregion 竞技场
;region 无限之塔
;tag 企业塔
TowerCompany() {
    EnterToArk
    AddLog("开始任务：企业塔", "Fuchsia")
    while (ok := FindText(&X, &Y, NikkeX + 0.539 * NikkeW . " ", NikkeY + 0.373 * NikkeH . " ", NikkeX + 0.539 * NikkeW + 0.066 * NikkeW . " ", NikkeY + 0.373 * NikkeH + 0.031 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔的无限"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("进入无限之塔")
        FindText().Click(X, Y - 50 * TrueRatio, "L")
    }
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("已进入无限之塔")
        Sleep 1000
    }
    else {
        AddLog("进入无限之塔失败，跳过任务", "MAROON")
        return
    }
    TowerArray := []
    loop 4 {
        if (ok := FindText(&X, &Y, NikkeX + 0.356 * NikkeW + 270 * TrueRatio * (A_Index - 1) . " ", NikkeY + 0.521 * NikkeH . " ", NikkeX + 0.356 * NikkeW + 0.070 * NikkeW + 270 * TrueRatio * (A_Index - 1) . " ", NikkeY + 0.521 * NikkeH + 0.034 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔·OPEN"), , , , , , , TrueRatio, TrueRatio)) {
            Status := "开放中"
        }
        else Status := "未开放"
        switch A_Index {
            case 1: Tower := "极乐净土之塔"
            case 2: Tower := "米西利斯之塔"
            case 3: Tower := "泰特拉之塔"
            case 4: Tower := "朝圣者/超标准之塔"
        }
        if Status = "开放中" {
            TowerArray.Push(Tower)
            AddLog(Tower "-" Status, "Green")
        }
        else AddLog(Tower "-" Status, "Gray")
    }
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.357 * NikkeW . " ", NikkeY + 0.518 * NikkeH . " ", NikkeX + 0.357 * NikkeW + 0.287 * NikkeW . " ", NikkeY + 0.518 * NikkeH + 0.060 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔·OPEN"), , , , , , 5, TrueRatio, TrueRatio)) {
        count := ok.Length
        Sleep 1000
        FindText().Click(X, Y + 100 * TrueRatio, "L")
        Sleep 1000
        ; 添加变量跟踪当前关卡
        TowerIndex := 1
        ; 修改循环条件
        while (TowerIndex <= count) {
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.426 * NikkeW . " ", NikkeY + 0.405 * NikkeH . " ", NikkeX + 0.426 * NikkeW + 0.025 * NikkeW . " ", NikkeY + 0.405 * NikkeH + 0.024 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("STAGE"), , , , , , , TrueRatio, TrueRatio)) {
                Tower := TowerArray[TowerIndex]
                AddLog("已进入" Tower "的内部")
                Sleep 1000
                FindText().Click(X + 100 * TrueRatio, Y, "L")
                EnterToBattle
                BattleSettlement
                ; 成功完成当前关卡后，才增加索引
                TowerIndex++
            }
            else {
                RefuseSale
            }
            ; 检查是否已完成所有关卡
            if (TowerIndex > count) {
                break
            }
            ; 点向右的箭头进入下一关
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.569 * NikkeW . " ", NikkeY + 0.833 * NikkeH . " ", NikkeX + 0.569 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.833 * NikkeH + 0.069 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔·向右的箭头"), , , , , , , TrueRatio, TrueRatio)) {
                Sleep 3000
                FindText().Click(X, Y, "L")
            }
            Sleep 1000
        }
        AddLog("所有塔都打过了")
    }
    loop 2 {
        GoBack
        Sleep 2000
    }
}
;tag 通用塔
TowerUniversal() {
    EnterToArk
    AddLog("开始任务：通用塔", "Fuchsia")
    while (ok := FindText(&X, &Y, NikkeX + 0.539 * NikkeW . " ", NikkeY + 0.373 * NikkeH . " ", NikkeX + 0.539 * NikkeW + 0.066 * NikkeW . " ", NikkeY + 0.373 * NikkeH + 0.031 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔的无限"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("进入无限之塔")
        FindText().Click(X, Y - 50 * TrueRatio, "L")
    }
    while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.548 * NikkeW . " ", NikkeY + 0.312 * NikkeH . " ", NikkeX + 0.548 * NikkeW + 0.096 * NikkeW . " ", NikkeY + 0.312 * NikkeH + 0.172 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("塔内的无限之塔"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击塔内的无限之塔")
        FindText().Click(X, Y, "L")
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.426 * NikkeW . " ", NikkeY + 0.405 * NikkeH . " ", NikkeX + 0.426 * NikkeW + 0.025 * NikkeW . " ", NikkeY + 0.405 * NikkeH + 0.024 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("STAGE"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("已进入塔的内部")
        FindText().Click(X + 100 * TrueRatio, Y, "L")
        EnterToBattle
        BattleSettlement
        ; 点向右的箭头
        if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.569 * NikkeW . " ", NikkeY + 0.833 * NikkeH . " ", NikkeX + 0.569 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.833 * NikkeH + 0.069 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔·向右的箭头"), , , , , , , TrueRatio, TrueRatio)) {
            Sleep 3000
            FindText().Click(X, Y, "L")
        }
        ; 循环等待箭头消失或处理广告
        while true {
            if (ok := FindText(&X := "wait0", &Y := 3, NikkeX + 0.569 * NikkeW . " ", NikkeY + 0.833 * NikkeH . " ", NikkeX + 0.569 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.833 * NikkeH + 0.069 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔·向右的箭头"), , , , , , , TrueRatio, TrueRatio)) {
                break
            }
            RefuseSale
            Sleep 1000
            if (ok := FindText(&X, &Y, NikkeX + 0.569 * NikkeW . " ", NikkeY + 0.833 * NikkeH . " ", NikkeX + 0.569 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.833 * NikkeH + 0.069 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔·向右的箭头"), , , , , , , TrueRatio, TrueRatio)) {
                Sleep 3000
                FindText().Click(X, Y, "L")
            }
        }
    }
}
;endregion 无限之塔
;region 拦截战
;tag 普通拦截
InterceptionNormal() {
    EnterToArk
    AddLog("开始任务：普通拦截", "Fuchsia")
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.401 * NikkeW . " ", NikkeY + 0.813 * NikkeH . " ", NikkeX + 0.401 * NikkeW + 0.069 * NikkeW . " ", NikkeY + 0.813 * NikkeH + 0.028 * NikkeH . " ", 0.45 * PicTolerance, 0.45 * PicTolerance, FindText().PicLib("拦截战"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("进入拦截战")
        FindText().Click(X, Y - 50 * TrueRatio, "L")
        Sleep 1000
    }
    Confirm
    UserClick(2120, 1956, TrueRatio) ; 点击普通拦截
    Sleep 1000
    loop 3 {
        Confirm
    }
    AddLog("已进入普通拦截界面")
    switch g_numeric_settings["InterceptionBossNormal"] {
        case 1:
            UserClick(1623, 953, TrueRatio)
            sleep 1000
            AddLog("已选择Level D")
        case 2:
            UserClick(2425, 1120, TrueRatio)
            sleep 1000
            AddLog("已选择Level S")
        case 3:
            UserClick(2136, 1675, TrueRatio)
            sleep 1000
            AddLog("已选择特殊目标拦截战")
        default:
            MsgBox "BOSS选择错误！"
            Pause
    }
    Sleep 1000
    while True {
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.826 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.145 * NikkeW . " ", NikkeY + 0.826 * NikkeH + 0.065 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("拦截战·快速战斗的图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("已激活快速战斗")
            Sleep 500
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            Sleep 500
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            Sleep 500
        }
        else if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.503 * NikkeW . " ", NikkeY + 0.879 * NikkeH . " ", NikkeX + 0.503 * NikkeW + 0.150 * NikkeW . " ", NikkeY + 0.879 * NikkeH + 0.102 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("拦截战·进入战斗的进"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("未激活快速战斗，尝试普通战斗")
            FindText().Click(X, Y, "L")
            Sleep 1000
            Skipping
        }
        else {
            AddLog("拦截次数已耗尽", "MAROON")
            break
        }
        modes := []
        if g_settings["InterceptionRedCircle"]
            modes.Push("RedCircle")
        if g_settings["InterceptionScreenshot"]
            modes.Push("Screenshot")
        if g_settings["InterceptionExit7"] and g_numeric_settings["UserLevel"] >= 3
            modes.Push("Exit7")
        global BattleActive := 1
        if g_settings["InterceptionRedCircle"] or g_settings["InterceptionExit7"] {
            AddLog("有概率误判，请谨慎开启该功能", "MAROON")
        }
        BattleSettlement(modes*)
        Sleep 2000
    }
}
;tag 异常拦截
InterceptionAnomaly() {
    EnterToArk
    AddLog("开始任务：异常拦截", "Fuchsia")
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.401 * NikkeW . " ", NikkeY + 0.813 * NikkeH . " ", NikkeX + 0.401 * NikkeW + 0.069 * NikkeW . " ", NikkeY + 0.813 * NikkeH + 0.028 * NikkeH . " ", 0.45 * PicTolerance, 0.45 * PicTolerance, FindText().PicLib("拦截战"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("进入拦截战")
        FindText().Click(X, Y - 50 * TrueRatio, "L")
        Sleep 1000
    }
    Confirm
    while !(ok := FindText(&X, &Y, NikkeX + 0.580 * NikkeW . " ", NikkeY + 0.956 * NikkeH . " ", NikkeX + 0.580 * NikkeW + 0.074 * NikkeW . " ", NikkeY + 0.956 * NikkeH + 0.027 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红字的异常"), , , , , , , TrueRatio, TrueRatio)) {
        Confirm
        if A_Index > 20 {
            MsgBox("异常个体拦截战未解锁！", "MAROON")
            Pause
        }
    }
    AddLog("已进入异常拦截界面")
    loop 5 {
        t := A_Index
        switch g_numeric_settings["InterceptionBoss"] {
            case 1:
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.723 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.723 * NikkeH + 0.061 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("克拉肯的克"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("已选择BOSS克拉肯")
                    break
                }
            case 2:
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.723 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.723 * NikkeH + 0.061 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("镜像容器的镜"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("已选择BOSS镜像容器")
                    break
                }
            case 3:
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.723 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.723 * NikkeH + 0.061 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("茵迪维利亚的茵"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("已选择BOSS茵迪维利亚")
                    break
                }
            case 4:
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.723 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.723 * NikkeH + 0.061 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("过激派的过"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("已选择BOSS过激派")
                    break
                }
            case 5:
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.723 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.723 * NikkeH + 0.061 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("死神的死"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("已选择BOSS死神")
                    break
                }
            default:
                MsgBox "BOSS选择错误！"
                Pause
        }
        AddLog("非对应BOSS，尝试切换")
        if (ok := FindText(&X, &Y, NikkeX + 0.584 * NikkeW . " ", NikkeY + 0.730 * NikkeH . " ", NikkeX + 0.584 * NikkeW + 0.023 * NikkeW . " ", NikkeY + 0.730 * NikkeH + 0.039 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("异常拦截·向右的箭头"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X + 10 * TrueRatio, Y, "L")
        }
        Sleep 500
    }
    FindText().Click(X, Y + 100 * TrueRatio, "L")
    Sleep 500
    Confirm
    if t > 1 {
        Sleep 2000
        switch g_numeric_settings["InterceptionBoss"] {
            case 1:
                UserClick(1858, 1470, TrueRatio)
                AddLog("选中队伍1")
            case 2:
                UserClick(2014, 1476, TrueRatio)
                AddLog("选中队伍2")
            case 3:
                UserClick(2140, 1482, TrueRatio)
                AddLog("选中队伍3")
            case 4:
                UserClick(2276, 1446, TrueRatio)
                AddLog("选中队伍4")
            case 5:
                UserClick(2414, 1474, TrueRatio)
                AddLog("选中队伍5")
            default:
                MsgBox "BOSS选择错误！"
                Pause
        }
    }
    Sleep 1000
    while True {
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.826 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.145 * NikkeW . " ", NikkeY + 0.826 * NikkeH + 0.065 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("拦截战·快速战斗的图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("已激活快速战斗")
            Sleep 500
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            Sleep 500
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            Sleep 500
        }
        else if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.503 * NikkeW . " ", NikkeY + 0.879 * NikkeH . " ", NikkeX + 0.503 * NikkeW + 0.150 * NikkeW . " ", NikkeY + 0.879 * NikkeH + 0.102 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("拦截战·进入战斗的进"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("未激活快速战斗，尝试普通战斗")
            FindText().Click(X, Y, "L")
            Sleep 1000
            Skipping
        }
        else {
            AddLog("拦截次数已耗尽", "MAROON")
            break
        }
        modes := []
        if g_settings["InterceptionRedCircle"]
            modes.Push("RedCircle")
        if g_settings["InterceptionScreenshot"]
            modes.Push("Screenshot")
        if g_settings["InterceptionExit7"] and g_numeric_settings["UserLevel"] >= 3
            modes.Push("Exit7")
        global BattleActive := 1
        if g_settings["InterceptionRedCircle"] or g_settings["InterceptionExit7"] {
            AddLog("有概率误判，请谨慎开启该功能", "MAROON")
        }
        BattleSettlement(modes*)
        Sleep 2000
    }
}
;endregion 拦截战
;region 前哨基地
;tag 前哨基地收菜
AwardOutpost() {
    AddLog("开始任务：前哨基地收菜", "Fuchsia")
    EnterToOutpost()
    while true {
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.884 * NikkeW . " ", NikkeY + 0.904 * NikkeH . " ", NikkeX + 0.884 * NikkeW + 0.114 * NikkeW . " ", NikkeY + 0.904 * NikkeH + 0.079 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("溢出资源的图标"), , , , , , , TrueRatio, TrueRatio)) {
            Sleep 1000
            AddLog("点击右下角资源")
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.527 * NikkeW . " ", NikkeY + 0.832 * NikkeH . " ", NikkeX + 0.527 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.832 * NikkeH + 0.041 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("获得奖励的图标"), , , , , , , TrueRatio, TrueRatio)) {
            break
        }
    }
    if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.490 * NikkeW . " ", NikkeY + 0.820 * NikkeH . " ", NikkeX + 0.490 * NikkeW + 0.010 * NikkeW . " ", NikkeY + 0.820 * NikkeH + 0.017 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        while (ok := FindText(&X, &Y, NikkeX + 0.490 * NikkeW . " ", NikkeY + 0.820 * NikkeH . " ", NikkeX + 0.490 * NikkeW + 0.010 * NikkeW . " ", NikkeY + 0.820 * NikkeH + 0.017 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X - 50 * TrueRatio, Y + 50 * TrueRatio, "L")
            AddLog("点击免费歼灭红点")
            Sleep 1000
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.465 * NikkeW . " ", NikkeY + 0.738 * NikkeH . " ", NikkeX + 0.465 * NikkeW + 0.163 * NikkeW . " ", NikkeY + 0.738 * NikkeH + 0.056 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("进行歼灭的歼灭"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击进行免费一举歼灭")
            FindText().Click(X, Y, "L")
            Sleep 1000
            while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.503 * NikkeW . " ", NikkeY + 0.825 * NikkeH . " ", NikkeX + 0.503 * NikkeW + 0.121 * NikkeW . " ", NikkeY + 0.825 * NikkeH + 0.059 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("获得奖励的图标"), , , , , , , TrueRatio, TrueRatio)) {
                Confirm
                Sleep 1000
            }
        }
    }
    else AddLog("没有免费一举歼灭", "MAROON")
    AddLog("尝试常规收菜")
    if (ok := FindText(&X, &Y, NikkeX + 0.503 * NikkeW . " ", NikkeY + 0.825 * NikkeH . " ", NikkeX + 0.503 * NikkeW + 0.121 * NikkeW . " ", NikkeY + 0.825 * NikkeH + 0.059 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("获得奖励的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击收菜")
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    else AddLog("没有可收取的资源", "MAROON")
    AddLog("尝试返回前哨基地主页面")
    while !(ok := FindText(&X, &Y, NikkeX + 0.884 * NikkeW . " ", NikkeY + 0.904 * NikkeH . " ", NikkeX + 0.884 * NikkeW + 0.114 * NikkeW . " ", NikkeY + 0.904 * NikkeH + 0.079 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("溢出资源的图标"), , , , , , , TrueRatio, TrueRatio)) {
        Confirm
    }
    AddLog("已返回前哨基地主页面")
    if g_settings["AwardOutpostDispatch"] ;派遣
        AwardOutpostDispatch()
    BackToHall(True)
}
;tag 派遣
AwardOutpostDispatch() {
    AddLog("开始任务：派遣委托", "Fuchsia")
    AddLog("查找派遣公告栏")
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.500 * NikkeW . " ", NikkeY + 0.901 * NikkeH . " ", NikkeX + 0.500 * NikkeW + 0.045 * NikkeW . " ", NikkeY + 0.901 * NikkeH + 0.092 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("派遣公告栏的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击派遣公告栏")
        FindText().Click(X, Y, "L")
        Sleep 1000
        while (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.547 * NikkeW . " ", NikkeY + 0.807 * NikkeH . " ", NikkeX + 0.547 * NikkeW + 0.087 * NikkeW . " ", NikkeY + 0.807 * NikkeH + 0.066 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("获得奖励的图标"), , , , , , , TrueRatio * 0.8, TrueRatio * 0.8)) {
            AddLog("点击全部领取")
            FindText().Click(X + 100 * TrueRatio, Y, "L")
        }
        else AddLog("没有可领取的奖励", "MAROON")
        while !(ok := FindText(&X, &Y, NikkeX + 0.378 * NikkeW . " ", NikkeY + 0.137 * NikkeH . " ", NikkeX + 0.378 * NikkeW + 0.085 * NikkeW . " ", NikkeY + 0.137 * NikkeH + 0.040 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("派遣公告栏最左上角的派遣"), , , , , , , TrueRatio, TrueRatio)) {
            UserClick(1595, 1806, TrueRatio)
            Sleep 500
        }
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.456 * NikkeW . " ", NikkeY + 0.807 * NikkeH . " ", NikkeX + 0.456 * NikkeW + 0.087 * NikkeW . " ", NikkeY + 0.807 * NikkeH + 0.064 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("蓝底白色右箭头"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试全部派遣")
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
        else AddLog("没有可进行的派遣")
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.501 * NikkeW . " ", NikkeY + 0.814 * NikkeH . " ", NikkeX + 0.501 * NikkeW + 0.092 * NikkeW . " ", NikkeY + 0.814 * NikkeH + 0.059 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("白底蓝色右箭头"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击全部派遣")
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
    }
    else AddLog("派遣公告栏未找到！")
}
;endregion 前哨基地
;region 咨询
;tag 好感度咨询
AwardAdvise() {
    while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.009 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.069 * NikkeW . " ", NikkeY + 0.009 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , , , , , , TrueRatio, TrueRatio)) {
        UserClick(1493, 1949, TrueRatio)
        AddLog("点击妮姬的图标，进入好感度咨询")
    }
    Sleep 2000
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.818 * NikkeW . " ", NikkeY + 0.089 * NikkeH . " ", NikkeX + 0.818 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.089 * NikkeH + 0.056 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("咨询的图标"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
        if A_Index > 10 {
            MsgBox("未找到好感度咨询图标")
            Pause
        }
    }
    AddLog("已进入好感度咨询界面")
    ; 花絮鉴赏会
    if g_settings["AwardAppreciation"] {
        AwardAppreciation
    }
    while (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.118 * NikkeW . " ", NikkeY + 0.356 * NikkeH . " ", NikkeX + 0.118 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.356 * NikkeH + 0.022 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("》》》"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        AddLog("点击左上角的妮姬")
        Sleep 500
    }
    AddLog("开始任务：妮姬咨询", "Fuchsia")
    while true {
        if (ok := FindText(&X, &Y, NikkeX + 0.572 * NikkeW . " ", NikkeY + 0.835 * NikkeH . " ", NikkeX + 0.572 * NikkeW + 0.008 * NikkeW . " ", NikkeY + 0.835 * NikkeH + 0.013 * NikkeH . " ", 0.25 * PicTolerance, 0.25 * PicTolerance, FindText().PicLib("灰色的咨询次数0"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("咨询次数已耗尽", "MAROON")
            break
        }
        if A_Index > 20 {
            AddLog("妮姬咨询任务已超过20次，结束任务", "MAROON")
            break
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.637 * NikkeW . " ", NikkeY + 0.672 * NikkeH . " ", NikkeX + 0.637 * NikkeW + 0.004 * NikkeW . " ", NikkeY + 0.672 * NikkeH + 0.013 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红色的20进度"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("图鉴已满")
            if (ok := FindText(&X, &Y, NikkeX + 0.541 * NikkeW . " ", NikkeY + 0.637 * NikkeH . " ", NikkeX + 0.541 * NikkeW + 0.030 * NikkeW . " ", NikkeY + 0.637 * NikkeH + 0.028 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("咨询·MAX"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("好感度也已满，跳过")
                if (ok := FindText(&X, &Y, NikkeX + 0.361 * NikkeW . " ", NikkeY + 0.512 * NikkeH . " ", NikkeX + 0.361 * NikkeW + 0.026 * NikkeW . " ", NikkeY + 0.512 * NikkeH + 0.046 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("红色的收藏图标"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    AddLog("取消收藏该妮姬")
                }
            }
            else if (ok := FindText(&X, &Y, NikkeX + 0.501 * NikkeW . " ", NikkeY + 0.726 * NikkeH . " ", NikkeX + 0.501 * NikkeW + 0.130 * NikkeW . " ", NikkeY + 0.726 * NikkeH + 0.059 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("快速咨询的图标"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("尝试快速咨询")
                FindText().Click(X, Y, "L")
                Sleep 1000
                if (ok := FindText(&X, &Y, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.600 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.125 * NikkeW . " ", NikkeY + 0.600 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    AddLog("已咨询" A_Index "次", "GREEN")
                    Sleep 1000
                }
            }
            else AddLog("该妮姬已咨询")
        }
        else {
            AddLog("图鉴未满")
            if (ok := FindText(&X, &Y, NikkeX + 0.502 * NikkeW . " ", NikkeY + 0.780 * NikkeH . " ", NikkeX + 0.502 * NikkeW + 0.131 * NikkeW . " ", NikkeY + 0.780 * NikkeH + 0.088 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("咨询的咨"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("尝试普通咨询")
                FindText().Click(X + 50 * TrueRatio, Y, "L")
                Sleep 1000
                if (ok := FindText(&X, &Y, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.600 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.125 * NikkeW . " ", NikkeY + 0.600 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    AddLog("已咨询" A_Index "次")
                }
                Sleep 1000
                while true {
                    AddLog("随机点击对话框")
                    UserClick(1894, 1440, TrueRatio) ;点击1号位默认位置
                    Sleep 200
                    UserClick(1903, 1615, TrueRatio) ;点击2号位默认位置
                    Sleep 200
                    Send "{]}" ;尝试跳过
                    Sleep 200
                    if A_Index > 5 and (ok := FindText(&X, &Y, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.009 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.069 * NikkeW . " ", NikkeY + 0.009 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , , , , , , TrueRatio, TrueRatio)) {
                        break
                    }
                }
                Sleep 1000
            }
            else {
                AddLog("该妮姬已咨询")
            }
        }
        while !(ok := FindText(&X, &Y, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.009 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.069 * NikkeW . " ", NikkeY + 0.009 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("确认咨询结算")
            Confirm
        }
        if g_settings["AwardAdviseAward"] and g_numeric_settings["UserLevel"] >= 3 {
            ; 自动观看新花絮并领取奖励
            if (ok := FindText(&X, &Y, NikkeX + 0.643 * NikkeW . " ", NikkeY + 0.480 * NikkeH . " ", NikkeX + 0.643 * NikkeW + 0.014 * NikkeW . " ", NikkeY + 0.480 * NikkeH + 0.026 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , 1.2 * TrueRatio, 1.2 * TrueRatio)) {
                AddLog("点击红点")
                FindText().Click(X, Y, "L")
                Sleep 2000
                while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.617 * NikkeW . " ", NikkeY + 0.400 * NikkeH . " ", NikkeX + 0.617 * NikkeW + 0.026 * NikkeW . " ", NikkeY + 0.400 * NikkeH + 0.512 * NikkeH . " ", 0.25 * PicTolerance, 0.25 * PicTolerance, FindText().PicLib("红点"), , , , , , 1, TrueRatio, TrueRatio)) {
                    AddLog("播放新的片段")
                    FindText().Click(X, Y, "L")
                    Sleep 3000
                    Send "{]}" ;尝试跳过
                    Sleep 3000
                    Confirm
                    Sleep 1000
                    GoBack
                    UserMove(1906, 1026, TrueRatio)
                    Send "{WheelDown 3}"
                    Sleep 1000
                }
                loop 3 {
                    Confirm
                    Sleep 500
                }
            }
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.970 * NikkeW . " ", NikkeY + 0.403 * NikkeH . " ", NikkeX + 0.970 * NikkeW + 0.024 * NikkeW . " ", NikkeY + 0.403 * NikkeH + 0.067 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("咨询·向右的图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("下一个妮姬")
            FindText().Click(X - 30 * TrueRatio, Y, "L")
            Sleep 1000
        }
    }
    BackToHall
}
;tag 花絮鉴赏会
AwardAppreciation() {
    AddLog("开始任务：花絮鉴赏会", "Fuchsia")
    Sleep 1000
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.979 * NikkeW . " ", NikkeY + 0.903 * NikkeH . " ", NikkeX + 0.979 * NikkeW + 0.020 * NikkeW . " ", NikkeY + 0.903 * NikkeH + 0.034 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X - 50 * TrueRatio, Y + 50 * TrueRatio, "L")
        AddLog("点击花絮")
    }
    else {
        AddLog("未找到花絮鉴赏会的N图标", "MAROON")
        return
    }
    while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.363 * NikkeW . " ", NikkeY + 0.550 * NikkeH . " ", NikkeX + 0.363 * NikkeW + 0.270 * NikkeW . " ", NikkeY + 0.550 * NikkeH + 0.316 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("EPI"), , , , , , 1, TrueRatio, TrueRatio)) {
        AddLog("播放第一个片段")
        FindText().Click(X, Y, "L")
    }
    while true {
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.559 * NikkeW . " ", NikkeY + 0.893 * NikkeH . " ", NikkeX + 0.559 * NikkeW + 0.070 * NikkeW . " ", NikkeY + 0.893 * NikkeH + 0.062 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("领取"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("领取奖励")
            FindText().Click(X, Y, "L")
            sleep 500
            FindText().Click(X, Y, "L")
            sleep 500
            FindText().Click(X, Y, "L")
            sleep 500
            break
        }
        else {
            AddLog("播放下一个片段")
            Send "{]}" ;尝试跳过
            if (ok := FindText(&X, &Y, NikkeX + 0.499 * NikkeW . " ", NikkeY + 0.513 * NikkeH . " ", NikkeX + 0.499 * NikkeW + 0.140 * NikkeW . " ", NikkeY + 0.513 * NikkeH + 0.072 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("播放"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
            }
        }
    }
    while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.118 * NikkeW . " ", NikkeY + 0.356 * NikkeH . " ", NikkeX + 0.118 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.356 * NikkeH + 0.022 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("》》》"), , , , , , , TrueRatio, TrueRatio)) {
        Confirm
    }
}
;endregion 咨询
;region 好友点数收取
AwardFriendPoint() {
    AddLog("开始任务：好友点数", "Fuchsia")
    while (ok := FindText(&X, &Y, NikkeX + 0.957 * NikkeW . " ", NikkeY + 0.216 * NikkeH . " ", NikkeX + 0.957 * NikkeW + 0.032 * NikkeW . " ", NikkeY + 0.216 * NikkeH + 0.111 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("好友的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击好友")
        FindText().Click(X, Y, "L")
        Sleep 2000
    }
    while (ok := FindText(&X, &Y, NikkeX + 0.628 * NikkeW . " ", NikkeY + 0.822 * NikkeH . " ", NikkeX + 0.628 * NikkeW + 0.010 * NikkeW . " ", NikkeY + 0.822 * NikkeH + 0.017 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击赠送")
        FindText().Click(X - 50 * TrueRatio, Y + 50 * TrueRatio, "L")
        Sleep 2000
    }
    else {
        AddLog("好友点数已执行")
    }
    BackToHall
}
;endregion 好友点数收取
;region 邮箱收取
AwardMail() {
    AddLog("开始任务：邮箱", "Fuchsia")
    while (ok := FindText(&X, &Y, NikkeX + 0.962 * NikkeW . " ", NikkeY + 0.017 * NikkeH . " ", NikkeX + 0.962 * NikkeW + 0.008 * NikkeW . " ", NikkeY + 0.017 * NikkeH + 0.015 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击邮箱")
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    else {
        AddLog("邮箱已领取")
        return
    }
    while (ok := FindText(&X, &Y, NikkeX + 0.519 * NikkeW . " ", NikkeY + 0.817 * NikkeH . " ", NikkeX + 0.519 * NikkeW + 0.110 * NikkeW . " ", NikkeY + 0.817 * NikkeH + 0.063 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("白底蓝色右箭头"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击全部领取")
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        Sleep 2000
    }
    BackToHall
}
;endregion 邮箱收取
;region 方舟排名奖励
;tag 排名奖励
AwardRanking() {
    AddLog("开始任务：方舟排名奖励", "Fuchsia")
    EnterToArk()
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.973 * NikkeW . " ", NikkeY + 0.134 * NikkeH . " ", NikkeX + 0.973 * NikkeW + 0.020 * NikkeW . " ", NikkeY + 0.134 * NikkeH + 0.083 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X - 30 * TrueRatio, Y + 30 * TrueRatio, "L")
    }
    else {
        AddLog("没有可领取的排名奖励，跳过")
        BackToHall
        return
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.909 * NikkeW . " ", NikkeY + 0.915 * NikkeH . " ", NikkeX + 0.909 * NikkeW + 0.084 * NikkeW . " ", NikkeY + 0.915 * NikkeH + 0.056 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("获得奖励的图标"), , , , , , , TrueRatio * 0.8, TrueRatio * 0.8)) {
        Sleep 1000
        AddLog("点击全部领取")
        FindText().Click(X, Y - 30 * TrueRatio, "L")
        Sleep 1000
    }
    BackToHall
}
;endregion 方舟排名奖励
;region 每日任务收取
AwardDaily() {
    AddLog("开始任务：每日任务收取", "Fuchsia")
    while (ok := FindText(&X, &Y, NikkeX + 0.874 * NikkeW . " ", NikkeY + 0.073 * NikkeH . " ", NikkeX + 0.874 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.073 * NikkeH + 0.019 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        AddLog("点击每日任务图标")
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.466 * NikkeW . " ", NikkeY + 0.093 * NikkeH . " ", NikkeX + 0.466 * NikkeW + 0.068 * NikkeW . " ", NikkeY + 0.093 * NikkeH + 0.035 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("每日任务·MISSION"), , , , , , , TrueRatio, TrueRatio)) {
            while !(ok := FindText(&X, &Y, NikkeX + 0.548 * NikkeW . " ", NikkeY + 0.864 * NikkeH . " ", NikkeX + 0.548 * NikkeW + 0.093 * NikkeW . " ", NikkeY + 0.864 * NikkeH + 0.063 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的全部"), , , , , , , TrueRatio, TrueRatio)) {
                UserClick(2412, 1905, TrueRatio)
                AddLog("点击全部领取")
                Sleep 2000
            }
            Sleep 1000
            BackToHall
        }
    }
    else {
        AddLog("每日任务奖励已领取")
        return
    }
}
;endregion 每日任务收取
;region 通行证收取
;tag 查找通行证
AwardPass() {
    AddLog("开始任务：通行证", "Fuchsia")
    t := 0
    while true {
        if (ok := FindText(&X, &Y, NikkeX + 0.879 * NikkeW . " ", NikkeY + 0.150 * NikkeH . " ", NikkeX + 0.879 * NikkeW + 0.019 * NikkeW . " ", NikkeY + 0.150 * NikkeH + 0.037 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("通行证·3+"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("3+通行证模式")
            FindText().Click(X, Y, "L")
            Sleep 1000
            ; 检查红点并执行通行证
            if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.985 * NikkeW . " ", NikkeY + 0.124 * NikkeH . " ", NikkeX + 0.985 * NikkeW + 0.015 * NikkeW . " ", NikkeY + 0.124 * NikkeH + 0.261 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X - 50 * TrueRatio, Y + 50 * TrueRatio, "L")
                t := t + 1
                AddLog("执行第" t "个通行证")
                OneAwardPass()
                BackToHall()
                continue
            }
        }
        else if (ok := FindText(&X, &Y, NikkeX + 0.878 * NikkeW . " ", NikkeY + 0.151 * NikkeH . " ", NikkeX + 0.878 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.151 * NikkeH + 0.036 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("通行证·2"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("2通行证模式")
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
        else {
            AddLog("1通行证模式")
        }
        ; 检查红点并执行通行证
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.982 * NikkeW . " ", NikkeY + 0.126 * NikkeH . " ", NikkeX + 0.982 * NikkeW + 0.016 * NikkeW . " ", NikkeY + 0.126 * NikkeH + 0.032 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X - 50 * TrueRatio, Y + 50 * TrueRatio, "L")
            t := t + 1
            AddLog("执行第" t "个通行证")
            OneAwardPass()
            BackToHall()
            continue
        }
        ; 检测是否有其他未完成的通行证
        if (ok := FindText(&X, &Y, NikkeX + 0.890 * NikkeW . " ", NikkeY + 0.149 * NikkeH . " ", NikkeX + 0.890 * NikkeW + 0.010 * NikkeW . " ", NikkeY + 0.149 * NikkeH + 0.016 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio * 0.8, TrueRatio * 0.8)) {
            FindText().Click(X, Y, "L")
        }
        else {
            AddLog("通行证已全部收取")
            Confirm
            break
        }
    }
}
;tag 执行一次通行证
OneAwardPass() {
    Sleep 3000
    loop 2 {
        if A_Index = 1 {
            UserClick(2184, 670, TrueRatio) ;点任务
            Sleep 1000
        }
        if A_Index = 2 {
            UserClick(1642, 670, TrueRatio) ;点奖励
            Sleep 1000
        }
        while !(ok := FindText(&X, &Y, NikkeX + 0.429 * NikkeW . " ", NikkeY + 0.903 * NikkeH . " ", NikkeX + 0.429 * NikkeW + 0.143 * NikkeW . " ", NikkeY + 0.903 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的全部"), , , , , , , TrueRatio, TrueRatio)) and !(ok := FindText(&X, &Y, NikkeX + 0.429 * NikkeW . " ", NikkeY + 0.903 * NikkeH . " ", NikkeX + 0.429 * NikkeW + 0.143 * NikkeW . " ", NikkeY + 0.903 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("SP灰色的全部"), , , , , , , TrueRatio, TrueRatio)) {
            loop 3 {
                UserClick(2168, 2020, TrueRatio) ;点领取
                Sleep 500
            }
        }
    }
    GoBack()
}
;endregion 通行证收取
;region 招募
;tag 每日免费招募
AwardFreeRecruit() {
    AddLog("开始任务：每日免费招募", "Fuchsia")
    Text每天免费 := "|<每天免费>*156$64.wzzzzzbzz9zU0s03w1z00S01U0DU7zmNnzzyTwQzk0601ztzU07Abs07zby00Q00t6S00QttwNna9s01nba3aE01z3z00Q03167wDw03s0DgNzUTz9zbAw03wMzsbSNnk07Xky6Qt0TztsTVUs20kTyDbzbDUMTsU"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2 * PicTolerance, 0.2 * PicTolerance, Text每天免费, , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        AddLog("进入招募页面")
        Sleep 1000
        while (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2 * PicTolerance, 0.2 * PicTolerance, Text每天免费, , 0, , , , , TrueRatio, TrueRatio)) {
            Text每日免费 := "|<每日免费>*122$73.szzs07z3zw00s01w01z07y00A00y00z03zU04TzzDwT3XzU0001zbyD007k0200Dnz7U01s00U07szXkkkw00MlXw01wQwS3W0E0y00y00C1l800D7wT007U04007byDk07s03a6Tnz7z0zwtll07tzXz2TyQss01w01z3DDA0w00y00y3X7UEDz1z00S3k30S3zVzbzDjw3Vzt"
            if (ok := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, Text每日免费, , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("进行招募")
                FindText().Click(X, Y, "L")
                Recruit()
            }
            else {
                ;点击翻页
                Sleep 1000
                UserClick(3774, 1147, TrueRatio)
                Sleep 1000
            }
        }
    }
    UserClick(1929, 1982, TrueRatio) ;点击大厅
}
;endregion 招募
;region 协同作战
;tag 协同作战入口
AwardCooperate() {
    AddLog("开始任务：协同作战", "Fuchsia")
    ;把鼠标移动到活动栏
    UserMove(150, 257, TrueRatio)
    while true {
        if (ok := FindText(&X := "wait", &Y := 0.5, NikkeX + 0.005 * NikkeW . " ", NikkeY + 0.074 * NikkeH . " ", NikkeX + 0.005 * NikkeW + 0.124 * NikkeW . " ", NikkeY + 0.074 * NikkeH + 0.088 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("COOP的P"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 500
            break
        }
        else {
            AddLog("尝试滑动左上角的活动栏")
            Send "{WheelDown 3}"
            Sleep 500
        }
        if (A_Index > 15) {
            AddLog("未能找到协同作战", "MAROON")
            return
        }
    }
    AwardCooperateBattle
    BackToHall
}
;tag 协同作战核心
AwardCooperateBattle() {
    while true {
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.851 * NikkeW . " ", NikkeY + 0.750 * NikkeH . " ", NikkeX + 0.851 * NikkeW + 0.134 * NikkeW . " ", NikkeY + 0.750 * NikkeH + 0.068 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("开始匹配的开始"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("开始匹配")
            FindText().Click(X, Y, "L")
            Sleep 500
        }
        else {
            AddLog("协同作战次数已耗尽或未在开放时间", "MAROON")
            return
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.508 * NikkeW . " ", NikkeY + 0.600 * NikkeH . " ", NikkeX + 0.508 * NikkeW + 0.120 * NikkeW . " ", NikkeY + 0.600 * NikkeH + 0.053 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("协同作战次数已耗尽", "MAROON")
            return
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.375 * NikkeW . " ", NikkeY + 0.436 * NikkeH . " ", NikkeX + 0.375 * NikkeW + 0.250 * NikkeW . " ", NikkeY + 0.436 * NikkeH + 0.103 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("普通"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("选择难度")
            FindText().Click(X, Y, "L")
            Sleep 500
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.373 * NikkeW . " ", NikkeY + 0.644 * NikkeH . " ", NikkeX + 0.373 * NikkeW + 0.253 * NikkeW . " ", NikkeY + 0.644 * NikkeH + 0.060 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("确认"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("确认匹配")
            FindText().Click(X, Y, "L")
        }
        while true {
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.511 * NikkeW . " ", NikkeY + 0.660 * NikkeH . " ", NikkeX + 0.511 * NikkeW + 0.106 * NikkeW . " ", NikkeY + 0.660 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
            }
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.444 * NikkeW . " ", NikkeY + 0.915 * NikkeH . " ", NikkeX + 0.444 * NikkeW + 0.112 * NikkeW . " ", NikkeY + 0.915 * NikkeH + 0.052 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("准备"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                break
            }
        }
        BattleSettlement
        sleep 5000
    }
}
;endregion 协同作战
;tag 单人突击
AwardSoloRaid(stage7 := True) {
    if stage7 {
        AddLog("开始任务：单人突击", "Fuchsia")
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.172 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.093 * NikkeW . " ", NikkeY + 0.172 * NikkeH + 0.350 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("RAID"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
    } else {
        AddLog("不在单人突击活动时间", "MAROON")
        return
    }
    while !(ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
        Confirm
        if A_Index > 3 {
            AddLog("未能找到单人突击活动", "MAROON")
            return
        }
    }
    Confirm
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.417 * NikkeW . " ", NikkeY + 0.806 * NikkeH . " ", NikkeX + 0.417 * NikkeW + 0.164 * NikkeW . " ", NikkeY + 0.806 * NikkeH + 0.073 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的挑战"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("不在单人突击活动时间", "MAROON")
        BackToHall
        return
    }
    if stage7 {
        AddLog("选中第七关")
        UserClick(2270, 231, TrueRatio)
        Sleep 1000
    }
    while True {
        if (ok := FindText(&X, &Y, NikkeX + 0.519 * NikkeW . " ", NikkeY + 0.618 * NikkeH . " ", NikkeX + 0.519 * NikkeW + 0.043 * NikkeW . " ", NikkeY + 0.618 * NikkeH + 0.037 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红色的MODE"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("挑战模式")
            BackToHall
            return
        }
        AddLog("检测快速战斗")
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.504 * NikkeW . " ", NikkeY + 0.728 * NikkeH . " ", NikkeX + 0.504 * NikkeW + 0.144 * NikkeW . " ", NikkeY + 0.728 * NikkeH + 0.074 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("快速战斗的图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("快速战斗已激活", "GREEN")
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            Sleep 500
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.553 * NikkeW . " ", NikkeY + 0.683 * NikkeH . " ", NikkeX + 0.553 * NikkeW + 0.036 * NikkeW . " ", NikkeY + 0.683 * NikkeH + 0.040 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("MAX"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
            if (ok := FindText(&X, &Y, NikkeX + 0.470 * NikkeW . " ", NikkeY + 0.733 * NikkeH . " ", NikkeX + 0.470 * NikkeW + 0.157 * NikkeW . " ", NikkeY + 0.733 * NikkeH + 0.073 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("进行战斗的进"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                BattleActive := 1
                Sleep 1000
            }
            BattleSettlement
            BackToHall
            return
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.413 * NikkeW . " ", NikkeY + 0.800 * NikkeH . " ", NikkeX + 0.413 * NikkeW + 0.176 * NikkeW . " ", NikkeY + 0.800 * NikkeH + 0.085 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("单人突击·挑战"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("快速战斗未激活，尝试普通战斗")
            FindText().Click(X, Y, "L")
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.518 * NikkeW . " ", NikkeY + 0.609 * NikkeH . " ", NikkeX + 0.518 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.609 * NikkeH + 0.033 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
            if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.512 * NikkeW . " ", NikkeY + 0.818 * NikkeH . " ", NikkeX + 0.512 * NikkeW + 0.142 * NikkeW . " ", NikkeY + 0.818 * NikkeH + 0.086 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("个人突击·进入战斗的进"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
                Skipping
                if BattleSettlement() = false {
                    AddLog("战斗结算失败，尝试返回大厅", "red")
                    BackToHall
                    return
                }
                sleep 5000
                while !(ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
                    Confirm
                }
            }
        }
        if stage7 {
            AddLog("第七关未开放", "MAROON")
            BackToHall
            AwardSoloRaid(stage7 := false)
            return
        }
        if !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.413 * NikkeW . " ", NikkeY + 0.800 * NikkeH . " ", NikkeX + 0.413 * NikkeW + 0.176 * NikkeW . " ", NikkeY + 0.800 * NikkeH + 0.085 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("单人突击·挑战"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("已无挑战次数，返回", "MAROON")
            BackToHall
            return
        }
    }
}
;region 小活动
;tag 入口
EventSmall() {
    AddLog("开始任务：小活动", "Fuchsia")
    loop {
        if (ok := FindText(&X, &Y, NikkeX + 0.632 * NikkeW . " ", NikkeY + 0.794 * NikkeH . " ", NikkeX + 0.632 * NikkeW + 0.140 * NikkeW . " ", NikkeY + 0.794 * NikkeH + 0.108 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("小活动·GO"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("已找到小活动：GO!NINJA THIEF!")
            UserClick(2782, 1816, TrueRatio)
            loop 3 {
                Sleep 500
                Confirm
            }
            break
        }
        else if (ok := FindText(&X, &Y, NikkeX + 0.751 * NikkeW . " ", NikkeY + 0.864 * NikkeH . " ", NikkeX + 0.751 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.864 * NikkeH + 0.037 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("活动·切换的图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("切换活动")
            FindText().Click(X, Y, "L")
            Sleep 3000
        }
        if A_Index > 3 {
            AddLog("未找到活动，可能是活动已结束")
            return
        }
    }
    while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.33 * PicTolerance, 0.33 * PicTolerance, FindText().PicLib("剧情活动"), , 0, , , , , TrueRatio, TrueRatio)) {
        Confirm
        Send "{]}"
    }
    AddLog("已进入活动地区")
    Sleep 3000
}
;tag 挑战
EventSmallChallenge() {
    AddLog("开始任务：小活动·挑战", "Fuchsia")
    while true {
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.357 * NikkeW . " ", NikkeY + 0.754 * NikkeH . " ", NikkeX + 0.357 * NikkeW + 0.136 * NikkeW . " ", NikkeY + 0.754 * NikkeH + 0.070 * NikkeH . " ", 0.31 * PicTolerance, 0.31 * PicTolerance, FindText().PicLib("小活动·挑战"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            ; 挑战
            Challenge
            break
        }
        if A_Index > 5 {
            MsgBox("未找到小活动挑战")
            Pause
        }
        sleep 1000
        Confirm
    }
    while (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("尝试返回活动主页面")
        GoBack
        Sleep 1000
    }
    AddLog("已返回活动主页面")
}
;tag 剧情活动
EventSmallStory() {
    AddLog("开始任务：小活动·剧情活动", "Fuchsia")
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.463 * NikkeW . " ", NikkeY + 0.723 * NikkeH . " ", NikkeX + 0.463 * NikkeW + 0.020 * NikkeW . " ", NikkeY + 0.723 * NikkeH + 0.029 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("小活动·放大镜的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("尝试进入对应活动页")
        FindText().Click(X, Y - 100 * TrueRatio, "L")
        Sleep 500
    }
    while !(ok := FindText(&X, &Y, NikkeX + 0.004 * NikkeW . " ", NikkeY + 0.022 * NikkeH . " ", NikkeX + 0.004 * NikkeW + 0.038 * NikkeW . " ", NikkeY + 0.022 * NikkeH + 0.027 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("活动关卡"), , , , , , , TrueRatio, TrueRatio)) {
        Confirm
    }
    AddLog("进入活动关卡")
    AdvanceMode("小活动·关卡图标", "小活动·关卡图标2")
    Sleep 1000
    GoBack
}
;tag 任务
EventSmallMission() {
    AddLog("开始任务：小活动·任务领取", "Fuchsia")
    if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.628 * NikkeW . " ", NikkeY + 0.758 * NikkeH . " ", NikkeX + 0.628 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.758 * NikkeH + 0.025 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
        AddLog("已进入任务界面")
        while (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.529 * NikkeW . " ", NikkeY + 0.862 * NikkeH . " ", NikkeX + 0.529 * NikkeW + 0.111 * NikkeW . " ", NikkeY + 0.862 * NikkeH + 0.056 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("签到·全部领取"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            AddLog("点击全部领取")
            Sleep 2000
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            Sleep 500
        }
    }
    else {
        AddLog("没有可领取的任务")
    }
}
;endregion 小活动
;region 大活动
;tag 入口
EventLarge() {
    AddLog("开始任务：大活动", "Fuchsia")
    loop {
        if (ok := FindText(&X, &Y, NikkeX + 0.632 * NikkeW . " ", NikkeY + 0.794 * NikkeH . " ", NikkeX + 0.632 * NikkeW + 0.140 * NikkeW . " ", NikkeY + 0.794 * NikkeH + 0.108 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·RE"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("已找到大活动：REBORN EVIL")
            UserClick(2782, 1816, TrueRatio)
            loop 3 {
                Sleep 500
                Confirm
            }
            break
        }
        else if (ok := FindText(&X, &Y, NikkeX + 0.751 * NikkeW . " ", NikkeY + 0.864 * NikkeH . " ", NikkeX + 0.751 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.864 * NikkeH + 0.037 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("活动·切换的图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("切换活动")
            FindText().Click(X, Y, "L")
            Sleep 3000
        }
        if A_Index > 3 {
            AddLog("未找到活动，可能是活动已结束")
            return
        }
    }
    while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
        Confirm
        Send "{]}"
    }
    AddLog("已进入活动地区")
    Sleep 3000
}
;tag 签到
EventLargeSign() {
    AddLog("开始任务：大活动·签到", "Fuchsia")
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.553 * NikkeW . " ", NikkeY + 0.781 * NikkeH . " ", NikkeX + 0.553 * NikkeW + 0.105 * NikkeW . " ", NikkeY + 0.781 * NikkeH + 0.058 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·签到印章"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("尝试进入对应活动页")
        FindText().Click(X - 50 * TrueRatio, Y, "L")
        Sleep 1000
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.534 * NikkeW . " ", NikkeY + 0.840 * NikkeH . " ", NikkeX + 0.534 * NikkeW + 0.099 * NikkeW . " ", NikkeY + 0.840 * NikkeH + 0.063 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·全部领取"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        AddLog("点击全部领取")
        Sleep 3000
        Confirm
    }
    while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("尝试返回活动主页面")
        GoBack
        ; 领取活动赠送妮姬
        if (ok := FindText(&X, &Y, NikkeX + 0.436 * NikkeW . " ", NikkeY + 0.866 * NikkeH . " ", NikkeX + 0.436 * NikkeW + 0.128 * NikkeW . " ", NikkeY + 0.866 * NikkeH + 0.070 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("抽卡·确认"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 500
        }
    }
    AddLog("已返回活动主页面")
}
;tag 挑战
EventLargeChallenge() {
    AddLog("开始任务：大活动·挑战", "Fuchsia")
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.340 * NikkeW . " ", NikkeY + 0.812 * NikkeH . " ", NikkeX + 0.340 * NikkeW + 0.120 * NikkeW . " ", NikkeY + 0.812 * NikkeH + 0.049 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·挑战"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("尝试进入对应活动页")
        FindText().Click(X - 50 * TrueRatio, Y, "L")
        Sleep 500
    }
    Challenge
    while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("尝试返回活动主页面")
        GoBack
    }
    AddLog("已返回活动主页面")
}
;tag 剧情活动
EventLargeStory() {
    AddLog("开始任务：大活动·剧情活动", "Fuchsia")
    ; 先story2
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.339 * NikkeW . " ", NikkeY + 0.760 * NikkeH . " ", NikkeX + 0.339 * NikkeW + 0.116 * NikkeW . " ", NikkeY + 0.760 * NikkeH + 0.053 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·STORY"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("尝试进入对应活动页")
        FindText().Click(X - 50 * TrueRatio, Y, "L")
        Sleep 500
    }
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.343 * NikkeW . " ", NikkeY + 0.707 * NikkeH . " ", NikkeX + 0.343 * NikkeW + 0.116 * NikkeW . " ", NikkeY + 0.707 * NikkeH + 0.053 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·STORY"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("尝试进入对应活动页")
        FindText().Click(X - 50 * TrueRatio, Y, "L")
        Sleep 500
    }
    loop 3 {
        Confirm
        Sleep 500
    }
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.416 * NikkeW . " ", NikkeY + 0.763 * NikkeH . " ", NikkeX + 0.416 * NikkeW + 0.062 * NikkeW . " ", NikkeY + 0.763 * NikkeH + 0.056 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·剩余时间"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("进入剧情活动页面")
        Sleep 500
        FindText().Click(X, Y - 100 * TrueRatio, "L")
        Sleep 1000
    }
    while !(ok := FindText(&X, &Y, NikkeX + 0.004 * NikkeW . " ", NikkeY + 0.022 * NikkeH . " ", NikkeX + 0.004 * NikkeW + 0.038 * NikkeW . " ", NikkeY + 0.022 * NikkeH + 0.027 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("活动关卡"), , , , , , , TrueRatio, TrueRatio)) {
        Confirm
    }
    AddLog("进入活动关卡")
    ; 执行剧情活动流程
    AdvanceMode("大活动·关卡图标", "大活动·关卡图标2")
    while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("尝试返回活动主页面")
        Confirm
        GoBack
    }
    AddLog("已返回活动主页面")
}
;tag 协同作战
EventLargeCooperate() {
    AddLog("开始任务：大活动·协同作战", "Fuchsia")
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.866 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.134 * NikkeW . " ", NikkeY + 0.866 * NikkeH + 0.046 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·协同作战"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("尝试进入对应活动页")
        FindText().Click(X - 50 * TrueRatio, Y, "L")
        Sleep 500
        if A_Index > 50 {
            AddLog("不在活动期间")
            break
        }
    }
    if (ok := FindText(&X, &Y, NikkeX + 0.357 * NikkeW . " ", NikkeY + 0.575 * NikkeH . " ", NikkeX + 0.357 * NikkeW + 0.287 * NikkeW . " ", NikkeY + 0.575 * NikkeH + 0.019 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    AwardCooperateBattle
    while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("尝试返回活动主页面")
        GoBack
    }
    AddLog("已返回活动主页面")
}
;tag 小游戏
EventLargeMinigame() {
    AddLog("开始任务：大活动·小游戏", "Fuchsia")
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.551 * NikkeW . " ", NikkeY + 0.715 * NikkeH . " ", NikkeX + 0.551 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.715 * NikkeH + 0.044 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·小游戏"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("尝试进入对应活动页")
        FindText().Click(X - 50 * TrueRatio, Y, "L")
        Send "{]}"
        Sleep 500
    }
    Sleep 2000
    Send "{]}"
    Confirm
    AddLog("点第一个START")
    UserClick(1974, 1418, TrueRatio)
    Sleep 1000
    AddLog("点第二个START")
    UserClick(1911, 1743, TrueRatio)
    if (ok := FindText(&X := "wait", &Y := 10, NikkeX + 0.370 * NikkeW . " ", NikkeY + 0.245 * NikkeH . " ", NikkeX + 0.370 * NikkeW + 0.259 * NikkeW . " ", NikkeY + 0.245 * NikkeH + 0.461 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·小游戏·十字"), , , , , , 1, TrueRatio, TrueRatio)) {
        loop {
            if (ok := FindText(&X, &Y, NikkeX + 0.370 * NikkeW . " ", NikkeY + 0.245 * NikkeH . " ", NikkeX + 0.370 * NikkeW + 0.259 * NikkeW . " ", NikkeY + 0.245 * NikkeH + 0.461 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·小游戏·十字"), , , , , , 1, TrueRatio, TrueRatio)) {
                AddLog("点击扩充")
                FindText().Click(X, Y, "L")
                Sleep 500
            }
            if (ok := FindText(&X, &Y, NikkeX + 0.499 * NikkeW . " ", NikkeY + 0.723 * NikkeH . " ", NikkeX + 0.499 * NikkeW + 0.142 * NikkeW . " ", NikkeY + 0.723 * NikkeH + 0.062 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·小游戏·扩充完成"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
                break
            }
        }
    }
    AddLog("点战斗开始")
    UserClick(1938, 2030, TrueRatio)
    Sleep 1000
    loop {
        Send "{Space}"
        Sleep 1000
        Send "{1}"
        Sleep 1000
        UserClick(1938, 2030, TrueRatio)
        Sleep 1000
        if A_Index > 12 {
            UserClick(1938, 2030, TrueRatio)
            Sleep 1000
            AddLog("结算战斗")
            Send "{Esc}"
            Sleep 1000
            AddLog("点击快速完成")
            UserClick(2120, 1858, TrueRatio)
            Sleep 1000
            AddLog("点击返回")
            UserClick(1806, 1682, TrueRatio)
            break
        }
    }
    while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("尝试返回活动主页面")
        GoBack
    }
    AddLog("已返回活动主页面")
}
;tag 领取奖励
EventLargeDaily() {
    AddLog("开始任务：大活动·领取奖励", "Fuchsia")
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.986 * NikkeW . " ", NikkeY + 0.172 * NikkeH . " ", NikkeX + 0.986 * NikkeW + 0.008 * NikkeW . " ", NikkeY + 0.172 * NikkeH + 0.019 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        if (ok := FindText(&X, &Y, NikkeX + 0.956 * NikkeW . " ", NikkeY + 0.170 * NikkeH . " ", NikkeX + 0.956 * NikkeW + 0.041 * NikkeW . " ", NikkeY + 0.170 * NikkeH + 0.089 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·任务"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y - 50 * TrueRatio, "L")
            Sleep 1000
            while !(ok := FindText(&X, &Y, NikkeX + 0.548 * NikkeW . " ", NikkeY + 0.864 * NikkeH . " ", NikkeX + 0.548 * NikkeW + 0.093 * NikkeW . " ", NikkeY + 0.864 * NikkeH + 0.063 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·灰色的全部"), , , , , , , TrueRatio, TrueRatio)) {
                UserClick(2412, 1905, TrueRatio)
                Sleep 1000
            }
        }
        while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试返回活动主页面")
            GoBack
        }
        AddLog("已返回活动主页面")
    }
    else AddLog("奖励已领取")
}
;tag 通行证
;endregion 大活动
;region 特殊活动
EventSpecial() {
}
;endregion 特殊活动
;region 任务完成后
;tag 自动升级循环室
ClearRedRecycling() {
    AddLog("自动升级循环室", "Fuchsia")
    if (ok := FindText(&X, &Y, NikkeX + 0.344 * NikkeW . " ", NikkeY + 0.719 * NikkeH . " ", NikkeX + 0.344 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.719 * NikkeH + 0.018 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("进入前哨基地")
        FindText().Click(X, Y, "L")
        Sleep 1000
        if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.582 * NikkeW . " ", NikkeY + 0.805 * NikkeH . " ", NikkeX + 0.582 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.805 * NikkeH + 0.023 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            Sleep 1000
            AddLog("点击进入循环室")
            FindText().Click(X, Y, "L")
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.612 * NikkeW . " ", NikkeY + 0.907 * NikkeH . " ", NikkeX + 0.612 * NikkeW + 0.013 * NikkeW . " ", NikkeY + 0.907 * NikkeH + 0.020 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击进入")
                FindText().Click(X, Y, "L")
                Sleep 3000
                Send "{WheelUp 2}"
                while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.333 * NikkeW . " ", NikkeY + 0.040 * NikkeH . " ", NikkeX + 0.333 * NikkeW + 0.354 * NikkeW . " ", NikkeY + 0.040 * NikkeH + 0.865 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击类型研究/通用研究")
                    FindText().Click(X, Y + 200 * TrueRatio, "L")
                    Sleep 1000
                    loop {
                        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.397 * NikkeW . " ", NikkeY + 0.767 * NikkeH . " ", NikkeX + 0.397 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.767 * NikkeH + 0.064 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("自动选择的图标"), , , , , , , TrueRatio, TrueRatio)) {
                            AddLog("点击自动选择")
                            FindText().Click(X, Y, "L")
                            Sleep 500
                        }
                        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.489 * NikkeW . " ", NikkeY + 0.764 * NikkeH . " ", NikkeX + 0.489 * NikkeW + 0.150 * NikkeW . " ", NikkeY + 0.764 * NikkeH + 0.071 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("循环室·升级"), , , , , , , TrueRatio, TrueRatio)) {
                            AddLog("点击升级")
                            FindText().Click(X, Y, "L")
                            Sleep 500
                            Confirm()
                            Sleep 500
                            Confirm()
                        }
                        else {
                            Confirm()
                            break
                        }
                        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.573 * NikkeW . " ", NikkeY + 0.684 * NikkeH . " ", NikkeX + 0.573 * NikkeW + 0.037 * NikkeW . " ", NikkeY + 0.684 * NikkeH + 0.044 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("MAX"), , , , , , , TrueRatio, TrueRatio)) {
                            AddLog("点击MAX")
                            FindText().Click(X, Y, "L")
                            Sleep 500
                            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.423 * NikkeW . " ", NikkeY + 0.781 * NikkeH . " ", NikkeX + 0.423 * NikkeW + 0.157 * NikkeW . " ", NikkeY + 0.781 * NikkeH + 0.070 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("循环室·升级"), , , , , , , TrueRatio, TrueRatio)) {
                                AddLog("点击升级")
                                FindText().Click(X, Y, "L")
                                Sleep 2000
                                Confirm()
                                Sleep 500
                                Confirm()
                                break
                            }
                        }
                    }
                }
                BackToHall()
            }
        }
        else AddLog("未发现循环室红点")
    }
    else AddLog("未发现前哨基地红点")
}
;tag 自动升级同步器
ClearRedSynchro() {
    AddLog("自动升级同步器", "Fuchsia")
    if g_settings["ClearRedSynchroForce"] {
        EnterToOutpost()
        if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.408 * NikkeW . " ", NikkeY + 0.806 * NikkeH . " ", NikkeX + 0.408 * NikkeW + 0.046 * NikkeW . " ", NikkeY + 0.806 * NikkeH + 0.096 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("前哨基地·同步器"), , , , , , , TrueRatio, TrueRatio)) {
            Sleep 1000
            AddLog("点击同步器")
            FindText().Click(X, Y, "L")
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.504 * NikkeW . " ", NikkeY + 0.907 * NikkeH . " ", NikkeX + 0.504 * NikkeW + 0.123 * NikkeW . " ", NikkeY + 0.907 * NikkeH + 0.084 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("前哨基地·进入的图标"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击进入")
                FindText().Click(X, Y, "L")
                Sleep 1000
                loop {
                    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.477 * NikkeW . " ", NikkeY + 0.201 * NikkeH . " ", NikkeX + 0.477 * NikkeW + 0.043 * NikkeW . " ", NikkeY + 0.201 * NikkeH + 0.045 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("同步器·增强"), , , , , , , TrueRatio, TrueRatio)) {
                        AddLog("点击增强")
                        FindText().Click(X, Y, "L")
                        Sleep 1000
                    }
                    if (ok := FindText(&X, &Y, NikkeX + 0.599 * NikkeW . " ", NikkeY + 0.604 * NikkeH . " ", NikkeX + 0.599 * NikkeW + 0.030 * NikkeW . " ", NikkeY + 0.604 * NikkeH + 0.034 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("同步器·消耗道具使用的图标"), , , , , , , TrueRatio, TrueRatio)) {
                        FindText().Click(X, Y, "L")
                        Sleep 1000
                    }
                    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.416 * NikkeW . " ", NikkeY + 0.798 * NikkeH . " ", NikkeX + 0.416 * NikkeW + 0.091 * NikkeW . " ", NikkeY + 0.798 * NikkeH + 0.070 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("自动选择的图标"), , , , , , , TrueRatio, TrueRatio)) {
                        AddLog("点击自动选择")
                        FindText().Click(X, Y, "L")
                        Sleep 1000
                    }
                    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.505 * NikkeW . " ", NikkeY + 0.798 * NikkeH . " ", NikkeX + 0.505 * NikkeW + 0.112 * NikkeW . " ", NikkeY + 0.798 * NikkeH + 0.068 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("同步器·开始增强"), , , , , , , TrueRatio, TrueRatio)) {
                        AddLog("点击开始增强")
                        FindText().Click(X, Y, "L")
                        Sleep 3000
                        while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.477 * NikkeW . " ", NikkeY + 0.201 * NikkeH . " ", NikkeX + 0.477 * NikkeW + 0.043 * NikkeW . " ", NikkeY + 0.201 * NikkeH + 0.045 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("同步器·增强"), , , , , , , TrueRatio, TrueRatio)) {
                            Confirm()
                        }
                    }
                    else {
                        AddLog("资源不足")
                        break
                    }
                }
            }
        }
    }
    if !g_settings["ClearRedSynchroForce"] {
        if (ok := FindText(&X, &Y, NikkeX + 0.344 * NikkeW . " ", NikkeY + 0.719 * NikkeH . " ", NikkeX + 0.344 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.719 * NikkeH + 0.018 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击进入前哨基地")
            FindText().Click(X, Y, "L")
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.443 * NikkeW . " ", NikkeY + 0.804 * NikkeH . " ", NikkeX + 0.443 * NikkeW + 0.014 * NikkeW . " ", NikkeY + 0.804 * NikkeH + 0.025 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                Sleep 1000
                AddLog("点击进入同步器")
                FindText().Click(X, Y, "L")
                Sleep 1000
                if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.612 * NikkeW . " ", NikkeY + 0.907 * NikkeH . " ", NikkeX + 0.612 * NikkeW + 0.013 * NikkeW . " ", NikkeY + 0.907 * NikkeH + 0.020 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击进入")
                    FindText().Click(X, Y, "L")
                    Sleep 2000
                    loop {
                        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.477 * NikkeW . " ", NikkeY + 0.201 * NikkeH . " ", NikkeX + 0.477 * NikkeW + 0.043 * NikkeW . " ", NikkeY + 0.201 * NikkeH + 0.045 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("同步器·增强"), , , , , , , TrueRatio, TrueRatio)) {
                            AddLog("点击增强")
                            FindText().Click(X, Y, "L")
                            Sleep 1000
                            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.505 * NikkeW . " ", NikkeY + 0.798 * NikkeH . " ", NikkeX + 0.505 * NikkeW + 0.112 * NikkeW . " ", NikkeY + 0.798 * NikkeH + 0.068 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("同步器·开始增强"), , , , , , , TrueRatio, TrueRatio)) {
                                AddLog("点击开始增强")
                                FindText().Click(X, Y, "L")
                                Sleep 1000
                            }
                            else
                                break
                        }
                        else {
                            Confirm()
                        }
                    }
                }
                else AddLog("未发现同步器进入红点")
            }
            else AddLog("未发现同步器红点")
        }
        else AddLog("未发现前哨基地红点")
    }
    BackToHall()
}
;tag 自动突破妮姬
ClearRedLimit() {
    AddLog("自动突破妮姬", "Fuchsia")
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.395 * NikkeW . " ", NikkeY + 0.883 * NikkeH . " ", NikkeX + 0.395 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.883 * NikkeH + 0.019 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击进入妮姬")
        Sleep 500
        FindText().Click(X, Y, "L")
        Sleep 1000
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.513 * NikkeW . " ", NikkeY + 0.191 * NikkeH . " ", NikkeX + 0.513 * NikkeW + 0.014 * NikkeW . " ", NikkeY + 0.191 * NikkeH + 0.022 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("妮姬·筛选红点"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击筛选红点")
            FindText().Click(X, Y, "L")
            Sleep 1000
            while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.099 * NikkeW . " ", NikkeY + 0.284 * NikkeH . " ", NikkeX + 0.099 * NikkeW + 0.015 * NikkeW . " ", NikkeY + 0.284 * NikkeH + 0.023 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击带有红点的妮姬")
                FindText().Click(X, Y, "L")
                Sleep 1000
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.004 * NikkeW . " ", NikkeY + 0.858 * NikkeH . " ", NikkeX + 0.004 * NikkeW + 0.040 * NikkeW . " ", NikkeY + 0.858 * NikkeH + 0.038 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("珍藏品壁纸的图标"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("切换珍藏品样式")
                    UserClick(94, 1888, TrueRatio)
                }
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.960 * NikkeW . " ", NikkeY + 0.487 * NikkeH . " ", NikkeX + 0.960 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.487 * NikkeH + 0.012 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("妮姬·极限突破的红色红点"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击极限突破/核心强化的红点")
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                }
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.416 * NikkeW . " ", NikkeY + 0.822 * NikkeH . " ", NikkeX + 0.416 * NikkeW + 0.171 * NikkeW . " ", NikkeY + 0.822 * NikkeH + 0.074 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("妮姬·极限突破"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击极限突破")
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.505 * NikkeW . " ", NikkeY + 0.593 * NikkeH . " ", NikkeX + 0.505 * NikkeW + 0.123 * NikkeW . " ", NikkeY + 0.593 * NikkeH + 0.064 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                        AddLog("确认突破")
                        FindText().Click(X, Y, "L")
                        Sleep 1000
                    }
                }
                if (ok := FindText(&X, &Y, NikkeX + 0.553 * NikkeW . " ", NikkeY + 0.683 * NikkeH . " ", NikkeX + 0.553 * NikkeW + 0.036 * NikkeW . " ", NikkeY + 0.683 * NikkeH + 0.040 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("MAX"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击MAX")
                    FindText().Click(X, Y, "L")
                    Sleep 500
                }
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.371 * NikkeW . " ", NikkeY + 0.785 * NikkeH . " ", NikkeX + 0.371 * NikkeW + 0.257 * NikkeW . " ", NikkeY + 0.785 * NikkeH + 0.076 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("妮姬·核心强化"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击核心强化")
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.505 * NikkeW . " ", NikkeY + 0.593 * NikkeH . " ", NikkeX + 0.505 * NikkeW + 0.123 * NikkeW . " ", NikkeY + 0.593 * NikkeH + 0.064 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                        AddLog("确认核心强化")
                        FindText().Click(X, Y, "L")
                        Sleep 1000
                    }
                }
                loop 3 {
                    Confirm()
                    Sleep 1000
                }
                GoBack()
            }
            UserClick(1898, 2006, TrueRatio)
        }
        BackToHall()
    }
    else AddLog("未发现妮姬菜单红点")
}
;tag 自动升级魔方
ClearRedCube() {
    AddLog("自动升级魔方", "Fuchsia")
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.752 * NikkeW . " ", NikkeY + 0.626 * NikkeH . " ", NikkeX + 0.752 * NikkeW + 0.013 * NikkeW . " ", NikkeY + 0.626 * NikkeH + 0.029 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击进入方舟")
        FindText().Click(X, Y, "L")
        Sleep 1000
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.478 * NikkeW . " ", NikkeY + 0.106 * NikkeH . " ", NikkeX + 0.478 * NikkeW + 0.015 * NikkeW . " ", NikkeY + 0.106 * NikkeH + 0.031 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击进入迷失地区")
            Sleep 1000
            FindText().Click(X, Y, "L")
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.983 * NikkeW . " ", NikkeY + 0.903 * NikkeH . " ", NikkeX + 0.983 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.903 * NikkeH + 0.027 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击调和魔方")
                Sleep 1000
                FindText().Click(X, Y, "L")
                Sleep 1000
                loop {
                    UserMove(1920, 598, TrueRatio) ; 将鼠标移到魔方列表区域，准备滚动或点击
                    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.339 * NikkeW . " ", NikkeY + 0.231 * NikkeH . " ", NikkeX + 0.339 * NikkeW + 0.322 * NikkeW . " ", NikkeY + 0.231 * NikkeH + 0.683 * NikkeH . " ", 0.23 * PicTolerance, 0.23 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                        AddLog("点击可升级魔方")
                        FindText().Click(X, Y, "L")
                        Sleep 1000
                        if (ok := FindText(&X, &Y, NikkeX + 0.551 * NikkeW . " ", NikkeY + 0.839 * NikkeH . " ", NikkeX + 0.551 * NikkeW + 0.017 * NikkeW . " ", NikkeY + 0.839 * NikkeH + 0.030 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                            AddLog("点击强化魔方")
                            FindText().Click(X, Y, "L")
                            Sleep 1000
                            if (ok := FindText(&X, &Y, NikkeX + 0.602 * NikkeW . " ", NikkeY + 0.759 * NikkeH . " ", NikkeX + 0.602 * NikkeW + 0.017 * NikkeW . " ", NikkeY + 0.759 * NikkeH + 0.029 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                                AddLog("点击强化")
                                FindText().Click(X, Y, "L")
                                Sleep 500
                                ; 清除强化后的确认/动画
                                loop 10 {
                                    UserClick(1910, 2066, TrueRatio)
                                    GoBack()
                                }
                            }
                        }
                    }
                    ; 未发现红点，尝试滚动
                    else {
                        Send "{WheelDown 13}"
                    }
                    if A_Index > 5 {
                        AddLog("所有魔方已检查")
                        break
                    }
                }
            }
        }
        BackToHall()
    }
    else AddLog("未发现方舟红点")
}
;tag 清除公告红点
ClearRedNotice() {
    AddLog("清除公告红点", "Fuchsia")
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.933 * NikkeW . " ", NikkeY + 0.012 * NikkeH . " ", NikkeX + 0.933 * NikkeW + 0.009 * NikkeW . " ", NikkeY + 0.012 * NikkeH + 0.023 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        Sleep 3000
        FindText().Click(X, Y, "L")
        Sleep 1000
        while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.490 * NikkeW . " ", NikkeY + 0.128 * NikkeH . " ", NikkeX + 0.490 * NikkeW + 0.016 * NikkeW . " ", NikkeY + 0.128 * NikkeH + 0.029 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            if A_Index = 1 {
                AddLog("清除活动公告红点")
                FindText().Click(X - 30 * TrueRatio, Y + 30 * TrueRatio, "L")
                Sleep 1000
                UserMove(1380, 462, TrueRatio) ; 将鼠标移动到活动栏区域
            }
            AddLog("查找红点")
            while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.620 * NikkeW . " ", NikkeY + 0.189 * NikkeH . " ", NikkeX + 0.617 * NikkeW + 0.013 * NikkeW . " ", NikkeY + 0.189 * NikkeH + 0.677 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 2000
                Confirm()
                Sleep 1000
                UserMove(1380, 462, TrueRatio)
            }
            AddLog("尝试滚动活动栏")
            Send "{WheelDown 33}"
            Sleep 500
        }
        while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.617 * NikkeW . " ", NikkeY + 0.141 * NikkeH . " ", NikkeX + 0.617 * NikkeW + 0.017 * NikkeW . " ", NikkeY + 0.141 * NikkeH + 0.031 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            if A_Index = 1 {
                AddLog("清除系统公告红点")
                FindText().Click(X - 30 * TrueRatio, Y + 30 * TrueRatio, "L")
                Sleep 1000
                UserMove(1380, 462, TrueRatio) ; 将鼠标移动到活动栏区域
            }
            AddLog("查找红点")
            while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.614 * NikkeW . " ", NikkeY + 0.188 * NikkeH . " ", NikkeX + 0.614 * NikkeW + 0.029 * NikkeW . " ", NikkeY + 0.188 * NikkeH + 0.694 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 2000
                Confirm()
                Sleep 1000
                UserMove(1380, 462, TrueRatio)
            }
            AddLog("尝试滚动活动栏")
            Send "{WheelDown 33}"
            Sleep 500
        }
        AddLog("公告红点已清除")
        BackToHall()
    }
    else AddLog("未发现公告红点")
}
;tag 清除壁纸红点
ClearRedWallpaper() {
    AddLog("清除壁纸红点", "Fuchsia")
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.980 * NikkeW . " ", NikkeY + 0.008 * NikkeH . " ", NikkeX + 0.980 * NikkeW + 0.019 * NikkeW . " ", NikkeY + 0.008 * NikkeH + 0.031 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击右上角的SUBMENU")
        FindText().Click(X, Y, "L")
        Sleep 1000
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.590 * NikkeW . " ", NikkeY + 0.441 * NikkeH . " ", NikkeX + 0.590 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.441 * NikkeH + 0.042 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击装饰大厅")
            FindText().Click(X, Y, "L")
            while (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.341 * NikkeW . " ", NikkeY + 0.371 * NikkeH . " ", NikkeX + 0.341 * NikkeW + 0.320 * NikkeW . " ", NikkeY + 0.371 * NikkeH + 0.028 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , 0.83 * TrueRatio, 0.83 * TrueRatio)) {
                AddLog("点击立绘/活动/技能动画/珍藏品")
                FindText().Click(X, Y, "L")
                Sleep 1000
                UserClick(1434, 856, TrueRatio)
                Sleep 1000
            }
            GoBack()
        }
        BackToHall()
    }
    else AddLog("未发现壁纸红点")
}
;tag 清除个人页红点
ClearRedProfile() {
    AddLog("清除个人页红点", "Fuchsia")
    if (FindText(&X := "wait", &Y := 1, NikkeX + 0.028 * NikkeW . " ", NikkeY + 0.000 * NikkeH . " ", NikkeX + 0.028 * NikkeW + 0.020 * NikkeW . " ", NikkeY + 0.000 * NikkeH + 0.032 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , TrueRatio, TrueRatio))
    || (FindText(&X := "wait", &Y := 1, NikkeX + 0.028 * NikkeW . " ", NikkeY + 0.000 * NikkeH . " ", NikkeX + 0.028 * NikkeW + 0.020 * NikkeW . " ", NikkeY + 0.000 * NikkeH + 0.032 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击左上角的个人头像")
        FindText().Click(X, Y, "L")
        Sleep 1000
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.418 * NikkeW . " ", NikkeY + 0.202 * NikkeH . " ", NikkeX + 0.418 * NikkeW + 0.017 * NikkeW . " ", NikkeY + 0.202 * NikkeH + 0.039 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击头像&边框")
            FindText().Click(X, Y, "L")
            Sleep 1000
            AddLog("点击头像")
            UserClick(1682, 292, TrueRatio)
            Sleep 1000
            AddLog("点击边框")
            UserClick(2152, 326, TrueRatio)
            Sleep 1000
            Send "{Esc}"
            Sleep 1000
        }
        if (FindText(&X := "wait", &Y := 1, NikkeX + 0.556 * NikkeW . " ", NikkeY + 0.217 * NikkeH . " ", NikkeX + 0.556 * NikkeW + 0.016 * NikkeW . " ", NikkeY + 0.217 * NikkeH + 0.029 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , TrueRatio, TrueRatio))
        || (FindText(&X := "wait", &Y := 1, NikkeX + 0.556 * NikkeW . " ", NikkeY + 0.217 * NikkeH . " ", NikkeX + 0.556 * NikkeW + 0.016 * NikkeW . " ", NikkeY + 0.217 * NikkeH + 0.029 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击称号")
            FindText().Click(X, Y, "L")
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.535 * NikkeW . " ", NikkeY + 0.802 * NikkeH . " ", NikkeX + 0.535 * NikkeW + 0.102 * NikkeW . " ", NikkeY + 0.802 * NikkeH + 0.057 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("全部领取的图标"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击全部领取")
                FindText().Click(X, Y, "L")
                Sleep 3000
                Confirm()
                Sleep 1000
            }
            Send "{Esc}"
            Sleep 1000
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.629 * NikkeW . " ", NikkeY + 0.159 * NikkeH . " ", NikkeX + 0.629 * NikkeW + 0.017 * NikkeW . " ", NikkeY + 0.159 * NikkeH + 0.036 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击个人简介装饰")
            FindText().Click(X, Y, "L")
            Sleep 1000
            AddLog("点击背景")
            UserClick(1634, 942, TrueRatio)
            Sleep 1000
            AddLog("点击贴纸")
            UserClick(2252, 932, TrueRatio)
            Sleep 1000
            Send "{Esc}"
            Sleep 1000
        }
        BackToHall()
    }
    else AddLog("未发现个人页红点")
}
;tag 清除bla红点
ClearRedBla() {
    AddLog("清除bla红点", "Fuchsia")
    if (ok := FindText(&X, &Y, NikkeX + 0.008 * NikkeW . " ", NikkeY + 0.174 * NikkeH . " ", NikkeX + 0.008 * NikkeW + 0.041 * NikkeW . " ", NikkeY + 0.174 * NikkeH + 0.084 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("Bla的图标"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 3000
    }
    UserClick(1554, 464, TrueRatio)
    Sleep 1000
    BackToHall()
}
;endregion 任务完成后
;region 妙妙工具
;tag 剧情模式
StoryMode(*) {
    Initialization
    WriteSettings
    AddLog("开始任务：剧情模式", "Fuchsia")
    while True {
        while (ok := FindText(&X, &Y, NikkeX + 0.936 * NikkeW . " ", NikkeY + 0.010 * NikkeH . " ", NikkeX + 0.936 * NikkeW + 0.051 * NikkeW . " ", NikkeY + 0.010 * NikkeH + 0.025 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("SKIP的图标"), , , , , , , TrueRatio, TrueRatio)) {
            if (ok := FindText(&X, &Y, NikkeX + 0.362 * NikkeW . " ", NikkeY + 0.589 * NikkeH . " ", NikkeX + 0.362 * NikkeW + 0.017 * NikkeW . " ", NikkeY + 0.589 * NikkeH + 0.283 * NikkeH . " ", 0.18 * PicTolerance, 0.18 * PicTolerance, FindText().PicLib("1"), , , , , , , TrueRatio, TrueRatio)) {
                if !g_settings["StoryModeAutoChoose"] {
                    if (ok := FindText(&X, &Y, NikkeX + 0.361 * NikkeW . " ", NikkeY + 0.638 * NikkeH . " ", NikkeX + 0.361 * NikkeW + 0.018 * NikkeW . " ", NikkeY + 0.638 * NikkeH + 0.282 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("2"), , , , , , , TrueRatio, TrueRatio)) {
                        continue
                    }
                }
                Sleep 1000
                Send "{1}"
                Sleep 500
            }
            if (ok := FindText(&X, &Y, NikkeX + 0.785 * NikkeW . " ", NikkeY + 0.004 * NikkeH . " ", NikkeX + 0.785 * NikkeW + 0.213 * NikkeW . " ", NikkeY + 0.004 * NikkeH + 0.071 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("白色的AUTO"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击AUTO")
                Send "{LShift Down}"
                Sleep 500
                Send "{LShift Up}"
                Click NikkeX + NikkeW, NikkeY, 0
            }
            if (ok := FindText(&X, &Y, NikkeX + 0.475 * NikkeW . " ", NikkeY + 0.460 * NikkeH . " ", NikkeX + 0.475 * NikkeW + 0.050 * NikkeW . " ", NikkeY + 0.460 * NikkeH + 0.080 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("Bla的图标"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击Bla的图标")
                Sleep 1000
                FindText().Click(X, Y, "L")
                Sleep 500
            }
            if (ok := FindText(&X, &Y, NikkeX + 0.366 * NikkeW . " ", NikkeY + 0.091 * NikkeH . " ", NikkeX + 0.366 * NikkeW + 0.012 * NikkeW . " ", NikkeY + 0.091 * NikkeH + 0.020 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("WIFI的图标"), , , , , , , TrueRatio, TrueRatio)) {
                if (ok := FindText(&X, &Y, NikkeX + 0.614 * NikkeW . " ", NikkeY + 0.210 * NikkeH . " ", NikkeX + 0.614 * NikkeW + 0.023 * NikkeW . " ", NikkeY + 0.210 * NikkeH + 0.700 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("对话框·对话"), , , , , , 3, TrueRatio, TrueRatio)) {
                    AddLog("点击对话")
                    FindText().Click(X - 100 * TrueRatio, Y - 100 * TrueRatio, "L")
                    sleep 1000
                }
                else {
                    AddLog("点击对话框的右下角")
                    UserClick(2382, 1894, TrueRatio)
                    sleep 1000
                }
            }
            if (ok := FindText(&X, &Y, NikkeX + 0.588 * NikkeW . " ", NikkeY + 0.754 * NikkeH . " ", NikkeX + 0.588 * NikkeW + 0.035 * NikkeW . " ", NikkeY + 0.754 * NikkeH + 0.055 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("对话框·想法"), , , , , , 3, TrueRatio, TrueRatio)) {
                AddLog("点击想法")
                FindText().Click(X - 100 * TrueRatio, Y - 100 * TrueRatio, "L")
                sleep 1000
            }
        }
        if g_settings["StoryModeAutoStar"] {
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.611 * NikkeW . " ", NikkeY + 0.609 * NikkeH . " ", NikkeX + 0.611 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.609 * NikkeH + 0.033 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的星星"), , , , , , , TrueRatio, TrueRatio)) {
                sleep 1000
                AddLog("点击右下角灰色的星星")
                FindText().Click(X, Y, "L")
                Sleep 500
            }
            else if (ok := FindText(&X, &Y, NikkeX + 0.361 * NikkeW . " ", NikkeY + 0.369 * NikkeH . " ", NikkeX + 0.361 * NikkeW + 0.020 * NikkeW . " ", NikkeY + 0.369 * NikkeH + 0.041 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的星星"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击左上角灰色的星星")
                FindText().Click(X, Y, "L")
                sleep 1000
                MsgBox("剧情结束力~")
                return
            }
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.500 * NikkeW . " ", NikkeY + 0.514 * NikkeH . " ", NikkeX + 0.500 * NikkeW + 0.139 * NikkeW . " ", NikkeY + 0.514 * NikkeH + 0.070 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("记录播放的播放"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击记录播放")
            FindText().Click(X, Y, "L")
            Sleep 500
            FindText().Click(X, Y, "L")
            Sleep 3000
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.785 * NikkeW . " ", NikkeY + 0.004 * NikkeH . " ", NikkeX + 0.785 * NikkeW + 0.213 * NikkeW . " ", NikkeY + 0.004 * NikkeH + 0.071 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("白色的AUTO"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击AUTO")
            Send "{LShift Down}"
            Sleep 500
            Send "{LShift Up}"
            Click NikkeX + NikkeW, NikkeY, 0
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.889 * NikkeW . " ", NikkeY + 0.912 * NikkeH . " ", NikkeX + 0.889 * NikkeW + 0.103 * NikkeW . " ", NikkeY + 0.912 * NikkeH + 0.081 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("白色的下一关卡"), , , , , , , TrueRatio, TrueRatio)) {
            Send "{T}"
            AddLog("点击下一关", "GREEN")
        }
        if !WinActive(nikkeID) {
            MsgBox "窗口未聚焦，程序已终止"
            return
        }
    }
}
;tag 调试模式
TestMode(BtnTestMode, Info) {
    g_numeric_settings["TestModeValue"] := TestModeEditControl.Value
    ; 1. 获取输入
    fullCallString := Trim(TestModeEditControl.Value)
    if (fullCallString = "") {
        MsgBox("请输入要执行的函数调用，例如: MyFunc(`"param1`", 123) 或 MyFunc")
        return
    }
    ; 2. 正则表达式解析 (允许函数名中带连字符，并使括号和参数可选)
    if RegExMatch(fullCallString, "i)^([\w-]+)\s*(?:\((.*)\))?$", &Match) {
        FuncName := Match[1]
        ; Match[2] 将包含括号内的参数字符串，如果括号不存在，则 Match[2] 为空
        ParamString := Match[2] ; 如果没有括号，Match[2] 会是空字符串
    } else {
        MsgBox("无效的输入格式`n`n请使用 '函数名(参数1, 参数2, ……)' 或 '函数名' 的格式")
        return
    }
    ; 3. 获取函数引用
    try {
        fn := %FuncName%
    } catch {
        MsgBox("错误: 函数 '" FuncName "' 不存在。")
        return
    }
    ; 4. 解析参数 (简化版 - 直接传递变量名作为字符串)
    ParamsArray := []
    ; 只有当 ParamString 不为空时才尝试解析参数
    if (Trim(ParamString) != "") {
        ParamList := StrSplit(ParamString, ",")
        for param in ParamList {
            cleanedParam := Trim(param)
            ; 直接作为字符串传递，不进行任何引号处理
            ParamsArray.Push(cleanedParam)
        }
    }
    ; 如果 ParamString 为空，ParamsArray 将保持为空，这正是我们无参数调用的期望
    ; 5. 初始化并执行
    if g_settings["TestModeInitialization"] {
        Initialization()
    }
    try {
        ; 使用 ParamsArray* 进行可变参数调用
        Result := fn.Call(ParamsArray*)
        ; 根据 Result 是否为空来决定消息，但通常函数执行完毕即可
        if (Result != "") {
            MsgBox("函数 '" FuncName "' 执行完毕。结果: " Result)
        } else {
            MsgBox("函数 '" FuncName "' 执行完毕。")
        }
    } catch Error as e {
        MsgBox("执行函数 '" FuncName "' 时出错:`n`n" e.Message "`n`n行号: " e.Line "`n文件: " e.File)
    }
}
;tag 快速爆裂
QuickBurst(*) {
    Initialization()
    while true {
        if (ok := FindText(&X, &Y, NikkeX + 0.920 * NikkeW . " ", NikkeY + 0.458 * NikkeH . " ", NikkeX + 0.920 * NikkeW + 0.016 * NikkeW . " ", NikkeY + 0.458 * NikkeH + 0.031 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("爆裂·A"), , , , , , , TrueRatio, TrueRatio)) {
            Send "{a}"
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.918 * NikkeW . " ", NikkeY + 0.551 * NikkeH . " ", NikkeX + 0.918 * NikkeW + 0.017 * NikkeW . " ", NikkeY + 0.551 * NikkeH + 0.028 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("爆裂·S"), , , , , , , TrueRatio, TrueRatio)) {
            Send "{s}"
        }
        if !WinActive(nikkeID) {
            MsgBox "窗口未聚焦，程序已终止"
            return
        }
    }
}
;tag 自动推图
AutoAdvance(*) {
    if g_numeric_settings["UserLevel"] < 3 {
        MsgBox("当前用户组不支持活动，请点击赞助按钮升级会员组")
        return
    }
    Initialization()
    k := 9
    if (ok := FindText(&X, &Y, NikkeX + 0.013 * NikkeW . " ", NikkeY + 0.074 * NikkeH . " ", NikkeX + 0.013 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.074 * NikkeH + 0.047 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("推图·地图的指针"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    loop {
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("黄色的遗失物品的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("找到遗失物品！")
            FindText().Click(X, Y, "L")
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 5, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                Sleep 500
                FindText().Click(X, Y, "L")
            }
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.010 * NikkeW . " ", NikkeY + 0.084 * NikkeH . " ", NikkeX + 0.010 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.084 * NikkeH + 0.038 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("推图·放大镜"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击小地图")
            FindText().Click(X, Y, "L")
        }
        else {
            EnterToBattle
            k := 9
            if BattleActive = 1 {
                modes := ["EventStory"]
                if BattleSettlement(modes*) = False {
                    MsgBox("本日の勝敗結果：`nDoroの敗北")
                    return
                }
                else {
                    while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.010 * NikkeW . " ", NikkeY + 0.084 * NikkeH . " ", NikkeX + 0.010 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.084 * NikkeH + 0.038 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("推图·放大镜"), , , , , , , TrueRatio, TrueRatio)) {
                        Confirm
                    }
                }
            }
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.359 * NikkeW . " ", NikkeY + 0.251 * NikkeH . " ", NikkeX + 0.359 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.251 * NikkeH + 0.040 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("推图·缩小镜"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("已进入小地图")
            Sleep 1000
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.360 * NikkeW . " ", NikkeY + 0.254 * NikkeH . " ", NikkeX + 0.360 * NikkeW + 0.280 * NikkeW . " ", NikkeY + 0.254 * NikkeH + 0.495 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("推图·红色的三角"), , , , , , k, TrueRatio * 0.8, TrueRatio * 0.8)) {
            Confirm
            AddLog("找到敌人")
            FindText().Click(X + (k - 9) * Random(-100, 100) * TrueRatio, Y + (k - 9) * Random(-100, 100) * TrueRatio, "L")
        }
        k := k + 2
        if k > 9
            k := k - 9
    }
}
;endregion 妙妙工具
;region 快捷键
;tag 关闭程序
^1:: {
    ExitApp
}
;tag 暂停程序
^2:: {
    Pause
}
;tag 初始化并调整窗口大小
^3:: {
    AdjustSize(1920, 1080)
}
^4:: {
    AdjustSize(2331, 1311)
}
^5:: {
    AdjustSize(2560, 1440)
}
^6:: {
    AdjustSize(3580, 2014)
}
^7:: {
    AdjustSize(3840, 2160)
}
;tag 调试指定函数
^0:: {
    ;添加基本的依赖
    ; Initialization()
}
;endregion 快捷键
