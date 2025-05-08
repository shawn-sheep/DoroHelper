#Requires AutoHotkey >=v2.0
#Include <github>
#Include <FindText>
CoordMode "Pixel", "Client"
CoordMode "Mouse", "Client"
;操作间隔（单位：毫秒）
sleepTime := 1500
;consts
currentVersion := "v1.0.0-beta.4"
usr := "kyokakawaii"
repo := "DoroHelper"
currentScale := A_ScreenDPI / 96 ;确定dpi缩放比例
stdScreenW := 3840
stdScreenH := 2160
waitTolerance := 50
colorTolerance := 15
scrRatio := 1 ;图像相对于屏幕的比例
; MsgBox "目前可能只支持国际服 2k分辨率 100%缩放"
; MsgBox "以任何方式暂停后，请右下角Reload Script重启程序后再次运行"
;初始化
Initialization() {
    global nikkeID := ""
    global NikkeX := 0
    global NikkeY := 0
    global NikkeW := 0
    global NikkeH := 0
    global NikkeWP := 0
    global NikkeHP := 0
    ; 设置窗口标题匹配模式为完全匹配
    SetTitleMatchMode 3
    targetExe := "nikke.exe"
    if WinExist("ahk_exe " . targetExe) {
        winID := WinExist("ahk_exe " . targetExe) ; 获取窗口ID
        actualWinTitle := WinGetTitle(winID)      ; 获取实际窗口标题
        AddLog("找到了进程为 '" . targetExe . "' 的窗口！`n实际窗口标题是: " . actualWinTitle)
        ; 你可以在这里添加其他操作，比如激活该窗口:
        WinActivate(winID)
    }
    else {
        ; 没有找到该进程的窗口
        AddLog("没有找到进程为 '" . targetExe . "' 的窗口，初始化失败！")
        Pause
    }
    nikkeID := winID
    WinGetClientPos &NikkeX, &NikkeY, &NikkeW, &NikkeH, nikkeID
    WinGetPos &NikkeXP, &NikkeYP, &NikkeWP, &NikkeHP, nikkeID
    ; WinMove (A_ScreenWidth / 2) - (NikkeWP / 2), (A_ScreenHeight / 2) - (NikkeHP / 2), 2347 * currentScale, 1350 * currentScale, nikkeID ;窗口缩放居中\
    WinMove , , 2347 * currentScale, 1350 * currentScale, nikkeID
    global scrRatio
    scrRatio := NikkeW / stdScreenW
    Sleep 500
    AddLog("nikke坐标是：" NikkeX "," NikkeY "`n屏幕宽度是" A_ScreenWidth "`n屏幕高度是" A_ScreenHeight "`nnikke宽度是" NikkeW "`nnikke高度是" NikkeH "`n缩放比例是" round(scrRatio, 2))
    WinMove (A_ScreenWidth / 2) - (NikkeWP / 2), (A_ScreenHeight / 2) - (NikkeHP / 2), , , nikkeID
}
;颜色判断
IsSimilarColor(targetColor, color) {
    tr := Format("{:d}", "0x" . substr(targetColor, 3, 2))
    tg := Format("{:d}", "0x" . substr(targetColor, 5, 2))
    tb := Format("{:d}", "0x" . substr(targetColor, 7, 2))
    pr := Format("{:d}", "0x" . substr(color, 3, 2))
    pg := Format("{:d}", "0x" . substr(color, 5, 2))
    pb := Format("{:d}", "0x" . substr(color, 7, 2))
    ;MsgBox tr tg tb pr pg pb
    distance := sqrt((tr - pr) ** 2 + (tg - pg) ** 2 + (tb - pb) ** 2)
    if (distance < colorTolerance)
        return true
    return false
}
;坐标转换-点击
UserClick(sX, sY, k) {
    uX := Round(sX * k) ; 计算转换后的坐标
    uY := Round(sY * k)
    CoordMode "Mouse", "Client"
    Send "{Click " uX " " uY "}" ; 点击转换后的坐标
}
;坐标转换-移动
UserMove(sX, sY, k) {
    uX := Round(sX * k) ; 计算转换后的坐标
    uY := Round(sY * k)
    Send "{Click " uX " " uY " " 0 "}" ; 点击转换后的坐标
}
;坐标转换-颜色
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
;检查更新
CheckForUpdateHandler(isManualCheck) {
    global currentVersion, usr, repo ; 确保能访问全局变量
    try {
        latestObj := Github.latest(usr, repo)
        if (currentVersion != latestObj.version) {
            userResponse := MsgBox( ; 发现新版本
                "DoroHelper存在更新版本:`n"
                "`nVersion: " latestObj.version
                "`nNotes:`n"
                . latestObj.change_notes
                "`n`n是否下载?", , "36") ; 0x24 = Yes/No + Question Icon
            if (userResponse = "Yes") {
                ; 用户选择下载
                downloadTempName := "DoroDownload.exe" ; 临时文件名
                finalName := "DoroHelper-" latestObj.version ".exe"
                try {
                    Github.Download(latestObj.downloadURLs[1], A_ScriptDir "\" downloadTempName)
                    ; 下载成功后重命名
                    FileMove(A_ScriptDir "\" downloadTempName, A_ScriptDir "\" finalName, 1) ; 1 = overwrite
                    MsgBox("新版本已下载至当前目录: " finalName, "下载完成")
                    ExitApp ; 下载完成后退出当前脚本
                } catch as downloadError {
                    MsgBox("下载失败，请检查网络。`n(" downloadError.Message ")", "下载错误", "IconX")
                    ; 删除临时文件
                    if FileExist(A_ScriptDir "\" downloadTempName)
                        FileDelete(A_ScriptDir "\" downloadTempName)
                }
            }
            ; else 用户选择不下载，什么也不做
        } else {
            ; 没有新版本
            if (isManualCheck) { ; 只有手动检查时才提示
                MsgBox("当前Doro已是最新版本。", "检查更新")
            }
        }
    } catch as githubError {
        ; 只有手动检查时才提示连接错误，自动检查时静默失败
        if (isManualCheck) {
            MsgBox("检查更新失败，无法连接到Github或仓库信息错误。`n(" githubError.Message ")", "检查更新错误", "IconX")
        }
    }
}
ClickOnCheckForUpdate(*) {
    CheckForUpdateHandler(true) ; 调用核心函数，标记为手动检查
}
;判断自动按钮颜色
isAutoOff(sX, sY, k) {
    uX := Round(sX * k)
    uY := Round(sY * k)
    uC := PixelGetColor(uX, uY)
    r := Format("{:d}", "0x" . substr(uC, 3, 2))
    g := Format("{:d}", "0x" . substr(uC, 5, 2))
    b := Format("{:d}", "0x" . substr(uC, 7, 2))
    if Abs(r - g) < 10 && Abs(r - b) < 10 && Abs(g - b) < 10
        return true
    return false
}
;检查自动瞄准和自动爆裂按钮颜色
CheckAutoBattle() {
    static autoBurstOn := false
    static autoAimOn := false
    ; 检查并开启自动瞄准
    if !autoAimOn && UserCheckColor([216], [160], ["0xFFFFFF"], scrRatio) {
        ; 如果自动瞄准按钮是灰色/关闭状态
        if isAutoOff(60, 57, scrRatio) {
            UserClick(60, 71, scrRatio) ; 点击开启自动瞄准
            Sleep sleepTime
        }
        autoAimOn := true ; 设置标志位，表示已尝试开启或已开启
    }
    ; 检查并开启自动爆裂
    if !autoBurstOn && UserCheckColor([216], [160], ["0xFFFFFF"], scrRatio) { ; 假设检查点与 Auto Aim 相同
        ; 如果自动爆裂按钮是灰色/关闭状态
        if isAutoOff(202, 66, scrRatio) {
            Send "{Tab}" ; 发送 Tab 键尝试开启自动爆裂
            Sleep sleepTime
        }
        autoBurstOn := true ; 设置标志位，表示已尝试开启或已开启
    }
}
;点左下角的小房子的对应位置的右边（不返回）
Confirm() {
    stdTargetX := 474
    stdTargetY := 2028
    UserClick(stdTargetX, stdTargetY, scrRatio)
    AddLog("点击默认位置(" stdTargetX * scrRatio "," stdTargetY * scrRatio ")")
}
GoBack() {
    AddLog("返回")
    Send "{Esc}"
    Sleep sleepTime
}
;结算招募
Recruit() {
    AddLog("结算招募")
    Text := "|<SKIP>*119$57.k1z7wT7k0w07kz1kw0100S7kS7U0003ky7kw003sS7Vy7Vy0T3ksTkwDk3zy63y7Vy0TzkkzkwDk07y47y7Vy00Dk0zkw00k0S03y7U07U3k0Tkw01zsS11y7U0Tz3kQDkwDz3sS7Uy7VzsT3ky7kwDz00S7kS7Vzs03kz3kwDz00S7wC7Vzy07kzVkwDzU"
    while !(ok := FindText(&X := "wait", &Y := 1, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) { ;如果没找到SKIP就一直点左下角（加速动画）
        Confirm
    }
    FindText().Click(X, Y, "L") ;找到了就点
    Sleep sleepTime
    Text := "|<确认>*143$52.zzXzzzzby0C7zwTwDk0E1zkzkz0303z1z7z0M0Dy3wTyDVVzwDlzsw01zzz7zXU01zzwTwA0060zlzk000M1z3y00llU7wDs0U07kTkz0200Tlz3w6801z7s7kMU27wTUT1WAMTly1y6801z7s3wM007wL0DlU00TkA8T00UVy01Vw0777s073k0QQTUUw723k1w47sAQD07tkzkzly0zz7zW"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
}
; 点掉推销
RefuseSale() {
    AddLog("尝试关闭可能的推销页面")
    loop 5 {
        Confirm
        Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            break
        }
    }
    Sleep sleepTime
}
; 进入战斗
EnterToBattle() {
    AddLog("尝试进入战斗")
    Text := "|<进入战斗的进入>*175$66.vzsSDzznzzzkzsS7zzVzzzUTsS7zz0zzzkDsS7zzUTzzs7sQ7zzkDzzw4000zzs7zzyA000zzw7zzzw000zzy3zzzw000zzy1zzzzsQ7zzy1zzzzsQ7zzy0zzXTsQ7zzw0zz0DsQ7zzw0Tz0DkQ7zzw0Tz0A000Tzs0DzwA000TzsA7zwA000TzkQ7zwC000zzkS3zwDUw7zzUS3zwDUw7zzUz1zwDVw7zz1z0zwD1w7zy1zUTwC3w7zw3zkDwC3w7zs3zk7s77w7zk7zs3U1zzzzUDzw1000s0C0Tzy01k000Q0zzz1Xs000S1zzzVbz000T7zzznU"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        AddLog("已点击进入战斗")
        Sleep sleepTime
        return True
    }
    else return False
}
;战斗结算
BattleSettlement() {
    Victory := 0
    AddLog("等待战斗结算")
    while true {
        CheckAutoBattle
        Sleep 3000
        TextTAB := "|<TAB的图标>*149$32.0Tzzzk3zzzw0zzzz0Dzzzk3zzzw0zzzz0Dzzzk3zzzw0w0zz0D0Dzk3k3zw0w0zz0D0Dzk3k3zw0w0y00D0D003k3k00w0w00D0D003k3k00w0w00D0D003k3k00w0w00D0D003k3k00w0w00D0D0Dzzzzzzzzzzzzzzzzzzzzw000000000000000000000U"
        TextR := "|<R的图标>*113$36.zzzzzzzzzzzzzy07zzzs07zzzU07zzz007bzy0TjXzw1zzVzw7zz0zsDzz0TsDzy0DkTzy07kTzy03kzzw0Tkzzw0zkzzzkzkzzzkzkzzzkzkzzzkzkTzzUzkTzzUzsTzz1zsDzz1zw7zy3zw3zw3zy0zU7zz000DzzU00Tzzk01zzzy07zzzztzzzzzzzzzzzzzzzU"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, TextTAB, , , , , , , currentScale, currentScale)) or (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, TextR, , , , , , , currentScale, currentScale)) {
            ;看到TAB的标志代表战斗结束了，看看怎么个事
            Text编队 := "|<编队>*103$46.tznzzznzXy7y0SDyC01s0szls07U7Xz7U0SASDsaTlslszW807WDXw1U0S8yDk601sXsz0szzWDVz3U0SAS7wQ00slsTUE03XX1w118CCQ3k44UsVkD7k03W60Tt00C8slw0Y0sz3302G3XsS4C98CD3s3lYUswTkzaG7Xnza"
            Text下一关 := "|<下一关>*192$69.zzzzzzzzwzls001zzzzz3yD0007zzzzwTVs000zzzzzlwTzlzzzzzzk00TyDzzzzzw003zlzzzzzzU00TyDzzzzzzy7zzkDzzzzzzszzy0zk000zz7zzk1y0007zkzzyA3k000s000zlkTzzzz0007yDXzzzzzw3zzlyzzzzzzUTzyDzzzzzzs1zzlzzzzzzy23zyDzzzzzzUsDzlzzzzzzkDUTyDzzzzzk3y0zlzzzzzz1zwDyDzzzzzxzzxU"
            ; 有编队代表输了，点Esc
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text编队, , , , , , , currentScale, currentScale)) {
                AddLog("战斗失败！尝试返回")
                GoBack
                Sleep sleepTime
                return False
            }
            ; 如果有下一关，就点下一关（爬塔的情况）
            else if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text下一关, , , , , , , currentScale, currentScale)) {
                AddLog("战斗成功！尝试进入下一关")
                FindText().Click(X, Y, "L")
                Victory := Victory + 1
                if Victory > 1 {
                    AddLog("共胜利" Victory "次")
                }
            }
            ; 没有编队也没有下一关就点Esc（普通情况或者爬塔次数用完了）
            else {
                AddLog("战斗结束！")
                GoBack
                Sleep sleepTime
                return True
            }
        }
    }
}
;返回大厅
BackToHall() {
    AddLog("尝试返回大厅")
    Text := "|<大厅>*113$41.ztzzzzzzVzy007z3zs007y7zk00DwTzXzzzsTz7zzU00S802000Q006001s00Dw3zly7zs7zXwTzkDz7szz0DyDlzyADsTXzsQDlz7zVsDXyDy7sD7wTkTsAD0zVzsMy1zbzwtw7y"
    while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) { ;如果没有找到大厅的文本
        GoBack ;就一直按Esc
    }
    if !WinActive(nikkeID) {
        MsgBox "窗口未聚焦，程序已终止"
        Pause
    }
    Sleep sleepTime
}
;进入方舟
EnterToArk() {
    AddLog("尝试进入方舟")
    Text方舟 := "|<方舟内部左上角的文本>*111$36.zXzzVzzXzzVzz1zs03001s03001s33sDzsVXwTzslXw07st3w07U00w07U00sT7kX3sz7sXXkz7kVXkz7llXVy7VzX3UDXy37kDXy7zszzzDU" ;判断方舟内部左上角的文本是否存在
    Text大厅 := "|<大厅方舟的图标>*161$56.000zzk000001zzzs00001zzzzU0001zzzzy0001zzzzzs000zzzzzz000TzyDzzw00Dzy3VzzU07zy0s7zw03zz0C0zzU1zzU3U7zw0zzs3w0zzUDzw3zkDzw7zz1zy1zz1zzUTzkDzszzsDzy3zzDzzzzzUzznzzzzzzzzyTzzzzzzzzrzy7zzzzzxzzUzzzzzzDzw7zy3zzlzz0zz0zzsTzsDzkTzw3zy0zs7zz0Tzk7k3zzU3zy0s0zzk0TzkC0Tzw03zy3UDzw00TzssDzz003zzzzzz000DzzzzzU001zzzzzk0007zzzzk0000Dzzzk00000zzzU000000zy0008"
    while True {
        Sleep sleepTime
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3, 0.3, Text大厅, , , , , , , currentScale, currentScale)) { ;查找并点击大厅的方舟按钮
            FindText().Click(X, Y, "L") ;找得到就尝试进入
            Sleep sleepTime
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3, 0.3, Text方舟, , , , , , , currentScale, currentScale)) {
                AddLog("已进入方舟")
                break
            }
        }
        else BackToHall() ; 找不到就先返回大厅
    }
    Sleep sleepTime
}
;登录
Login() {
    AddLog("正在登录")
    Text大厅 := "|<大厅>*80$41.zkzzzzzzVzw003z3zk007y7zU00DwDz000zsTy7zz000A002000M000000k007w3zV00zs7z3wDzU7y7sTz0DwDkzw4DsTVzkMDkz3z0sDVy7w3s67wDUDk4C0T0zs8Q1z7zslw3y" ;大厅底部的文本
    while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3, 0.3, Text大厅, , , , , , , currentScale, currentScale)) { ;如果没有找到大厅的文本
        Confirm()
        ;点击蓝色的确认按钮（如果出现更新提示等消息）
        Text := "|<确认>*192$51.zz1zyDy7s0s0TUzkz0601y3y7s0U0TkTkzksT3z3y7yC3kTwzkzlk00zzy7wC0073zkzU800kDy7s1X761zkz0AMMsDw7s1U07lzUT2A00yDw3sFU07lzUT2AMMyDs1sFX77kb2DWAEEy0kkwF007k663W800y0VsA1737k8D0U0wsy23w407W7UUTUXkw0wC7y6SDU7nlzsU"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            AddLog("发现更新，尝试点击")
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
        Text := "|<一周内不再提示的空框>*200$28.7zzzVzzzz7zzzyzzzzzk003z000Dw000zk003z000Dw000zk003z000Dw000zk003z000Dw000zk003z000Dw000zk003z000Dw000zk003z000DzzzzxzzzzXzzzwU"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            AddLog("发现公告，尝试勾选一周内不再提示后关闭")
            FindText().Click(X, Y, "L")
            Sleep sleepTime
            Text := "|<叉叉>*174$29.bzzzxDzzzmDzzz6DzzwSDzzlyDzz7yDzwTyDzlzyDz7zyDwTzyDlzzy77zzy8Tzzy1zzzy7zzzs7zzzU7zzy67zzsS7zzVy7zy7y7zsTy7zVzy7y7zy7sTzy7Vzzy67zzy0Tzzy1zzzyE"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                Sleep sleepTime
            }
        }
    }
    AddLog("已处于大厅页面，登录成功")
}
; 前哨基地收菜
OutpostDefence() {
    BackToHall
    AddLog("==========前哨基地收菜任务开始==========")
    Text := "|<前哨基地>*96$123.zzzzzzzzVzz0000TUw40Dzzzzzzzw43U0003w0UU1zzzzzzztUUQ0007w0400DzzzzzzsA47U000zU0U0VzzzUzzk0UUyE007w040ADvzs7y0040Dy000zU001VwDz0zU0001zk007y0U0AD0zk0Q0400Ty000zw60VV83w01U0kUUzk007zUk4A80000A07007y000sw70U100001UU000zk0007Uo4080000Q40007y0000w0UV30000TUU000y00007U04Ds07zUw401s700001w0UVv07zQ7UU000k0000z047z0031Uw40007001k1U3Uzk00MA7UUU00s0M00A0w7w0011Uw44007s0001UTU00008A7UUUTUy000MSDy008011Uw046070007bzzk03108A7U0U00s4060zzz0Ds011Uw04007Xy007zzzzz008A7U1U00y0000zzzzzs011Uw7w1w7s000Dzzzzz1k8A7UzUz0z003zzzzzzs011UyDw7UDs1zzzzzzzz008A7zzUw1zzzzzzzzzzs03jUzzw7UTzzzzzzzzzz00Ds7zzUyDzzzzzzzzzzsT1s1zzwDzzzzzzzzzzzz3UD0DzzzzzzzzzzzzzzzsM3w3zzzzzzzzzzzzzzzz30TVzzzzzzzzzzzzzzzzsQDzzzzzzzzzzzzzzzzzz3nzzzzzzzzzzzzzzzzzzw"
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击进入前哨基地")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    else {
        AddLog("未找到前哨基地！返回")
        return
    }
    Text := "|<%>*74$24.U7y703y703w713wD33wD33sD33sT33sT33kT33kz33Uz33Vz33Vz033z033zU73zkC3zzy7zzw7zzwDzzwDzzsTzzsTzzsTzzks7zkk1zUU1zVU0zVUkz3Vkz3Vkz3Vky7Vky7Vky7VkwDVkwDVksTU0sTU0szk1szs3U"
    if (ok := FindText(&X := "wait", &Y := 10, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击左下角资源")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    Text := "|<免费一举歼灭的红点>*194$67.000000000C0000000000zs000000000sD000000001k1k00000001kwQ00000000lz600000000lzlU0000000tzwk0000000Rzy80000000QzzbzzzzzzzyTzm00000003Dzt00000000nztU0000000Nzwk00000004TwM000000017wM00000000k0M00000000A0M000000001zs0000000007s0000000003k0000000001U0000000000k0000000000M0000000000A0E"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime
        Text := "|<歼灭>*182$46.U3s7U000000S0008003s000kz0zzsTz3zXzzlzw0yDzz7zk3szwsSD0DXzlVsssU0y67XX001ssQQ40073Ulk1U0wS3D07szvk7zkzXzz0TzXyDzsEzwDszzVVzVzXzsC3wDyDz1w7UzszUDs27zXw1zk8zyDsTzkzztzrzzy"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            AddLog("点击进行歼灭")
            FindText().Click(X, Y, "L")
            Sleep sleepTime
            Text := "|<获得奖励的图标>*191$34.zzsTzzzzVzzzzy7zzzzsTzzzzVzzzzy7zzzzsTzzzzVzzzzy7zzzzsTzzzzVzzzzy7zzzk00TzzU01zzz00Dzzw01zzzs07zzzk0zzzz07zwTy0Tw1zw3zk7zkTz0TzVzw1zzDzk7zxzz0Tzzzw1zzzzk7zzzz0Tzzzw1zzzzk3zzzz000000000001U00007U0001s"
            while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                Confirm
                Sleep sleepTime
            }
        }
    }
    else AddLog("没有免费一举歼灭")
    AddLog("尝试常规收菜")
    Text := "|<获得奖励的图标>*191$34.zzsTzzzzVzzzzy7zzzzsTzzzzVzzzzy7zzzzsTzzzzVzzzzy7zzzzsTzzzzVzzzzy7zzzk00TzzU01zzz00Dzzw01zzzs07zzzk0zzzz07zwTy0Tw1zw3zk7zkTz0TzVzw1zzDzk7zxzz0Tzzzw1zzzzk7zzzz0Tzzzw1zzzzk3zzzz000000000001U00007U0001s"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击收菜")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    AddLog("尝试返回前哨基地主页面")
    Text := "|<%>*74$24.U7y703y703w713wD33wD33sD33sT33sT33kT33kz33Uz33Vz33Vz033z033zU73zkC3zzy7zzw7zzwDzzwDzzsTzzsTzzsTzzks7zkk1zUU1zVU0zVUkz3Vkz3Vkz3Vky7Vky7Vky7VkwDVkwDVksTU0sTU0szk1szs3U"
    while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        Confirm
        Sleep sleepTime
    }
    AddLog("已返回前哨基地主页面")
    AddLog("==========前哨基地收菜任务结束==========")
    if g_settings["Expedition"] ;派遣
        Expedition()
    BackToHall()
}
; 派遣
Expedition() {
    AddLog("==========派遣委托任务开始==========")
    AddLog("查找派遣公告栏")
    Text := "|<派遣公告栏的图标>*145$58.zzzzsTzzzzzzzy0zzzzzzzzU0zzzzzzzw00zzzzzzz000zzzzzzk1k1zzzzzw0Dk1zzzzzU3zU1zzzzs0yDU1zzzy0DUDU3zzzU1wQDU3zzw0T3wTU3zz07kzsT03zk1yDzsT07w0DVzzsT07U3sTzzsz040y7zzzsy00Dlzzzzky01wTzxzzky0D3zzXzzls0szzw7zzVU3bzzUDzza0CTzw0TzyM0tzzs1zztU3bzzkDzza0CTzzVzzyM0tyzzDzjtU3btzzzyza0CTbzzznyM0tyDzzzDtU3bszzzsza0CTVzzzXyM0ty7zDwDtU3bsDkTkza0CTUy0y3yM0ty1k0kDtU3bs6010za0CTU0003yM0ty0000DtU3bs0000za0CTU0003yM0ty0000DtU3by0001za0CTw000TyM0tzw007ztU3Vzw01zy60DXzw0DzVs0T3zs3zsT00T3zszz7k00T7zzzky080z7zzwDU3s0y7zz3s0Ts0y7zsz07zk0y7y7k1zzk1yDVw0Tzzk1w8T03zzzk1w7s0zzzzU1wy0DzzzzU3zU3zzzzzU3s0TzzzzzU307zzzzzz001zzzzzzz00Tzzzzzzz03zzzzzzzz0zzzzzzzzyDzzzzU"
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击派遣公告栏")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
        Text := "|<全部领取的符号>*190$28.zz3zzzwDzzzkzzzz3zzzwDzzzkzzzz3zzzwDzzzkzzzU07zy00zzw03zzs0TzzU3zzz0Dz7y1zUTs7y1zkzs7zbzUTyzy1zzzs7zzzUTzzy1zzzs7zzzU000000000U0006"
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
            AddLog("点击全部领取")
            FindText().Click(X, Y, "L")
            while True {
                Text := "|<左上角的派遣>*149$68.000040001w01k00TU20TzzUS03zw1sDzzsDszzzUz3zzy3zTzzsDsyTDUTbzzk1zDzzs1tzy00Dnzzy0AT0101szzzU07k7s0Q07k001wzz00Dzzzm0TDzs03zzzxs7nzy00zzzyzVwzs001zzwDwTDS0TwTzz1z7nrk7z7zzk7VwxxVzlw1w0sTDDwTwTzz007nnzXz7zzk01wwzs7lzzw08SDDw1wT00077Xny0T7zzw1tswT07lzzz0yyD7k1wTzzkDjXlw0T7k3w7nswTU7lzzz1wyDDs3wTzzkyD7yz1zrzzsTblzrszzU01rlwTxyTzzzzxwyDyD7nzzzzSDVy3kwDzzzVXsQ0M60zzzs0A2000U0zzwU"
                while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                    Confirm
                }
            }
        }
        Text := "|<全部派遣的符号>*193$35.00Ty0007zz000zzzU03zzzU0DzzzU0zzzzU3zzzzUDzzzzUTzzzzVzbwzz3y7kzz7w3UzyTw3Uzwzw3Uztzw3Uzvzw3Uzzzy3Uzzzs71zTzUQ7yzy1kTxzs71znzUw7zXy3UTz7wDVzwDwzbzsDzzzzUTzzzz0Tzzzw0Tzzzk0Tzzz00Tzzw00Dzzk007zy0001zU08"
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
        Text := "|<派遣的符号>*191$33.zzUDzzzU0Dzzk00Tzs000zy0003zU000Ds0000y00003k0000Q0k601UD1s081wTU007ly000T7s001wTU007ky000T3s003wT000z7k00Dlw003sT000y7k00DXw041sT01U61k0C00003k0000T00007w0001zk000Tz0007zw001zzs00zzzk0TzU"
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            AddLog("点击全部派遣")
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
    }
    else AddLog("派遣公告栏未找到！")
    AddLog("==========派遣委托任务结束==========")
}
; 付费商店每日每周免费钻
CashShop() {
    BackToHall
    AddLog("==========付费商店任务开始==========")
    AddLog("寻找付费商店")
    Text := "|<付费>*190$44.003U3zz0M0sDzzsD0C3zzy7k3UTzz1s1y7zzkyzznzzzTzzwzzzrzzyDyxzw0S0yDSz23VzXqDlksDzzVwSC1zzsD7XUDyS3kws3XXUQCC0tss703UDzy3k0s3yzwQ3y7z1z71zVz01VkTkA000Q000000U"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        Text := "|<带点的商店>*197$82.000000000008zs00000000000lz000000000003Vk00000000000304000000000007Xk00000000000Dw000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000s000000001k007U00000000D00Tzz0000000zzz7zzw000000DzzwTzzk000000zzz1zC00000000DXk7Uw00000000STMS3zk000000TzzVsDz0000001zzy7Uzw0000007zysS3k0000000TxzVsTy0000001zXy7zzs0000007zzsTzzU000000TzvVrkS0000001rbiDS1s0000007TysxzzU000000RzvXrzy0000001rzyCTzs000000787sNs00000000Q0C00000000001U0000000000008"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
            AddLog("点击付费商店")
            FindText().Click(X, Y, "L")
            Sleep sleepTime
            Text一级红点 := "|<一级页面小红点>*199$19.1zk3sw3U333slbyBbzWnztvzwtzzQzzCTzbbznnztsztaDslU0kM1k7zk1zUE"
            Text二级红点 := "|<二级页面小红点>*199$66.000000003y000000000DzU00000000S1s00000000k0M00000001nyAzzzzzzzXbzCzzzzzzzzDzazzzzzzzzDzbzzzzzzzzDznzzzzzzzzDznzzzzzzzzDznzzzzzzzzDznzzzzzzzzDzXzzzzzzzz7zazzzzzzzzXzCzzzzzzzzlwAzzzzzzzzs0wzzzzzzzzz3kzzzzzzzzzzUzzzzzzzzzzUzzzzzzzzzzUzzzzzzzzzzUU"
            Text三级红点 := "|<三级页面小红点>*169$47.zzzzzzztzzzzzzzvzzzzzzzzzzzzzzzzzzzzzzzzzzzzlzzzzzzw0TzzzzzkwTzzzzz7wTzzzzyTwTzzzztzwzzzzznztzzzzzbztzzzzzDznzzzzyTzbzzzzwzyTzzzzszwzzzzzsznzzzzzky7zzzzzk0Tzzzzzs3zw"
            while true (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text一级红点, , , , , , , currentScale, currentScale)) {
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text一级红点, , , , , , , currentScale, currentScale)) {
                    AddLog("点击一级页面")
                    FindText().Click(X, Y, "L")
                    Sleep sleepTime
                }
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text二级红点, , , , , , , currentScale, currentScale)) {
                    AddLog("点击二级页面")
                    FindText().Click(X, Y, "L")
                    Sleep sleepTime
                }
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text三级红点, , , , , , , currentScale, currentScale)) {
                    AddLog("点击三级页面")
                    FindText().Click(X, Y, "L")
                }
                Text := "|<付费商店>*154$74.szby0TzszzwTyDtw00Q00Dz3z7yTU07001k00lz3k01k00w008E0Q00Tllz7Xw407003wMTlsz103k00s00wS0ETty34C00D7U06SS1l7a8nls0lXbk03s60wSDwMty00y1kD00776TW4DU03U01lnbslXt6AsU0QTty8syFXC8z77wTU0TY0nW01ls7U40t78lU0QS1sDsCTsCM07DVzzzzbzDzTvU"
                while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                    Confirm
                }
            }
        }
        else AddLog("付费商店已领取！")
    }
    else AddLog("付费商店未找到！")
    AddLog("==========付费商店任务结束==========")
    BackToHall
}
;普通商店
NormalShop() {
    BackToHall
    AddLog("==========普通商店任务开始==========")
    Text := "|<商店>*175$61.zzzzzzzsDzzzzzzzzw7zzzsTzzzy007zs7yDk0003zw007k000000003s000000001w007zU000Dy3z7zk0DUTz1z1zzw7kTzUzU07y3sDTkTk03z0007sDs01k0003w7w00k0001y3y1zs003Uz3z1zw71UkTVzU0C31k0Dkk00710w07sM003U0y03wA001k0011w60TUs801Uy33zkQ400kT1VzsC33sMDVkE071VsA7Us003Uk063kQ001kM033sS03UsA3w1wD1zzw6Dy0zbbzzy3zz0zzzzzz1zzrzzzzzzUzzzzzzzzzk"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击商店图标")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    else {
        AddLog("未找到商店图标")
        BackToHall
        return
    }
    Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
    if (ok := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
        AddLog("已进入百货商店")
    }
    loop 2 {
        Text100 := "|<100%>*205$34.XUC0loA0k3KQnnDBPnDAwlDAwnnxwnnDDbnDAwyTAwnnmAnnDD+n0A0tfC0s3a8"
        while (ok := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text100, , , , , , , currentScale, currentScale)) {
            AddLog("点击免费商品")
            FindText().Click(X, Y, "L")
            Sleep sleepTime
            Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
                AddLog("点击购买")
                FindText().Click(X, Y, "L")
                Sleep sleepTime
            }
            ;确认至百货商店页面
            Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
            while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                Confirm
            }
        }
        else {
            AddLog("没有可白嫖的东西")
        }
        Text := "|<芯尘盒>*174$62.1UM00k00600wD00S003k0Tzw1ba03z0Tzzkxvk3zwDzzwSSy3zztzzyDbbnzzz3mw7lsyzzzUNq1sS77zzk0w0A7UUTzs07U00k07zy0RsE0S01zzVzDS07U0DzkTn7Vzzs7zy7w1sTzy3zzlz0D7zzUzzwxkTk1s0DzzDSDw0S03zzkbzkTzzvzzz1zs7zzyzzzk7w1zzzjzzy"
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            AddLog("点击芯尘盒")
            FindText().Click(X, Y, "L")
            Text := "|<信用点的图标>*169$29.000k0001s000Tk001vk007Xk00TDk03znk0DzDU0zyTU7zzz0Tzzz1zzzz7zzzwjzzxnDzzy6Dzzs0TzvU8zzy09zzk0DTr00DzQ00TxU00Te000Ts000RU000Q0000E004"
            if (ok := FindText(&X := "wait", &Y := 5, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
                if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
                    AddLog("点击购买")
                    FindText().Click(X, Y, "L")
                    Sleep sleepTime
                }
            }
            else {
                AddLog("只使用信用点购买，跳过")
                GoBack
            }
        }
        ;确认至百货商店页面
        Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
        while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
            Confirm
        }
        Text := "|<FREE>*184$36.UA7kC0081U607slXyT7ssXyT7ssUC10MlUC10M1XyT7s3XyT7slU60bstU60U"
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , 1, , , , , currentScale, currentScale)) {
            while true {
                Text := "|<刷新的图标>*154$19.zlzz07y00C7w77z37z1bzs3zzVzz8zzUTzlzzs7zwUDwMDwA7wC0sD80Dz0Tk"
                if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, 0, , , , , , currentScale, currentScale)) {
                    AddLog("免费刷新一次")
                    FindText().Click(X, Y, "L")
                    Sleep sleepTime
                }
                Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
                if (ok := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
                    FindText().Click(X, Y, "L")
                    break
                }
            }
            Sleep sleepTime
        }
        else break
    }
    AddLog("==========普通商店任务结束==========")
}
; 竞技场商店
ArenaShop() {
    AddLog("==========竞技场商店任务开始==========")
    Text := "|<竞技场商店的图标>*127$42.zzs0DzzzzU03zzzz001zzzy1y1zzzw7z0zzzsTTUzzzswDUzzzkwDUlzylwDUwTsVsDVz7lXsD1zXXXsS3zl7XsE7zt7XU0TzsD301zzsD3U0Tzs73kkTzsb3ksDzlXXks7zntXkw7wrxVUw3szzVUy1kzzk1z01zzk1z03zzw1zU7zzy3zsTzU"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("进入竞技场商店")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    Text := "|<燃烧代码的图标>*100$15.ztzyDz1zkDw0z07k0S23UsAD01s0DUVw4DldyD7nwww"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.23, 0.23, Text, , , , , , , currentScale, currentScale)) and g_settings["BookFire"] {
        loop ok.Length {
            FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
            Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
            if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
                AddLog("购买燃烧代码手册")
                FindText().Click(x, y, "L")
                Sleep sleepTime
                Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
                while !(ok2 := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                    Confirm
                }
            }
        }
    }
    Text := "|<水冷代码的图标>*122$17.zrvzDbwSDkQDUkS1Vs1bU3z07w0Ds0TU0z01z07y0Ty1zs"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) and g_settings["BookWater"] {
        loop ok.Length {
            FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
            Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
            if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
                AddLog("购买水冷代码手册")
                FindText().Click(x, y, "L")
                Sleep sleepTime
                Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
                while !(ok2 := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                    Confirm
                }
            }
        }
    }
    Text := "|<风压代码的图标>*150$21.zwTzz1zzkCDy00s017U6QbzrU000z00Czzzk07zs0TzznzzDTztnzz4Tzw7w"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) and g_settings["BookWind"] {
        loop ok.Length {
            FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
            Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
            if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
                AddLog("购买风压代码手册")
                FindText().Click(x, y, "L")
                Sleep sleepTime
                Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
                while !(ok2 := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                    Confirm
                }
            }
        }
    }
    Text := "|<电击代码的图标>*110$12.zxztznznzXz7y7y7w7s7k1k0U001w3y7w7wDwTwztztzvzrzU"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) and g_settings["BookElec"] {
        loop ok.Length {
            FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
            Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
            if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
                AddLog("购买电击代码手册")
                FindText().Click(x, y, "L")
                Sleep sleepTime
                Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
                while !(ok2 := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                    Confirm
                }
            }
        }
    }
    Text := "|<铁甲代码的图标>*150$20.sDVs1kC00100000000000000006001k00z00zk1zw0zy0DzU3zs0zy0Tzk7zy7zs"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) and g_settings["BookIron"] {
        loop ok.Length {
            FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
            Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
            if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
                AddLog("购买铁甲代码手册")
                FindText().Click(x, y, "L")
                Sleep sleepTime
                Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
                while !(ok2 := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                    Confirm
                }
            }
        }
    }
    Text := "|<代码手册宝箱>*157$79.000000000000000000000000000000000000000000000zy00000000001w7k0000000001U0A0000000003yIzU00000000DVlly00000000y0ss7s0000007s3sTUDk00000T0S0060z0000Tw1k000M1zk01tk600I0VU7j03U8M00C00H00s30RU000000Bk610780000000W1VkwE000000161kyz000000002nsTsC0000000sDwDM1k000001U3y7y0700000607z3zs0TU001w0TzVzzU1w007k1zzkzjw0D007U7zzsT7zk0w0C0TzzwDXzy03Vs0zzzy7ljzs1ss3zzyz1klzzV01DzzzT0kS7zxU0jzzzzUMAsTzw1rzzxzkA633zz1vzztzs630QTDzzzznTw31U1VXzzzzCDy4"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , 0, , , , , currentScale, currentScale)) and g_settings["BookBox"] {
        FindText().Click(x, y, "L")
        Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
        if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            AddLog("购买代码手册宝箱")
            FindText().Click(x, y, "L")
            Sleep sleepTime
            Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
            while !(ok2 := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                Confirm
            }
        }
    }
    Text := "|<礼包>*179$37.6301k03Xk0s01ls0zzbyw0zzvzS0zzwzj0zyS3bUTzD3nk7zrXts1zvryw0Qxvzy0Dytzz07zwLrb3zy3XnVkDVltks1sszsTzwQDsDzwC3s1zwU"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) and g_settings["ArenaShopPackage"] {
        FindText().Click(x, y, "L")
        Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
        if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
            AddLog("购买简介个性化礼包")
            FindText().Click(x, y, "L")
            Sleep sleepTime
            Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
            while !(ok2 := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                Confirm
            }
        }
    }
    Text := "|<熔炉>*171$40.60k0k20s3U30Q3XzsS1kCTzVs7Uzzy7zzzzltzzzzzjbzzzyySTzVzrztzC7yDzbszzsTwT3znXzsQTzDTzltsQzzy7rU7zzsTS0Trj3zk3qQQCz0CFzltw0s7z73U10TwA608"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) and g_settings["ArenaShopFurnace"] {
        AddLog("购买公司武器熔炉")
        FindText().Click(x, y, "L")
        Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
        if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(x, y, "L")
            Sleep sleepTime
            Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
            while !(ok2 := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                Confirm
            }
        }
    }
    AddLog("==========竞技场商店任务结束==========")
}
; 废铁商店
ScrapShop() {
    AddLog("==========废铁商店任务开始==========")
    Text := "|<废铁商店的图标>*160$40.zw000zzzU001zzy0003zzk000Dzz3zzkTzsDzzVzz1zzy3zw7zzwDzUy7zkTy7s7zVzkTU7y3z3z07w7sDz0TsT1zz1zUwDzy7z3UzsTzw67zUTzsETy0TzU1zw0Tz27zw1zs8Dzw7z1kzzsTw71zVzzUy7y1zy7sDs1zkTkTk1z3zVzk7sDy3zkT1zwDzVwDzkTzzUzzVzzy7zy3zzkTzw0003zzs000DzzU001zzz000DzU"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    if g_settings["ScrapShopGem"] {
        Text := "|<珠宝>**50$41.00Q01s0zjs03k3TREDyzziewTxzrRRwzzxWbvts0/5DrnU0Kvwc7zzxr/E7wzbjyz7xz7Tky0O02bVwDrs5130TDk+a60zRUrT61yv7Xyy0BSDzpyTuzDz+xzrjEQInzzz"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
        ; 珠宝领了就默认整个任务做完了
        else {
            AddLog("已执行，跳过")
            AddLog("==========废铁商店任务结束==========")
            BackToHall
            return
        }
        Text := "|<MAX>*124$23.76CMCAAkQMN0kksEVVkV33V267649DA0GCM0UME10kU21V8Ym2F1YUW31Vgi78"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
        Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            ;确认至百货商店页面
            Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
            while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                Confirm
            }
        }
    }
    if g_settings["ScrapShopVoucher"] {
        loop 6 {
            Text := "|<礼物的图标>*195$22.3sS0Tnw1XwM67VUMQCDzDzzwzzznzzzDzzwzzznzzzDzzwzs0000000Dwzkznz3zDwDwzkznz3zDwDwzW"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , 1, currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                Sleep sleepTime
            }
            Text := "|<MAX>*124$23.76CMCAAkQMN0kksEVVkV33V267649DA0GCM0UME10kU21V8Ym2F1YUW31Vgi78"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                Sleep sleepTime
            }
            Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                ;确认至百货商店页面
                Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
                while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                    Confirm
                }
            }
        }
    }
    if g_settings["ScrapShopResources"] {
        loop 6 {
            Text := "|<小时>**50$83.000003zw0000000000063zC00000000008AjzA000000000k0bzzA00000001006R7zC000Dzzzzzzzzzz401k000000001zy0C2000000000RA0lzU00000000TM16zk00000000Pk6SLk00000000OU9vvU00100A00q0nQxU0k71wM00Y0ARn03kC3zs01c2MCS07XRazs03E4k3o076PB/U0701UAc0CBrSL00+030Hk0Qviby00Q0G0xU0trBBw00c0b1a03nCPss03E07Uw0DkQ7lU07817yk0TXsAD00SE17j0003U0S01YU11k000000007N01U000000000vW01zzzzzzzzzz5A00008020V0lHC00000k00060VXA00001U0000MX7NE"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3, 0.3, Text, , , , , , 1, currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                Sleep sleepTime
            }
            Text := "|<MAX>*124$23.76CMCAAkQMN0kksEVVkV33V267649DA0GCM0UME10kU21V8Ym2F1YUW31Vgi78"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                Sleep sleepTime
            }
            Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                ;确认至百货商店页面
                Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
                while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                    Confirm
                }
            }
        }
        Text := "|<信用点>**50$62.21U00000C01kw0Tzy03k0Q7U7zzU0jyDzTVTDg081XjrwLrv02ztf0755Wk0c0uE1VTTgDvyAY0ELnv3yzW9UA5wykjzcuE11TTg/zuCY0EIK/2U2Udzw5xykjzc+E13TDg9zu2Y0Ezrv3zzUdzqDzykUu8+TzXlMgQ2j2b1tsK/7ivsdzyS5yXnjS+LxbVrswdnnbztkRyCCQstkA83C0300U"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3, 0.3, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
        Text := "|<MAX>*124$23.76CMCAAkQMN0kksEVVkV33V267649DA0GCM0UME10kU21V8Ym2F1YUW31Vgi78"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
        Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            ;确认至百货商店页面
            Text := "|<百货>*128$36.zzzwMt001sM1001kE1z3zU0Bz3zk0sk07ws0k07ww1k07wzzlz7s03ly7s03k07slXk07slXlz7slXlz7sV3k07y07k07U60k07kTlnz7vzzU"
            while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
                Confirm
            }
        }
    }
    AddLog("==========废铁商店任务结束==========")
}
; 好友点数收取
FriendPoint() {
    stdTargetX := 3729
    stdTargetY := 553
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [64]
    stdCkptY := [470]
    desiredColor := ["0xFAA72C"]
    while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入好友界面失败！"
            Pause
        }
    }
    stdCkptX := [2104, 2197]
    stdCkptY := [1825, 1838]
    desiredColor := ["0x0CAFF4", "0xF7FDFE"]
    stdTargetX := 2276
    stdTargetY := 1837
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) && !UserCheckColor([2104, 2054], [1825, 1876], [
        "0x8B8788", "0x8B8788"], scrRatio) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入好友界面失败！"
            Pause
        }
    }
    while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "赠送好友点数失败"
            Pause
        }
    }
    stdTargetX := 333
    stdTargetY := 2041
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [64]
    stdCkptY := [470]
    desiredColor := ["0xFAA72C"]
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退出好友界面失败！"
            Pause
        }
    }
}
; 模拟室
SimulationRoom() {
    EnterToArk
    AddLog("==========模拟室任务开始==========")
    AddLog("查找模拟室入口")
    Text := "|<方舟中的模拟室>*121$58.zzzzzzzzjz727lrszsTwM0D6DXU00lU0wM6A0023070UMk00040Q01XXzkUU0k80D00D603lW1y00w80D6A7w67UU0w8wTU0C00303lw00M00Q2D7s0n0k1kM0Da7A603lU0w00EM07603k01lk0wM07i2D703V20M00AEA4Csl000lXsszni003jzzzzzzzzs"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("进入模拟室")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    Text := "|<左上角的模拟室>*106$56.ltXtzxzwTwM0SASC007603X1XU00UU1kk8s00040s02C000006003U01UU1kl0y00w80SAEDUET007V7Xs07U01U1sy00s00M0QDU2A006303s1X1U0kk0w00kE0CA0700C607W01zVzlU1kW0M00QEQABla0036Db7wvU01U"
    while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        Confirm
    }
    ; 还在模拟中就退出（话说为啥）
    Text := "|<模拟结>*95$58.A6A3000E30kzsAM61UQ37zklcMC1kADQ37lUlzzwNkzP67LzzrzXxiMtVkATy36PXy70tzsANiDnzbrzUlUkiDzTM63q30s01zzszMA7s0DHz3lZszjyw3U37rXszunzwATS03VfDzklnw0i6A7Q3CQnysMlswQnnjvzXD1nk6AkDyAE040000kO"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("退出进行中的模拟")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
        Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
    }
    Text := "|<开始模拟>*174$88.zzzz7wzyTbDtzzy001wTlzts0DXbwk007lyDzb00SSPnU00T7szyQ03ssDDsyDs77DUSQy1YMzXtz0AQQ1U1s6NXyDbw0Xss403UNWDsyTsU03slyDXa8zXszW007X00yCQX000CNUwQ403styQ000tbzzk1yDVbtk0036Tzy000s6TbwTby1U0sK07UtwTlyTwC031z7yXYEz7tzssyA600SC03szbzVXsuQ01ssM7XyTw2DXty0zX34QTtzV8yDbkVyAQM1zbwDU0yQ71VnXUDyTly03tUy67ySPztzztyTbTywzzzU"
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击开始模拟")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    ;打过了就直接退
    Text := "|<已通关>*197$62.00000001047zz0kzy0s7XzzsSDzUD1kTzy3kzk1kw007UQDs1zzk00s3DzUzzyQ0C03zwDzzb03U0zz03k1zzsTDzk0Q0Tzy7nzw0DU7zzVwzz7zzxs0s7DzlzzzQ001nzwTzzb000Qzz07w1k0C7ATk1zUS03Vz7w1xw7U0szli0yDkzzyTzztz1zDzz7DzyT07kzzUUTz7U0u"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("今日模拟室已通关")
        GoBack
        AddLog("==========模拟室任务结束==========")
        return
    }
    AddLog("选中5C")
    Text := "|<5>*163$22.7zzUTzz3zzwDzzkzzz3zzsDk00z003w00Dk00zz03zz0Dzz1zzy7zzwTzztz0zU01y007w00Dk00z003xw0Tzs1yTkDtzzzXzzw7zzUDzw0TzU0Ts2"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime // 2
    }
    Text := "|<C>*164$26.01zU03zz03zzw1zzzUzzzwTzzy7zUz3z03lzU08Tk007s003y000z000Dk003w000z000Dk003w000z000Dk001y000Tk007w000zk0MDy0T1zzzsDzzz1zzzUDzzk1zzs07zs007U2"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime // 2
    }
    Text := "|<快速模拟的图标>*200$42.zzk07zzzz000zzzw000Dzzk0007zzU0001zz00000zy00000Tw00000Ds00000Ds000007k0U1003k1k3U03U3s7k01U3yDs0103z7w0100zXy0000Tlz0000DsTk0007wDs0003y7w0001z3y0001z3w0003wDs0007wTk000TkzU000zVz0001z3y00U3y7w01U3w7s01U3s7k03k0k3U03k000007s000007w00000Dw00000Ty00000Tz00000zzU0003zzs0007zzw000Tzzz001zzzzs07zzU"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击快速模拟")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    Text := "|<跳过增益选择的图标>*141$26.s0k0D0D03w3s0zUzUDyDw3znzkzzzyDzzzvzzzzzzzzjzzznzvzszwzsDwDw3y3w0y0y0D0C010300U"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("跳过增益选择")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    EnterToBattle
    BattleSettlement
    Text := "|<模拟结束的图标>*159$38.03zzzy01zzzzs0zzzzy0Dk00Dk3k001w0w000D0D0003k00000w00000D000003k0U000w0M000D0S0003kDU000w7zzU0D3zzs03nzzy00xzzzU0Dzzzs03zzzy00xzzzU0DDzzs03lzzy00wDzzU0D0y0003k7U000w0s000D020003k00000w00000D000003k3k000w0w000T0DU00Dk3zzzzw0Tzzzy03zzzz0000302"
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击模拟结束")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    AddLog("==========模拟室任务结束==========")
}
; 模拟室超频
SimulationOverClock() {
    AddLog("==========模拟室超频任务开始==========")
    Text := "|<剩余奖励的0>*80$26.s001wTzyCDzzl600C3001lU00AE0014000F0004E3w141VUF0E84E421410UF0E84E66140z0F0004E0014000FU00AA0071U03WDzzllzzsy000S"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        Text := "|<开始超频>*173$63.zzyD7ztzwzs01nszyA1a000CTBX0FY077DUF4Q6Abnttw2QXtk4k7DDU00M0E0000C40E7z02001UrrHUACE00A7zs41U27DDkk70aA0Eltz60kA1806DDs3a3UD34Xty0QkDzsw8zDXk6E0AC0jtyy0n01Xlo"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
    }
    else {
        AddLog("本次模拟室超频已完成！")
        return
    }
    Text := "|<BIOS>*168$49.03wzVzk3U0yT0Dk0E0DD03k09z7b3kszUzXn7wQzy01tXz60D00wlzX01U0CMzls0Hz7ATszz1zlaDwTzUzsnXwQzkDstk0S7k00Qy0TU0U0STUTs0s"
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    Text := "|<25>*121$44.U00y000k007U00A000s003000C000k001000DzzUEDzzzzw63zzzzz1Uzzzk00M00Dk006000w003U00C001s001U00y0000Dzzzzw03zzzzz00zzzzzk0001U000000E0010006000s001U00S000M00DU"
    if (ok := !FindText(&X := "wait", &Y := 5, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("未选择难度！跳过")
        return
    }
    Text := "|<开始模拟>*177$110.zzzzzzzzzzTztzzzzzzzzzzlzszzXwQDwTzyT0003wTwDzkw00z7Xz3U000T7z7zwC007lsTks000DlzVzz3U01wS0wS0003wTsszkz73z3UD7z3wDw0QCDk3ttz08Flzkz3y077ls0k07U2AQTwDkzU1VwD0A00w1X37z3wDyAEE3wD00Tlsslzkz3zX000T3lz7wSCATwDkzsl007kM00z7XX7U008QQEDlw200Tkszlk00076Dzzy0Vz3w2DsQ0001lXzzzU000w0XyDU000w8s03k000S0MzXzlz3z0C00w3z1zUCCkTsTkzw3U0C0zszx7U47y7wDzUszXUC007ls00zVz3zsCDss3001wS0UDkzkzy1XyDMk00T7UM1sDwDz0MzXyDs1zlkQ8Q7z3zVa7kzXwADwQC763zkzkTU0Dss70S7b1k0zwDwDs03wA3s71zkwMTz3z7y60z33zXkTyTjTzlzzzbzTtzzzyzzzzU"
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    loop 6 {
        Text := "|<获得>*120$30.xvzzzU0D8000C8sstwM0duxcsVkT80XnSA100A80s0880llwDlVlz009UzBntYTAnkCDCHWTDD3U"
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
        EnterToBattle
        BattleSettlement
        Text := "|<连结等级>*179$51.Mk663jVjnzsrwzyByDzDzjzXKkDXwkzwSqzzTTXzbrvjtnwzyQzDzDTDznrNzvzwzyzyAQ8NbznxnVVzACMTyzzzzUr3TuTt3w1s3FU"
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
        Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
            AddLog("模拟室超频第" A_Index "关已通关！")
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
    }
    Text := "|<模拟通关>*103$63.rqzTzzzzzzyM1tbbQ0TDXm07AAkk3sswAHl1b71z2700A04yk3U0AM1l47w0C03V0DAUtUFz7w01s7640DszU0A0ssUF00001V67Y0A0130CA0wUFy3sE0t03YkDUDnUT8UM63sMSMEl8E0087UmD4TaHU1Xy4"
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("挑战最后一关")
        FindText().Click(X, Y, "L")
    }
    EnterToBattle
    BattleSettlement
    Text := "|<模拟结束的图标>*159$38.03zzzy01zzzzs0zzzzy0Dk00Dk3k001w0w000D0D0003k00000w00000D000003k0U000w0M000D0S0003kDU000w7zzU0D3zzs03nzzy00xzzzU0Dzzzs03zzzy00xzzzU0DDzzs03lzzy00wDzzU0D0y0003k7U000w0s000D020003k00000w00000D000003k3k000w0w000T0DU00Dk3zzzzw0Tzzzy03zzzz0000302"
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    Text := "|<连结等级>*179$51.Mk663jVjnzsrwzyByDzDzjzXKkDXwkzwSqzzTTXzbrvjtnwzyQzDzDTDznrNzvzwzyzyAQ8NbznxnVVzACMTyzzzzUr3TuTt3w1s3FU"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    AddLog("==========模拟室超频任务结束==========")
}
; 新人竞技场收菜
Arena() {
    EnterToArk() ;进入方舟
    AddLog("==========竞技场收菜任务开始==========")
    AddLog("查找奖励")
    Text := "|<SPECIAL>*103$36.V132Qn1162Mn99CGMHB9COMHD9CSMH312SMHV12SMHt3CSMHtDCSEH9DCGE31DC2H31D22H0XjX7H0U"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击奖励")
        FindText().Click(X, Y, "L")
        Text := "|<领取>*179$44.sw0C07zwC0300zz3k0s000UTXzCA01XszlX74Q00w0tt1U0D0CQKDBXlXb7nn8wsslswmD6CAk3AXk3mA0m8w0w3yAWD4D1zb8XnXsTlmMwsS7UwaS03VkDkT01kC7w3k0s1kyATyAACC7XzW7XnXwzsnxU"
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            AddLog("点击领取")
            FindText().Click(X, Y, "L")
            Sleep sleepTime
            Confirm()
        }
    }
    else AddLog("未找到奖励")
    AddLog("尝试确认并返回方舟大厅")
    Text := "|<方舟页面左上角的方舟>*111$36.zXzzVzzXzzVzz1zs03001s03001s33wDzsVXwTzslXw07st3w07U00w07U00sT7k33sz7sXXkz7kVXkz7llXVy7VzX3UDXy37kDXy7ztzzzDU"
    while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        Confirm
    }
    AddLog("==========竞技场收菜任务结束==========")
    AddLog("进入竞技场")
    Text := "|<竞技场>*80$59.zUzwDVz70T001sT3y80C003kU0wE0S00C000sk1y3Vw0010w7U0081Uy0UT000MDVw001U03sE0Q403007k00QM0600C001ss0ADsQ033lk0M00s647U00k01sC0T00Vk07sQ1s013sEnkw3k66D1V3V01Vw8E704001jk0US0MAC3zW1Xz1stzDzyD"
    while (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击竞技场")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
}
; 新人竞技场
RookieArena() {
    AddLog("==========新人竞技场任务开始==========")
    AddLog("查找新人竞技场")
    Text := "|<新人竞技场>*92$92.wznzlzzszwTXyTzy7UDwTy00D7sz60C007z7zU03lk1tU3U0Tzlzy43s00CQ0wF7zwTz0kw0021kz4Fzy7z0010QDUEDU00zUzk00QD3s00000DsDz00T607303Vk3y3zk07k00tk0U0Fz0Tw01k00QS0804Tk3z00Q1677420F7sEzk071k3s18U4FwC7w01wS0w0W804S3kzkXj7US0FUE371w3sMtlk3VwMUElUzUE60EE09w0ACAMTyA3U4463z67bz7jzr3y3XbtzvXU"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击新人竞技场")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    AddLog("检测免费次数")
    Text免费 := "|<免费>*186$36.wTzy4Ls0zk01k0zz4FVkzk01103k03003k00U1Xk00XXXwQMnXXUQFk03k03k03s03z0zszXy8zslXwMtsXXksts671s1UC0bw3UzsU"
    while (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text免费, , , , , , 3, currentScale, currentScale)) { ;3代表从下往上找
        AddLog("有免费次数，尝试进入战斗")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
        ;检测是否开启快速战斗
        Text := "|<ON>*185$32.z7zzyT0TjzXU1szsksC7y8zXUzWDwM7s7z60S1zlX3UTwMsMbz6D08zVXs27kszUk0SDwC0DXzXs7szzU"
        if !(ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            Text := "|<OFF>*159$49.z7zk0TU0y0zU0700C07U0300671lzzXzyDsszzlzz7yATzszz7z601w03XzX00y01lzlXzz7zwzslzzXzyDsszzlzz3sQTzszzk0SDzwTzw0T7zyDzzUzXzz7zw"
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                AddLog("有笨比没开自动战斗，帮忙开了！")
                FindText().Click(X, Y, "L")
                Sleep sleepTime
            }
        }
        ;点击进入战斗
        EnterToBattle
        ; 确认结算
        BattleSettlement
        Sleep sleepTime
    }
    AddLog("没有免费次数，尝试返回")
    ;如果左上角有新人竞技场就点返回
    Text := "|<新人竞技场>*111$93.lzXzVzzkzwTXyA0s10DwDy007XwTlU3007zVzs00wM0CA0M07zwDzlsz001lw7a8zzVzk00k00A31s17zwDy0030wT001001zVzk00QT3w00000Ds7zU0DV01lU0ss3z0zw01w00CC0004Ts3zXwC0XXll000Xy4Tw01sA8SC8014TVVzU0D3k7k2808XwC7w03wS0w0n00AT3kTslrXsD0QM8VXUz1w6AQQ0wT6ACAMDw61k3201zk1lvXXztkS0sMQDy8A"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        GoBack
    }
    AddLog("已返回竞技场页面")
    AddLog("==========新人竞技场任务结束==========")
}
;特殊竞技场
SpecialArena() {
    AddLog("==========特殊竞技场任务开始==========")
    AddLog("查找特殊竞技场")
    Text := "|<特殊竞技场>*93$91.tyDzzDzlzsyDszzws1U07s00wT7wM0kQ0E03w00SA0CA0M60AC0DVkw0077kQ1sy207UkS0031kS0010030010wT0ED000U2DU00kyDU004k0l13w01wM0QM0CTsl00C00y00CC0600000700Q0077000040U7U0C137X00003kk7k071l3k000lXss3s03sw3k20QslwE0z0CwS3k34CSMsEUD36CC0sD6CDUMMF41U4406z07bsQSsy3k2633zW3nwDzwT7y77jtzv3U"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击特殊竞技场")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    AddLog("检测免费次数")
    Text免费 := "|<免费>*186$36.wTzy4Ls0zk01k0zz4FVkzk01103k03003k00U1Xk00XXXwQMnXXUQFk03k03k03s03z0zszXy8zslXwMtsXXksts671s1UC0bw3UzsU"
    while (ok := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text免费, , , , , , 3, currentScale, currentScale)) { ;3代表从下往上找
        AddLog("有免费次数，尝试进入战斗")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
        ;检测是否开启快速战斗
        Text := "|<ON>*185$32.z7zzyT0TjzXU1szsksC7y8zXUzWDwM7s7z60S1zlX3UTwMsMbz6D08zVXs27kszUk0SDwC0DXzXs7szzU"
        if !(ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            Text := "|<OFF>*159$49.z7zk0TU0y0zU0700C07U0300671lzzXzyDsszzlzz7yATzszz7z601w03XzX00y01lzlXzz7zwzslzzXzyDsszzlzz3sQTzszzk0SDzwTzw0T7zyDzzUzXzz7zw"
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                AddLog("有笨比没开自动战斗，帮忙开了！")
                FindText().Click(X, Y, "L")
                Sleep sleepTime
            }
        }
        ;点击进入战斗
        EnterToBattle
        ; 确认结算
        BattleSettlement
        Sleep sleepTime
    }
    ;如果左上角有特殊竞技场就点返回
    Text := "|<特殊竞技场>*113$93.tyDzz7zszyTnzDzz70Q18z007lwTtU30k1U07s00SC0DA0860C007ksDU01tw30SDkE0y73s00A3Us0060060030wTUED0U0k17k00SDXw00160C0MzU0DlU1kk0szXX00Q01y40DC0700A003U0D001ts0U00UA1w7Vs4ATC8020DVUDU0D1l3s180lXwQ1w01yD0y0F774TX07sFrlsDU4MstXsV0T6CSC0wDX77kQA8b0k3101bs0sy3Xr7kD0MMADyAD7kzzszDw7bjtzvXU"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        GoBack
    }
    AddLog("已返回竞技场页面")
    AddLog("==========特殊竞技场任务结束==========")
}
ChampionArena() {
    ;进入冠军竞技场（点竞技场里的特殊竞技场）
}
; 对前n位nikke进行好感度咨询(可以通过收藏把想要咨询的nikke排到前面)
NotAllCollection() {
    stdCkptX := [2447]
    stdCkptY := [1464]
    desiredColor := ["0x444547"]
    return UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio)
}
LoveTalking(times) {
    ;进入妮姬列表
    stdTargetX := 1497
    stdTargetY := 2004
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [64]
    stdCkptY := [470]
    desiredColor := ["0xFAA72C"]
    while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "进入妮姬列表失败！"
            Pause
        }
    }
    stdCkptX := [1466, 1814]
    stdCkptY := [428, 433]
    desiredColor := ["0x3B3C3E", "0x3B3C3E"]
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入妮姬列表失败！"
            Pause
        }
    }
    ;进入咨询页面
    stdTargetX := 3308
    stdTargetY := 257
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [1650]
    stdCkptY := [521]
    desiredColor := ["0x14B0F5"]
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        ;如果没次数了，直接退出
        if UserCheckColor(stdCkptX, stdCkptY, ["0xE0E0E2"], scrRatio) {
            stdTargetX := 333
            stdTargetY := 2041
            UserClick(stdTargetX, stdTargetY, scrRatio)
            Sleep sleepTime
            stdCkptX := [64]
            stdCkptY := [470]
            desiredColor := ["0xFAA72C"]
            while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
                UserClick(stdTargetX, stdTargetY, scrRatio)
                Sleep sleepTime
                if A_Index > waitTolerance {
                    MsgBox "退回大厅失败！"
                    Pause
                }
            }
            return
        }
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入咨询页面失败！"
            Pause
        }
    }
    ;点进第一个妮姬
    stdTargetX := 736
    stdTargetY := 749
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [1504]
    stdCkptY := [1747]
    desiredColor := ["0xF99F22"]
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入妮姬咨询页面失败！"
            Pause
        }
    }
    loop times {
        stdCkptX := [1994]
        stdCkptY := [1634]
        desiredColor := ["0xFA6E34"]
        ;如果能够快速咨询
        if UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) && !(g_settings["LongTalk"] && NotAllCollection()) {
            ;点击快速咨询
            stdTargetX := 2175
            stdTargetY := 1634
            UserClick(stdTargetX, stdTargetY, scrRatio)
            Sleep sleepTime
            stdCkptX := [1994]
            stdCkptY := [1634]
            desiredColor := ["0xFA6E34"]
            while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
                UserClick(stdTargetX, stdTargetY, scrRatio)
                Sleep sleepTime
                if A_Index > waitTolerance {
                    MsgBox "进入妮姬咨询页面失败！"
                    Pause
                }
            }
            ;点击确定
            stdTargetX := 2168
            stdTargetY := 1346
            UserClick(stdTargetX, stdTargetY, scrRatio)
            Sleep sleepTime
            stdCkptX := [1504]
            stdCkptY := [1747]
            desiredColor := ["0xF99F22"]
            while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
                UserClick(stdTargetX, stdTargetY, scrRatio)
                Sleep sleepTime
                if A_Index > waitTolerance {
                    MsgBox "快速咨询失败！"
                    Pause
                }
            }
        }
        else {
            ;如果不能快速咨询
            stdCkptX := [1982]
            stdCkptY := [1819]
            desiredColor := ["0x4A4A4C"]
            if !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
                stdTargetX := 2168
                stdTargetY := 1777
                UserClick(stdTargetX, stdTargetY, scrRatio)
                Sleep sleepTime
                stdCkptX := [1504]
                stdCkptY := [1747]
                desiredColor := ["0xF99F22"]
                while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
                    UserClick(stdTargetX, stdTargetY, scrRatio)
                    Sleep sleepTime
                    if A_Index > waitTolerance {
                        MsgBox "咨询失败！"
                        Pause
                    }
                }
                ;点击确认
                stdTargetX := 2192
                stdTargetY := 1349
                UserClick(stdTargetX, stdTargetY, scrRatio)
                Sleep sleepTime
                stdCkptX := [2109]
                stdCkptY := [1342]
                desiredColor := ["0x00A0EB"]
                while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
                    UserClick(stdTargetX, stdTargetY, scrRatio)
                    Sleep sleepTime
                    if A_Index > waitTolerance {
                        MsgBox "咨询失败！"
                        Pause
                    }
                }
                stdCkptX := [1504]
                stdCkptY := [1747]
                desiredColor := ["0xF99F22"]
                stdTargetX := 1903
                stdTargetY := 1483
                while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
                    if Mod(A_Index, 2) == 0
                        UserClick(stdTargetX, stdTargetY, scrRatio)
                    else
                        UserClick(stdTargetX, 1625, scrRatio)
                    Sleep sleepTime // 2
                    if A_Index > waitTolerance * 2 {
                        MsgBox "咨询失败！"
                        Pause
                    }
                }
            }
        }
        if A_Index >= times
            break
        ;翻页
        stdTargetX := 3778
        stdTargetY := 940
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        stdCkptX := [1982]
        stdCkptY := [1819]
        desiredColor := ["0x4A4A4C"]
        numOfTalked := A_Index
        while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
            UserClick(stdTargetX, stdTargetY, scrRatio)
            Sleep sleepTime
            if A_Index + numOfTalked >= times + 2
                break 2
            if A_Index > waitTolerance {
                MsgBox "咨询失败！"
                Pause
            }
        }
    }
    ;退回大厅
    stdTargetX := 333
    stdTargetY := 2041
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [64]
    stdCkptY := [470]
    desiredColor := ["0xFAA72C"]
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退回大厅失败！"
            Pause
        }
    }
}
; 爬塔一次(做每日任务)
FailTower() {
    stdTargetX := 2689
    stdTargetY := 1463
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [64]
    stdCkptY := [470]
    desiredColor := ["0xFAA72C"]
    while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            Pause
        }
    }
    stdCkptX := [1641]
    stdCkptY := [324]
    desiredColor := ["0x01D4F6"]
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            Pause
        }
    }
    ;进入无限之塔
    stdTargetX := 2278
    stdTargetY := 776
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [2405]
    stdCkptY := [1014]
    desiredColor := ["0xF8FBFE"]
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入无限之塔失败！"
            Pause
        }
    }
    stdTargetX := 1953
    stdTargetY := 934
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [2129, 2305]
    stdCkptY := [1935, 1935]
    desiredColor := ["0x2E77C2", "0x2E77C2"]
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "选择作战失败！"
            Pause
        }
    }
    stdTargetX := 2242
    stdTargetY := 2001
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [2129, 2305]
    stdCkptY := [1935, 1935]
    desiredColor := ["0x2E77C2", "0x2E77C2"]
    while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入作战失败！"
            Pause
        }
    }
    ;按esc
    stdCkptX := [2065]
    stdCkptY := [1954]
    desiredColor := ["0x238CFD"]
    stdTargetX := 3780
    stdTargetY := 75
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "按esc失败！"
            Pause
        }
    }
    ;按放弃战斗
    stdCkptX := [2065]
    stdCkptY := [1954]
    desiredColor := ["0x238CFD"]
    stdTargetX := 1678
    stdTargetY := 1986
    while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "放弃战斗失败！"
            Pause
        }
    }
    ;退回大厅
    stdTargetX := 301
    stdTargetY := 2030
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [64]
    stdCkptY := [470]
    desiredColor := ["0xFAA72C"]
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退回大厅失败！"
            Pause
        }
    }
}
; 通用塔
UniversalTower() {
    EnterToArk
    AddLog("==========通用塔任务开始==========")
    Text := "|<无限之塔>*125$79.zzzzzzzzDznlns00Q00Dz3zsU0Q00C007zkzwE0600703Xs01y807z7zYE1s00S32DzXzk80w00C1k7zVzsA0Tzw70s7U00A26Dzy7kk0k006N07zy7wEM4007A03zy7y007w1za05zy7z40Ty0zl0UTw7zXzzy0Ts0MDw7zkU1y4CQ2ADsDzk00y376T67kDzk8QS3U3DU1k3zMQCA3k3bUME007y077s1nsCQw07z03zzztzzzzkDzntk"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击无限之塔")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    Text := "|<塔内的无限之塔>*194$63.000000000E3zwTzs1U37QTznzz0C0PzsD0PMszz3Dy0k3Pz7zwyzU60TTs0D7nszzvvb01kMzbzzPTs0Q3zT1s3Dy070PzkD0Nvs1k3003s3zD0Q0Tzkv3TNkD07zyCQv3i7k0slrXzMTxzzk7ysDn3nATw0zo"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击塔内的无限之塔")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    Text := "|<STAGE>*83$39.0kCD0s041ls705kQ74scz7Usz77sw77ssz7Usz70sw76M877YsX10ssX4MD774MX7sssX4Mz770MX7sss34Ms7748300sll0M4TbSSL1U"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("已进入塔的内部")
        stdTargetX := 1926
        stdTargetY := 908
        Sleep sleepTime
        AddLog("点击最新关卡")
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        EnterToBattle
        BattleSettlement
        sleep 3000
        RefuseSale
    }
    AddLog("==========通用塔任务结束==========")
    BackToHall
}
; 企业塔
CompanyTower() {
    EnterToArk
    AddLog("==========企业塔任务开始==========")
    Text := "|<无限之塔>*125$79.zzzzzzzzDznlns00Q00Dz3zsU0Q00C007zkzwE0600703Xs01y807z7zYE1s00S32DzXzk80w00C1k7zVzsA0Tzw70s7U00A26Dzy7kk0k006N07zy7wEM4007A03zy7y007w1za05zy7z40Ty0zl0UTw7zXzzy0Ts0MDw7zkU1y4CQ2ADsDzk00y376T67kDzk8QS3U3DU1k3zMQCA3k3bUME007y077s1nsCQw07z03zzztzzzzkDzntk"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
        AddLog("点击无限之塔")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    ; 只要有一座塔是0/3就当作任务执行过了
    Text := "|<塔的外部0/3>*121$23.szi7UyM28wn4tty9lbw3XDV76T3CBzWQnzYtbj83C0MCS1ztzzznzzzbzw"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        AddLog("今日企业塔已打过，返回")
        AddLog("==========企业塔任务结束==========")
        BackToHall
        return
    }
    Text每日通关 := "|<每日通关>*124$58.vzzzzzzzzz7zs0Qs1sww0701lkDnXXzwTbX1w0407nyTs1k000DDtz07wTmAw0740Tty01k0QE1U00037tt0600W8wzbY0Tky8XnySH1y1s0701sA7lXs0w07008D3y7lyQk1Vy8"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text每日通关, , , , , , 5, currentScale, currentScale)) { ;5代表从左往右
        count := ok.Length
        AddLog("今天有" count "座塔要打")
        FindText().Click(X, Y, "L")
        Sleep sleepTime
        loop count {
            Text := "|<STAGE>*83$39.0kCD0s041ls705kQ74scz7Usz77sw77ssz7Usz70sw76M877YsX10ssX4MD774MX7sssX4Mz770MX7sss34Ms7748300sll0M4TbSSL1U"
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                AddLog("已进入塔的内部")
                Text := "|<泰特拉>*94$56.zXzwT7wT7w00z70T7ty0071U3lyTz3zkM0s00A00s3lw00300C001Uzzy7zUE0QQQE0097wD77C007lz7kFnsn7w00E6MsQsQ0043aA3A21n7VtXY0BkMlwS9zU3z74T7aT00Tlv7lz7k33wT1sE0Dkxz7kS403yTzvyTrzzU"
                if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                    AddLog("这座塔是泰特拉之塔")
                }
                Text := "|<极乐>**50$38.DU001zXTzlzzMr0AM02xk360DiDRljzn1rMPP0sxrgqk7DMDDjxXq3k03MNxg00S6DPz7z7VaTvzVvPaStdQknbjTrSRnPnxb3tyyH9WCwBokvnz3DDzzkzk1s007k2"
                if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, 0, , , , , , currentScale, currentScale)) { ;0代表使用上一次截屏
                    AddLog("这座塔是极乐净土之塔")
                }
                Text := "|<STAGE>*83$39.0kCD0s041ls705kQ74scz7Usz77sw77ssz7Usz70sw76M877YsX10ssX4MD774MX7sssX4Mz770MX7sss34Ms7748300sll0M4TbSSL1U"
                while (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                    stdTargetX := 1850
                    stdTargetY := 984
                    AddLog("点击最新关卡")
                    UserClick(stdTargetX, stdTargetY, scrRatio)
                    Sleep sleepTime
                    EnterToBattle
                }
                BattleSettlement
                sleep 5000
                RefuseSale
            }
            stdTargetX := 2239
            stdTargetY := 1868
            AddLog("点击下一个塔")
            UserClick(stdTargetX, stdTargetY, scrRatio)
        }
        AddLog("所有塔都打过了")
    }
    AddLog("==========企业塔任务结束==========")
    BackToHall
}
;11: 进入异拦
Interception() {
    global g_numeric_settings ;
    stdTargetX := 2689
    stdTargetY := 1463
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [64]
    stdCkptY := [470]
    desiredColor := ["0xFAA72C"]
    while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            Pause
        }
    }
    stdCkptX := [1641]
    stdCkptY := [324]
    desiredColor := ["0x01D4F6"]
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            Pause
        }
    }
    ;进入拦截战
    stdTargetX := 1781
    stdTargetY := 1719
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [1641]
    stdCkptY := [324]
    desiredColor := ["0x01D4F6"]
    while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入拦截战失败！"
            Pause
        }
    }
    stdTargetX := 559
    stdTargetY := 1571
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep 1000
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep 1000
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep 1000
    ;选择BOSS
    switch g_numeric_settings["InterceptionBoss"] {
        case 1:
            stdTargetX := 1556
            stdTargetY := 886
            stdCkptX := [1907]
            stdCkptY := [898]
            desiredColor := ["0xFA910E"]
        case 2:
            stdTargetX := 2279
            stdTargetY := 1296
            stdCkptX := [1923]
            stdCkptY := [908]
            desiredColor := ["0xFB01F1"]
        case 3:
            stdCkptX := [1917]
            stdCkptY := [910]
            desiredColor := ["0x037EF9"]
        case 4:
            stdTargetX := 2281
            stdTargetY := 899
            stdCkptX := [1916]
            stdCkptY := [907]
            desiredColor := ["0x00F556"]
        case 5:
            stdTargetX := 1551
            stdTargetY := 1299
            stdCkptX := [1919]
            stdCkptY := [890]
            desiredColor := ["0xFD000F"]
        default:
            MsgBox "BOSS选择错误！"
            Pause
    }
    stdTargetX := 1556
    stdTargetY := 886
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep 2000
        if A_Index > waitTolerance {
            MsgBox "选择BOSS失败！"
            Pause
        }
    }
    ;点击挑战按钮
    if UserCheckColor([1735], [1730], ["0x28282A"], scrRatio) {
        stdTargetX := 301
        stdTargetY := 2030
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        stdCkptX := [64]
        stdCkptY := [470]
        desiredColor := ["0xFAA72C"]
        while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
            UserClick(stdTargetX, stdTargetY, scrRatio)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "退回大厅失败！"
                Pause
            }
        }
        return
    }
    stdTargetX := 1924
    stdTargetY := 1779
    stdCkptX := [1390]
    stdCkptY := [1799]
    desiredColor := ["0x01AEF3"]
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "点击挑战失败！"
            Pause
        }
    }
    ;选择编队
    switch g_numeric_settings["InterceptionBoss"] {
        case 1:
            stdTargetX := 1882
            stdTargetY := 1460
            stdCkptX := [1843]
            stdCkptY := [1428]
        case 2:
            stdTargetX := 2020
            stdTargetY := 1460
            stdCkptX := [1981]
            stdCkptY := [1428]
        case 3:
            stdTargetX := 2151
            stdTargetY := 1460
            stdCkptX := [2113]
            stdCkptY := [1428]
        case 4:
            stdTargetX := 2282
            stdTargetY := 1460
            stdCkptX := [2248]
            stdCkptY := [1428]
        case 5:
            stdTargetX := 2421
            stdTargetY := 1460
            stdCkptX := [2380]
            stdCkptY := [1428]
        default:
            MsgBox "BOSS选择错误！"
            Pause
    }
    desiredColor := ["0x02ADF5"]
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep 1500
        if A_Index > waitTolerance {
            MsgBox "选择编队失败！"
            Pause
        }
    }
    ;如果不能快速战斗，就进入战斗
    stdCkptX := [1964]
    stdCkptY := [1800]
    desiredColor := ["0xF96B2F"]
    if !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        stdTargetX := 2219
        stdTargetY := 1992
        stdCkptX := [1962]
        stdCkptY := [1932]
        desiredColor := ["0xD52013"]
        while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
            UserClick(stdTargetX, stdTargetY, scrRatio)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "进入战斗失败！"
                Pause
            }
        }
        ;退出结算页面
        stdTargetX := 904
        stdTargetY := 1805
        stdCkptX := [3731, 3713, 3638]
        stdCkptY := [2040, 2034, 2091]
        desiredColor := ["0xE6E6E6", "0xE6E6E6", "0x000000"]
        while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
            CheckAutoBattle()
            Sleep sleepTime
            if A_Index > waitTolerance * 20 {
                MsgBox "自动战斗失败！"
                Pause
            }
        }
        while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
            UserClick(stdTargetX, stdTargetY, scrRatio)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "退出结算页面失败！"
                Pause
            }
        }
    }
    ;检查是否退出
    stdCkptX := [1390]
    stdCkptY := [1799]
    desiredColor := ["0x01AEF3"]
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退出结算页面失败！"
            Pause
        }
    }
    ;快速战斗
    stdTargetX := 2229
    stdTargetY := 1842
    stdCkptX := [1964]
    stdCkptY := [1800]
    desiredColor := ["0xF96B2F"]
    while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
        while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
            UserClick(stdTargetX, stdTargetY, scrRatio)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "快速战斗失败！"
                Pause
            }
        }
        ;退出结算页面
        stdTargetX := 904
        stdTargetY := 1805
        stdCkptX := [2232, 2391, 2464]
        stdCkptY := [2100, 2099, 2051]
        desiredColor := ["0x000000", "0x000000", "0x000000"]
        while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "快速战斗结算失败！"
                Pause
            }
        }
        while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
            UserClick(stdTargetX, stdTargetY, scrRatio)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "退出结算页面失败！"
                Pause
            }
        }
        ;检查是否退出
        stdCkptX := [1390]
        stdCkptY := [1799]
        desiredColor := ["0x01AEF3"]
        while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "退出结算页面失败！"
                Pause
            }
        }
        Sleep 1000
        stdTargetX := 2229
        stdTargetY := 1842
        stdCkptX := [1964]
        stdCkptY := [1800]
        desiredColor := ["0xF96B2F"]
    }
    ;退回大厅
    BackToHall
}
;排名奖励
RankingReward() {
    EnterToArk()
    Text := "|<带红点的排名奖杯>**50$62.006M0NU0Tw003A03A0T7k01a00NUC0S00m003A6DlU0F000NVbCA08U003AnUn04E000Nhk6E280003/M0Y1400000Y090W00000902EF000003M0Y8000000m0N47zzzzzgkAm1U0000Nb6B0M00006MT6UC00001X03UDU0000TS7kb000000vzkHU0000031U8lk0000QsA0Mw0000D61U6P00003NVA1ak0000qMNUNA0000Aa3A6H000039UNVaE0000qM3ANY0000Ba0N2B00003tU30nk0000wk0MAS0000CA031VU0006600EA000013U003U00001k000D00001k0001w0003s00003U001k000U"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime
        loop 2 {
            Text := "|<红点>**50$18.0y031kA0MMyAFrYX1Wa0mY0NA0NA0NY0NY0Ea0mnVaEz480860s1z0U"
            while (ok := FindText(&X := "wait", &Y := 1, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3, 0.3, Text, , , , , , , currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                Sleep sleepTime
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3, 0.3, Text, , , , , , , currentScale, currentScale)) {
                    FindText().Click(X, Y, "L")
                    Sleep sleepTime
                    Confirm
                    GoBack
                }
            }
            stdTargetX := 1858
            stdTargetY := 615
            UserMove(stdTargetX, stdTargetY, scrRatio)
            Send "{WheelDown 30}"
        }
    }
    BackToHall
}
; 邮箱收取
Mail() {
    Sleep sleepTime
    stdTargetX := 3667
    stdTargetY := 81
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [64]
    stdCkptY := [470]
    desiredColor := ["0xFAA72C"]
    while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio) ;检测大厅点邮箱
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入邮箱失败！"
            Pause
        }
    }
    stdCkptX := [2085]
    stdCkptY := [1809]
    desiredColor := ["0xCAC7C4"] ;检测灰色的领取按钮
    stdTargetX := 2085
    stdTargetY := 1809
    ;Sleep sleepTime ;加载容错
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio) ;不是灰色就一直点全部领取
        Sleep sleepTime
    }
    stdCkptX := [64]
    stdCkptY := [470]
    desiredColor := ["0xFAA72C"]
    stdTargetX := 2394
    stdTargetY := 291
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio) ;确认领取+返回直到回到大厅
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退出邮箱失败！"
            Pause
        }
    }
}
; 任务收取
Mission() {
    stdTargetX := 3341
    stdTargetY := 206
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [64]
    stdCkptY := [470]
    desiredColor := ["0xFAA72C"]
    while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio) ;检测大厅点任务
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入任务失败！"
            Pause
        }
    }
    stdTargetX := 2286
    stdTargetY := 1935
    x0 := 1512 ;用于遍历任务
    y0 := 395
    while UserCheckColor([1365, 2087], [1872, 1997], ["0xF5F5F5", "0xF5F5F5"], scrRatio) { ;检测是否在任务界面
        Sleep sleepTime
        UserClick(x0, y0, scrRatio) ;点任务标题
        Sleep sleepTime
        if !UserCheckColor([1365, 2087], [1872, 1997], ["0xF5F5F5", "0xF5F5F5"], scrRatio) { ;退出
            break
        }
        stdCkptX := [2276]
        stdCkptY := [1899]
        desiredColor := ["0x7B7C7B"]
        while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) { ;如果不是灰色就点
            Sleep sleepTime
            UserClick(stdTargetX, stdTargetY, scrRatio) ;点领取
        }
        x0 := x0 + 280 ;向右切换标题
    }
}
; 通行证收取 兼容双通行证 兼容特殊活动
Pass() {
    OnePass()
    stdCkptX := [3395]
    stdCkptY := [368]
    stdCkptY1 := [468] ;活动可能偏移
    desiredColor := ["0xFBFFFF"] ;白色的轮换按钮
    stdTargetX := 3395
    stdTargetY := 368
    stdTargetY1 := 468
    if UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {  ;如果轮换按钮存在
        global PassRound
        PassRound := 0
        while (PassRound < 2) {
            userClick(stdTargetX, stdTargetY, scrRatio) ;转一下
            Sleep sleepTime
            PassRound := PassRound + 1
            stdCkptX := [3437]
            stdCkptY := [338]
            desiredColor := ["0xFE1809"] ;红点
            if UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) { ;如果转出红点
                Sleep sleepTime
                userClick(stdTargetX, stdTargetY, scrRatio) ;再转一下
                Sleep sleepTime
                OnePass()
                break
            }
        }
    }
    if UserCheckColor(stdCkptX, stdCkptY1, desiredColor, scrRatio) {  ;检测是否偏移
        global PassRound
        PassRound := 0
        while (PassRound < 2) {
            userClick(stdTargetX, stdTargetY1, scrRatio) ;转一下
            Sleep sleepTime
            PassRound := PassRound + 1
            stdCkptX := [3437]
            stdCkptY := [438]
            desiredColor := ["0xFE1809"] ;红点
            if UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) { ;如果转出红点
                Sleep sleepTime
                userClick(stdTargetX, stdTargetY1, scrRatio) ;再转一下
                Sleep sleepTime
                OnePass()
                break
            }
        }
    }
}
OnePass() { ;执行一次通行证
    stdTargetX := 3633
    stdTargetY := 405
    UserClick(stdTargetX, stdTargetY, scrRatio)
    Sleep sleepTime
    stdCkptX := [64]
    stdCkptY := [470]
    desiredColor := ["0xFAA72C"]
    while UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio) ;检测大厅点通行证
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入通行证失败！"
            Pause
        }
    }
    stdCkptX := [1733]
    stdCkptY := [699]
    desiredColor := ["0xF1F5F6"]
    stdTargetX := 2130
    stdTargetY := 699
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) { ;左不是白则点右
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
    }
    stdCkptX := [1824]
    stdCkptY := [1992]
    desiredColor := ["0x7C7C7C"] ;检测灰色的全部领取
    stdTargetX := 1824
    stdTargetY := 1992
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio) ;不是灰色就一直点领取
        Sleep sleepTime
    }
    stdCkptX := [2130]
    stdCkptY := [699]
    desiredColor := ["0xF1F5F6"]
    stdTargetX := 1733
    stdTargetY := 699
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) { ;右不是白则点左
        UserClick(stdTargetX, stdTargetY, scrRatio)
        Sleep sleepTime
    }
    stdCkptX := [1824]
    stdCkptY := [1992]
    desiredColor := ["0x7C7C7C"] ;检测灰色的全部领取
    stdTargetX := 1824
    stdTargetY := 1992
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio) ;不是灰色就一直点领取
        Sleep sleepTime
    }
    stdCkptX := [64]
    stdCkptY := [470]
    desiredColor := ["0xFAA72C"]
    stdTargetX := 2418
    stdTargetY := 185
    while !UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
        UserClick(stdTargetX, stdTargetY, scrRatio) ;确认领取+返回直到回到大厅
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退出通行证失败！"
            Pause
        }
    }
    stdCkptX := [3395]
    stdCkptY := [368]
    desiredColor := ["0xFBFFFF"] ;检测是否多通行证
    stdTargetX := 3395
    stdTargetY := 368
    if UserCheckColor(stdCkptX, stdCkptY, desiredColor, scrRatio) {
    }
}
; 免费招募
FreeRecruit() {
    BackToHall()
    Text每天免费 := "|<每天免费>*156$64.wzzzzzbzz9zU0s03w1z00S01U0DU7zmNnzzyTwQzk0601ztzU07Abs07zby00Q00t6S00QttwNna9s01nba3aE01z3z00Q03167wDw03s0DgNzUTz9zbAw03wMzsbSNnk07Xky6Qt0TztsTVUs20kTyDbzbDUMTsU"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text每天免费, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        AddLog("进入招募页面")
        while (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text每天免费, , , , , , , currentScale, currentScale)) {
            Text每日免费 := "|<每日免费>*122$73.szzs07z3zw00s01w01z07y00A00y00z03zU04TzzDwT3XzU0001zbyD007k0200Dnz7U01s00U07szXkkkw00MlXw01wQwS3W0E0y00y00C1l800D7wT007U04007byDk07s03a6Tnz7z0zwtll07tzXz2TyQss01w01z3DDA0w00y00y3X7UEDz1z00S3k30S3zVzbzDjw3Vzt"
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3, 0.3, Text每日免费, , 0, , , , , currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                Recruit()
            }
            else {
                ; 点击翻页
                Sleep sleepTime
                stdTargetX := 3774
                stdTargetY := 1147
                UserClick(stdTargetX, stdTargetY, scrRatio)
                Sleep sleepTime
            }
        }
    }
    BackToHall()
}
; 德雷克·反派之路
RoadToVillain() {
    BackToHall()
    Sleep sleepTime
    Text := "|<ROAD TO>*149$61.VzXyDXzUDXUD0T7UDk70HX7DfnbyTb9tbnYttzDbksntmQwzbns0twvCSTntw0wyMXDDtwy6STA1bbwyT3bbCQnbyTb9lk6T83zDk6wyDDaDzryD"
    while (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , 0, , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
        Sleep sleepTime
    }
    loop 3 {
        if A_Index = 1 {
            Text := "|<任务>*181$41.1U103U03Uz0D00Dzz0zzkTzs3zzVvz0Tzy7US0zXsD0w0rzUy1s0Tz3w3kDzzvzzyTsznzzwQQ33zzs0w070w1zzwC1s3zzsQ3k0T3ks7U0w71nzw7kC3bztzDw7DzlsTkC0030T2"
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                Sleep sleepTime
            }
        }
        if A_Index = 2 {
            Text := "|<周任务>*183$62.7zz0Q1s0s03zzs7zz0TzUzzy3zzkDzwDzzUzzkDzz3XlsSTk7yTUzzyDUw1zzkDzzbsD0Bzs3zxty3k7zzszzyTzztzzzDzzXzzyTwzXzzsTzzX7U0vzS7zzkzzwSzrVsD0Dzz7jxsS3k3zzlvrS7Uw07kwQzrUsDU3sDDDzsCzzXw7nnny3jztyTsMET0vzyS3w003UC0000Q2"
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                Sleep sleepTime
            }
        }
        if A_Index = 3 {
            Text := "|<奖励>*181$40.3VU0031CD0DzQCtzszxkzzzXzr1jwSC0Q1vvkzzzTXy3zzzyDkDzzyzy0z1rnjU3zbQCs0TyRk3U1rtrzzzbRbTzzyRytzzztrvb0zU7zyQTzUTjlzwTtzzyzUzjzttk0Q/Mb8"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                Sleep sleepTime
            }
        }
        Text := "|<全部领取>*165$83.zlzzXwDwT0Q0zzzVzz3k7ss0E0Tzy1zk0U7Uk0k00Dk1zU00C0wDV00T1Uz028w0kz080sDUT6AFkE0C0MlUTUCAM7000Q0lW000M0ED8s0s1X6001U00TEk1kXUDU0T004S0U3U70zwDzzy8w0070C1zsTz0AMz20C0S3w03w08ly40Q8wDs07s0F3sM0s0sTz3zkkUD1s1k0UTy7zXV0S3s7020Q00D021y7U7080E00C04TyC6Dw0kU00Q08zyQSTsnnzzzxyzzzzzzvzy"
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Text := "|<活动结束>*128$65.7sDznzDbzty40w3bwM1k03M7s7Dtk1U07yDzs1a07zDzU3zk28tz00a020NY30S0060A0n8A0QslzXyT6QQ3tnXz7wqAkTzk06E1lYl007U0MXXU9XD7Ds3nDb03DySTU36TCCCQ0Qw9UQ0Tw0k01VnVs0zxVbk3bbY"
            while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                Confirm
            }
            Sleep sleepTime
        }
    }
    BackToHall()
}
Cooperate() {
    ; 把鼠标移动到活动栏
    stdTargetX := 150
    stdTargetY := 257
    UserMove(stdTargetX, stdTargetY, scrRatio)
    Text := "|<COOP的CP>*113$81.zk00007zzzzzzzw00000Tzzzzzzz000003zzzzzzzk00000Tzzzzzzw000007zzzzzzz000000zzzzzzzk00000Tzzzzzzw000007zzzzzzz000001zzzzzzzs03zzzzzzzzzzz01zzzzzzzzzzzs0Tzzzzzzzzzzz07zzzzzzzzzzzs0zzzzzzzzzzzz07zzzzzzzzzzzs0zzzzzzzzzzzz07zzzzzzzzzzzs0zzzzzzzzzzzz07zzzzzzzzzzzs0zzzzzzzzzzzz07zzzzzzzzzzzs0zzzzzzzzzzzz0Dzzzzzzzzzzzs3zzzzzzzzzzzz0zzzzzzzzzzzzsDzzzzzzzzzzzz3k0001zzzzzzzsw00007zzzzzzzD00000Tzzzzzzvk00001zzzzzzzw000007zzzzzzz000000Tzzzzzzk000007zzzzzzw000000TzzzzzzU000007zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzW0001yDzzzzzzk0000D0zzzzzzy00003k7zzzzzzk0000w0zzzzzzz0000D07zzzzzzs0003k0zzzzzzz0000w07zzzzzzs000D00zzzzzzz0003k07zzzzzzs1zzw01zzzzzzz0Dzz00Tzzzzzzs1zzk07zzzzzzz0Dzw01zzzzzzzs1zz00Tzzzzzzz0DU007zzzzzzzk1w001zzzzzzzy0DU00Tzzzzzzzk1w007zzzzzzzy0DU01zzzzzzzzk1w00Tzzzzzzzy0DU07zzzzzzzzk1w01zzzzzzzzy0Dzzzzzzzzzzzk1zzzzzzzzzzzz0Dzzzzzzzzzzzk1zzzzzzzzzzzy0Dzzzzzzzzzzzs1zzzzzzzzzzzy0Dzzzzzzzzzzzk1zzzzzzzzzzzz0Dzzzzzzzzzzzs1zzzzzzzzzzzz0Dzzzzzzzzzzzk1zzzzzzzzzzzz0Dzzzzw"
    loop 20 {
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, Text, , , , , , , currentScale, currentScale)) {
            Sleep sleepTime
            FindText().Click(X, Y, "L")
            break
        }
        ;没找到就滚轮滚
        else {
            Send "{WheelDown 5}"
            Sleep sleepTime
        }
        ;找不到就退出
        if (A_Index > 20) {
            return
        }
    }
    while true {
        ;一直找开始匹配
        Text开始匹配 := "|<开始匹配>**50$110.00000y0y00000000003yTkADUDk1zzzyTzzzvzzzz286A0zzzzo03zyk000EW1X08000B00k0g0004MUEy20003M0A0/w7kTCTASkVksTrqTzWTXyDr3u568yDDsxbzsU8UW103XFWBan0M0M28288UE0laAXNgk6020W0W2876ATV8qPA1U0jsU8UW0lW00OBan0NGDy/yDszAtU02XFgk6En02zVwDuCM7scoPBNUAk0c0002X7zzuD4nTM3AS+0000clzzgXlAoq43DWz3wDuATzz8snDBVUnDjszXwUD00mAAlXMyAls4M8UC3k0AV6A0qTXA036281kwzX8HVUNW0n1UlUW0A7AAmDkTyM0AlwMk8U31n3AXs1y6TXANAA281UAkn8zzzxbsn6K60W0kb7sm33zzMyAT71U8UMTk0AU000K033VUk286Bw0380005U0k0wM0W1b37snzzzzNyS0Rw0DUDUzzw00007kzzyC03s007Uy00000s0088"
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text开始匹配, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Sleep sleepTime
            Text := "|<通知>**50$48.0DzyTU00TA07MUTytw03Mzzzkw07MzU3sT4Ck0U3QS0Sk0U3Cz0TU3XX7s03WDXX0803nAXXzslny7XXUM03U0XXUM03U0XXUMlnU0XXwM03yDXXAM0366XX4MEX63XX4MlXA1XXAMl3A1XXsMt7sM03k3zzksU3V001UxU3nk01ljXXqy07v0zzU"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
                BackToHall
                return
            }
        }
        else {
            BackToHall
            return
        }
        while true {
            ;防止有人取消，反复检测
            Text接受 := "|<接受>**50$48.7kT001zw4kNUTzk64rtzM0064w01M03yww01SSTAkDDDCSP4kDDACDCCkDDDSCADww01k0014s01k0014w01nzztQDnznzztsDXzv00Pk001z00Tks01X7sMwzD7VXsk4qDC1llk4o6A0s3U4r0Q1s3sQzkDTU0TMy03E1k1Es7XM7w3U"
            if (ok := FindText(&X := "wait", &Y := 30, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text接受, , , , , , , currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                Sleep sleepTime
            }
            Sleep sleepTime
            Text准备 := "|<准备>**50$54.y6AM067zUX4Q80A01kXAS80M00ElgSDlk00kks00H0TVUMk00G0D3UMkwDmA0709UyDnz0D0D0yDny07z3000z00032000M0D033800w1zs37syDo3zyCAsyDbU00QAMwDlU00E8M00FXkwMMs00lXkwMEsyDlU00Mkca81U00MlcyDtXkwMV800NXkwMX8009U00Mn800NU00MU"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text准备, , , , , , , currentScale, currentScale)) {
                FindText().Click(X, Y, "L")
                Sleep sleepTime
                break
            }
            if A_Index > waitTolerance {
                MsgBox "进入作战失败！"
                Pause
            }
        }
        BattleSettlement
        Sleep 5000
    }
}
SoloRaid() {
    BackToHall
    Text := "|<单人突击的图标>*101$54.zU3w0D303z01s0D301z00s0C301z00k06200y00k06600y3kkw467Uy3UUw447Vy7UUwAA71w7VUs8AD1w710088D3s0100MMC3s0300MMS3s0700EES7s023kkkS7k063Ukkw7kQ67UUUw7kw47VVUwDUwA71VVsDUsAD11VsDVs8D3100T1sMC3300z1kMS2301z3kES6203z7ksy6607zzUzw7zzzzzVzwDzzzzzbzwzzzzzzjztzzzzzU"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        FindText().Click(X, Y, "L")
    }
    Text := "|<左上角的单人突击>*112$73.syDzVzzkzzwTwT7zkzs00TyDy73zsTw00700400TwDy003U0200Dy7z4Qlk01667z3zUA3zszU03zVzsDUzsDk01zUTwQEs008kkzkDzy1y00400Ts3zy0T11200DsFz001llny7zsMTU00sss001wC7zUTwQQ000wD1zU7yCA000MDkT0Uz007wTwDw61s3U03yDyDzb1z3k01"
    while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
        Confirm
    }
    loop 3 {
        Text := "|<挑战>*180$55.szbDzzzkzwTV3zwTsNyDkVzy7w8z7sEzz3y4DXY8FzVz320048Tk1VX0020Ts0kzU010Dw0M0E20UDy7k0C3UE7z3s07Xk87zVw03kS4Dzky0rs723y01sEk3V0T00w8E10U7U0S0M30E1k0D0A2080sS7UDVU48QDXk7sk66S7lw7wR33T3sy2yD1VbVsS3D7Uklk0C03XUsMs040210w0Q00010kS0C0030kQzUD3snkszzwTzzzww"
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
        else {
            AddLog("已无挑战次数，返回")
            BackToHall
            return
        }
        Text := "|<确认的图标>*184$34.zy03zzzU07zzs00zzz0Tzzzs7zzvz1zzz7sDzzsD1zzz1wDzzsDVzzz1y7zzsDkzzz1z3zzsDwDzz1zlyTsDz7kz1zwT1sDzly31zk7w0Dz0Ts1zw0zkDzl3zVzz6DzDzsMTzzzXkzzzwD3zzzVy7zzw7wDzzUzkDzw7zkDz0zzU007zz001zzz00TzzzkDzy"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2, 0.2, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Sleep sleepTime
        }
        Sleep 3000
        Text := "|<进入战斗>*174$123.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzvtzzrzzzszlzzzz7zzz7yC7zwTzzz7yAzzTkzzzsTlkzzVzzzszlXzky7zzzVyC7zw7zzz7yATy1kzzzy7UUDzkTzzsTllzk77zzzkU00zz1zzz0C6TzUszzzzw007zw7zzs1kzzy77zzzzk00zzkzzz0C0Dzxszzzzzlkzzw3zzsz00yDz7zzzzyC7zzUTzz7k0DUTkzzzk7lkzzw1zzsy0vw1z7zzy0w41zz0Dzy7z6Ds7szzzk4003zs0zy01slzkz7zzzkU00Ty23zk0D6Dz7kzzzy4007zksTy01s3zzy37zzkwC7zw7VzlwD0Tzzk0zzy73kzzVw7yDls7zy007zzksS7zsDkzlyDUzU000zzy67kzy3y3yDlwDk003zzzkky7zUTsDlyD1i00kzzzw7Dkzs7zUyDVkAsTy7zzz01zDy1zy1k0A07zzkzzzk00030TzkC0000zzy7zzy7000M7zz3k00E7zzkzzztw007VzzwSDl71zzz7zzzzy0zzzzzzvzzwTzzszzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            FindText().Click(X, Y, "L")
            Sleep sleepTime
            BattleSettlement()
        }
        Text := "|<左上角的单人突击>*112$73.syDzVzzkzzwTwT7zkzs00TyDy73zsTw00700400TwDy003U0200Dy7z4Qlk01667z3zUA3zszU03zVzsDUzsDk01zUTwQEs008kkzkDzy1y00400Ts3zy0T11200DsFz001llny7zsMTU00sss001wC7zUTwQQ000wD1zU7yCA000MDkT0Uz007wTwDw61s3U03yDyDzb1z3k01"
        while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1, 0.1, Text, , , , , , , currentScale, currentScale)) {
            Confirm
        }
        Sleep sleepTime
    }
}
; 通用函数，用于切换 g_settings Map 中的设置值
ToggleSetting(settingKey, guiCtrl, *) {
    global g_settings
    ; 切换值 (0 变 1, 1 变 0)
    g_settings[settingKey] := 1 - g_settings[settingKey]
    ; 可选: 如果需要，可以在这里添加日志记录
    ; ToolTip("切换 " settingKey " 为 " g_settings[settingKey])
}
ChangeOnInterceptionBoss(GUICtrl, *) {
    global g_numeric_settings
    g_numeric_settings["InterceptionBoss"] := GUICtrl.Value
}
ChangeOnSleepTime(GUICtrl, *) {
    global sleepTime
    switch GUICtrl.Value {
        case 1: sleepTime := 750
        case 2: sleepTime := 1000
        case 3: sleepTime := 1250
        case 4: sleepTime := 1500
        case 5: sleepTime := 1750
        case 6: sleepTime := 2000
        default: sleepTime := 1500
    }
}
ChangeOnColorTolerance(GUICtrl, *) {
    global colorTolerance
    switch GUICtrl.Value {
        case 1: colorTolerance := 15
        case 2: colorTolerance := 35
        default: colorTolerance := 15
    }
}
ClickOnHelp(*) {
    msgbox "
    (
    #############################################
    使用说明
    对大多数老玩家来说Doro设置保持默认就好。
    万一Doro失控，请按Ctrl + 1组合键结束进程。
    万一Doro失控，请按Ctrl + 1组合键结束进程。
    万一Doro失控，请按Ctrl + 1组合键结束进程。
    ############################################# 
    要求：
    - 【设定-画质-全屏幕模式 + 16:9的显示器比例】（推荐）   或    【16:9的窗口模式（窗口尽量拉大，否则像素识别可能出现误差）】
    - 设定-画质-开启光晕效果
    - 设定-画质-开启颜色分级
    - 游戏语言设置为简体中文
    - 以**管理员身份**运行DoroHelper
    - 不要开启windows HDR显示
    ############################################# 
    步骤：
    -打开NIKKE启动器。点击启动。等右下角腾讯ACE反作弊系统扫完，NIKKE主程序中央SHIFT UP logo出现之后，再切出来点击“DORO!”按钮。如果你看到鼠标开始在左下角连点，那就代表启动成功了。然后就可以悠闲地去泡一杯咖啡，或者刷一会儿手机，等待Doro完成工作了。
    -也可以在游戏处在大厅界面时（有看板娘的页面）切出来点击“DORO!”按钮启动程序。
    -游戏需要更新的时候请更新完再使用Doro。
    ############################################# 
    其他:
    
    -检查是否发布了新版本。
    -如果出现死循环，提高点击间隔可以解决80%的问题。
    -如果你的电脑配置较好的话，或许可以尝试降低点击间隔。
    
    )"
}
ClickOnDoro(*) {
    Initialization
    WriteSettings()
    Login() ;登陆到主界面
    if g_settings["Shop"] {
        if g_settings["CashShop"]
            CashShop()
        if g_settings["NormalShop"]
            NormalShop()
        if g_settings["ArenaShop"]
            ArenaShop()
        if g_settings["ScrapShop"]
            ScrapShop()
        BackToHall
    }
    if g_settings["SimulationRoom"] {
        SimulationRoom()
        if g_settings["SimulationOverClock"] ;模拟室超频
            SimulationOverClock()
        BackToHall
    }
    if g_settings["Arena"] {
        Arena()
        if g_settings["RookieArena"] ;新人竞技场
            RookieArena()
        if g_settings["SpecialArena"] ;特殊竞技场
            SpecialArena()
        if g_settings["ChampionArena"] ;冠军竞技场
            ChampionArena()
        BackToHall
    }
    if g_settings["LoveTalking"]
        LoveTalking(g_numeric_settings["NumOfLoveTalking"])
    if g_settings["Tower"] {
        if g_settings["CompanyTower"]
            CompanyTower()
        if g_settings["UniversalTower"]
            UniversalTower()
        BackToHall
    }
    if g_settings["Interception"]
        Interception()
    if g_settings["Award"] {
        if g_settings["OutpostDefence"] ; 使用键名检查 Map
            OutpostDefence()
        if g_settings["RankingReward"] ;方舟排名奖励
            RankingReward()
        if g_settings["FriendPoint"]
            FriendPoint()
        if g_settings["Mail"]
            Mail()
        if g_settings["Mission"]
            Mission()
        if g_settings["Pass"]
            Pass()
        if g_settings["FreeRecruit"]
            FreeRecruit()
        if g_settings["RoadToVillain"]
            RoadToVillain()
        if g_settings["Cooperate"]
            Cooperate()
        if g_settings["SoloRaid"]
            SoloRaid()
        BackToHall
    }
    MsgBox "Doro完成任务！"
    CalculateAndShowSpan()
    if g_settings["SelfClosing"]
        ExitApp
    Pause
}
SleepTimeToLabel(sleepTime) {
    return String(sleepTime / 250 - 2)
}
ColorToleranceToLabel(colorTolerance) {
    switch colorTolerance {
        case 15: return "1"
        case 35: return "2"
        default:
            return "1"
    }
}
IsCheckedToString(foo) {
    if foo
        return "Checked"
    else
        return ""
}
InterceptionBossToLabel() {
    global g_numeric_settings
    return String(g_numeric_settings["InterceptionBoss"])
}
WriteSettings(*) {
    global g_settings, g_numeric_settings, sleepTime, colorTolerance
    ; 从 g_settings Map 写入开关设置
    for key, value in g_settings {
        IniWrite(value, "settings.ini", "Toggles", key)
    }
    for key, value in g_numeric_settings {
        IniWrite(value, "settings.ini", "NumericSettings", key)
    }
    ; 写入其他独立设置
    IniWrite(sleepTime, "settings.ini", "Other", "sleepTime")
    IniWrite(colorTolerance, "settings.ini", "Other", "colorTolerance")
}
LoadSettings() {
    global g_settings, g_numeric_settings, sleepTime, colorTolerance
    default_settings := g_settings.Clone()
    ; 从 Map 加载开关设置
    for key, defaultValue in default_settings {
        readValue := IniRead("settings.ini", "Toggles", key, defaultValue)
        g_settings[key] := readValue
    }
    default_numeric_settings := g_numeric_settings.Clone() ; 保留一份默认数值设置
    for key, defaultValue in default_numeric_settings {
        readValue := IniRead("settings.ini", "NumericSettings", key, defaultValue)
        ; 确保读取的值是数字，如果不是则使用默认值
        if IsNumber(readValue) {
            g_numeric_settings[key] := Integer(readValue) ; 转换为整数
        } else {
            g_numeric_settings[key] := defaultValue
        }
    }
    ; 加载其他独立设置 (带默认值)
    sleepTime := IniRead("settings.ini", "Other", "sleepTime", 1500)
    colorTolerance := IniRead("settings.ini", "Other", "colorTolerance", 15)
}
SaveSettings(*) {
    WriteSettings()
    MsgBox "设置已保存！"
    AddLog("设置已保存！", true)
}
; 全局设置 Map 对象
global g_settings := Map(
    "Award", 1,                ; 奖励领取总开关
    "OutpostDefence", 1,       ; 前哨基地收菜
    "CashShop", 1,             ; 付费商店
    "Shop", 1,                 ; 商店总开关
    "NormalShop", 1,           ; 普通商店
    "NormalShopDust", 1,       ; 普通商店：芯尘盒
    "ArenaShop", 1,            ; 竞技场商店
    "BookFire", 1,             ; 竞技场商店：燃烧手册
    "BookWater", 1,            ; 竞技场商店：水冷手册
    "BookWind", 1,             ; 竞技场商店：风压手册
    "BookElec", 1,             ; 竞技场商店：电击手册
    "BookIron", 1,             ; 竞技场商店：铁甲手册
    "BookBox", 1,              ; 竞技场商店：手册宝箱
    "ArenaShopPackage", 1,     ; 竞技场商店：简介个性化礼包
    "ArenaShopFurnace", 1,     ; 竞技场商店：公司武器熔炉
    "ScrapShop", 1,            ; 废铁商店
    "ScrapShopGem", 1,         ; 废铁商店：珠宝
    "ScrapShopVoucher", 1,     ; 废铁商店：好感券
    "ScrapShopResources", 1,   ; 废铁商店：养成资源
    "Expedition", 1,           ; 派遣 (之前是 isCheckedExpedtion)
    "FriendPoint", 1,          ; 好友点数
    "Mail", 1,                 ; 邮箱
    "Mission", 1,              ; 任务
    "Pass", 1,                 ; 通行证
    "SimulationRoom", 1,       ; 模拟室
    "SimulationOverClock", 1,  ; 模拟室超频
    "Arena", 1,                ; 竞技场收菜
    "RankingReward", 1,        ; 排名奖励
    "RookieArena", 1,          ; 新人竞技场
    "SpecialArena", 1,         ; 特殊竞技场
    "ChampionArena", 0,        ; 冠军竞技场
    "LoveTalking", 1,          ; 咨询
    "CompanyWeapon", 1,        ; 企业武器熔炉 (商店)
    "Interception", 1,         ; 拦截战
    "Tower", 1,                ; 无限之塔总开关
    "CompanyTower", 1,         ; 企业塔
    "UniversalTower", 0,       ; 通用塔
    "LongTalk", 1,             ; 详细咨询 (若图鉴未满)
    "AutoCheckUpdate", 0,      ; 自动检查更新
    "SelfClosing", 1,          ; 完成后自动关闭程序
    "FreeRecruit", 1,          ; 活动期间每日免费招募
    "RoadToVillain", 1,        ; 德雷克·反派之路
    "Cooperate", 1,            ; 协同作战
    "SoloRaid", 1,            ; 协同作战
    ;"CheckBox",0              ; 简介个性化礼包
)
; 其他非简单开关的设置 Map 对象
global g_numeric_settings := Map(
    "NumOfLoveTalking", 10,       ; 咨询次数
    "InterceptionBoss", 1         ; 拦截战BOSS选择
)
;检测管理员身份
if !A_IsAdmin {
    MsgBox "请以管理员身份运行Doro"
    ExitApp
}
;读取设置
SetWorkingDir A_ScriptDir
try {
    LoadSettings()
}
catch as err {
    WriteSettings()
}
if g_settings["AutoCheckUpdate"] {
    CheckForUpdateHandler(false) ; 调用核心函数，标记为非手动检查
}
/**
 * 添加一个与 g_settings Map 关联的复选框到指定的 GUI 对象.
 * @param guiObj Gui - 要添加控件的 GUI 对象.
 * @param settingKey String - 在 g_settings Map 中对应的键名.
 * @param displayText String - 复选框旁边显示的文本标签.
 * @param options String - (可选) AutoHotkey GUI 布局选项字符串 (例如 "R1.2 xs+15").
 */
AddCheckboxSetting(guiObj, settingKey, displayText, options := "") {
    global g_settings, ToggleSetting ; 确保能访问全局 Map 和处理函数
    ; 检查 settingKey 是否存在于 g_settings 中
    if !g_settings.Has(settingKey) {
        MsgBox("错误: Setting key '" settingKey "' 在 g_settings 中未定义!", "添加控件错误", "IconX")
        return ; 或者抛出错误
    }
    ; 构建选项字符串，确保 Checked/空字符串 在选项之后，文本之前
    initialState := IsCheckedToString(g_settings[settingKey])
    fullOptions := options (options ? " " : "") initialState ; 如果有 options，加空格分隔
    ; 添加复选框控件，并将 displayText 作为第三个参数
    cbCtrl := guiObj.Add("Checkbox", fullOptions, displayText)
    ; 绑定 Click 事件，使用胖箭头函数捕获当前的 settingKey
    cbCtrl.OnEvent("Click", (guiCtrl, eventInfo) => ToggleSetting(settingKey, guiCtrl, eventInfo))
    ; 返回创建的控件对象 (可选，如果需要进一步操作)
    return cbCtrl
}
;创建gui
doroGui := Gui(, "Doro小帮手" currentVersion)
doroGui.Opt("+Resize")
doroGui.MarginY := Round(doroGui.MarginY * 0.9)
doroGui.SetFont("cred s12 Bold")
doroGui.Add("Text", "R1", "关闭：ctrl + 1 终止：ctrl + 2")
doroGui.Add("Text", "R1", "调整窗口：ctrl + 3 调试：ctrl + 0")
doroGui.Add("Link", " R1", '<a href="https://github.com/kyokakawaii/DoroHelper">项目地址</a>')
doroGui.SetFont()
doroGui.Add("Button", "R1 x+10", "帮助").OnEvent("Click", ClickOnHelp)
doroGui.Add("Button", "R1 x+10", "检查更新").OnEvent("Click", ClickOnCheckForUpdate)
BtnClear := doroGui.Add("Button", "R1 x+10", "清空日志").OnEvent("Click", (*) => LogBox.Value := "")
Tab := doroGui.Add("Tab3", "xm") ;由于autohotkey有bug只能这样写
Tab.Add(["设置", "任务", "商店", "战斗", "奖励", "日志"])
Tab.UseTab("设置")
doroGui.SetFont("cred s10 Bold")
doroGui.Add("Text", , "除非你知道自己在做什么，否则不要修改")
doroGui.SetFont()
AddCheckboxSetting(doroGui, "AutoCheckUpdate", "自动检查更新(确保能连上github)", "R1.2")
AddCheckboxSetting(doroGui, "SelfClosing", "任务完成后自动关闭程序", "R1.2")
doroGui.Add("Text", , "点击间隔(毫秒)")
doroGui.Add("DropDownList", "Choose" SleepTimeToLabel(sleepTime), [750, 1000, 1250, 1500, 1750, 2000]).OnEvent("Change", ChangeOnSleepTime)
doroGui.Add("Text", , "色差容忍度")
doroGui.Add("DropDownList", "Choose" ColorToleranceToLabel(colorTolerance), ["严格", "宽松"]).OnEvent("Change", ChangeOnColorTolerance)
doroGui.Add("Button", "R1", "保存当前设置").OnEvent("Click", SaveSettings)
Tab.UseTab("任务")
AddCheckboxSetting(doroGui, "Shop", "商店购买", "R1.2")
AddCheckboxSetting(doroGui, "SimulationRoom", "模拟室", "R1.2")
AddCheckboxSetting(doroGui, "Arena", "竞技场", "R1.2 Section")
AddCheckboxSetting(doroGui, "LoveTalking", "咨询妮姬", "R1.2 xs Section") ; 注意 Section 选项用法（保存此控件位置并定义一个新控件段）
AddCheckboxSetting(doroGui, "Tower", "无限之塔", "R1.2 xs")
AddCheckboxSetting(doroGui, "Interception", "异常拦截", "R1.2 xs")
AddCheckboxSetting(doroGui, "Award", "奖励收取", "R1.2 xs")
Tab.UseTab("商店")
doroGui.Add("Text", "R1.2 Section", "付费商店")
AddCheckboxSetting(doroGui, "CashShop", "领取付费商店免费钻(进不了商店的别选)", "R1.2 xs+15")
doroGui.Add("Text", "R1.2 xs Section", "普通商店")
AddCheckboxSetting(doroGui, "NormalShop", "每日白嫖2次", "R1.2 xs+15")
AddCheckboxSetting(doroGui, "NormalShopDust", "用信用点买芯尘盒", "R1.2 xs+15")
doroGui.Add("Text", " R1 xs", "竞技场商店")
doroGui.Add("Text", " R1 xs+15", "购买代码手册数量")
AddCheckboxSetting(doroGui, "BookFire", "燃烧", "R1.2 xs+15")
AddCheckboxSetting(doroGui, "BookWater", "水冷", "R1.2 X+0.5")
AddCheckboxSetting(doroGui, "BookWind", "风压", "R1.2 X+0.5")
AddCheckboxSetting(doroGui, "BookElec", "电击", "R1.2 X+0.5")
AddCheckboxSetting(doroGui, "BookIron", "铁甲", "R1.2 X+0.5")
AddCheckboxSetting(doroGui, "ArenaShopPackage", "购买简介个性化礼包", "R1.2 xs+15")
AddCheckboxSetting(doroGui, "ArenaShopFurnace", "购买公司武器熔炉", "R1.2 xs+15")
doroGui.Add("Text", "R1.2 xs Section", "废铁商店")
AddCheckboxSetting(doroGui, "ScrapShopGem", "购买珠宝", "R1.2 xs+15")
AddCheckboxSetting(doroGui, "ScrapShopVoucher", "购买全部好感券", "R1.2 xs+15")
AddCheckboxSetting(doroGui, "ScrapShopResources", "购买全部资源", "R1.2 xs+15")
Tab.UseTab("战斗")
doroGui.Add("Text", "R1.2 Section", "竞技场")
AddCheckboxSetting(doroGui, "RookieArena", "新人竞技场", "R1.2 XP+15 Y+M")
AddCheckboxSetting(doroGui, "SpecialArena", "特殊竞技场", "R1.2 Y+M")
AddCheckboxSetting(doroGui, "ChampionArena", "冠军竞技场(跟风竞猜)", "R1.2 Y+M")
doroGui.Add("Text", "R1.2 xs Section", "异常拦截编队")
doroGui.Add("DropDownList", "XP+15 Y+M Choose" InterceptionBossToLabel(), ["克拉肯(石)，编队1", "过激派(头)，编队2", "镜像容器(手)，编队3", "茵迪维利亚(衣)，编队4", "死神(脚)，编队5"]).OnEvent("Change", ChangeOnInterceptionBoss)
doroGui.Add("Text", "R1.2 xs Section", "模拟室（打5C，普通关卡需要快速战斗）")
AddCheckboxSetting(doroGui, "SimulationOverClock", "模拟室超频（默认使用上次的tag）", "R1.2 XP+15 Y+M")
doroGui.Add("Text", "R1.2 xs Section", "无限之塔")
AddCheckboxSetting(doroGui, "CompanyTower", "尽可能地爬企业塔", "R1.2 xs+15")
AddCheckboxSetting(doroGui, "UniversalTower", "尽可能地爬通用塔", "R1.2 xs+15")
Tab.UseTab("奖励")
AddCheckboxSetting(doroGui, "OutpostDefence", "领取前哨基地防御奖励+1次免费歼灭", "R1.2 Section")
AddCheckboxSetting(doroGui, "Expedition", "领取并重新派遣委托", "R1.2 xs+15")
AddCheckboxSetting(doroGui, "RankingReward", "方舟排名奖励", "R1.2 xs")
AddCheckboxSetting(doroGui, "FriendPoint", "好友点数收取", "R1.2 xs")
AddCheckboxSetting(doroGui, "Mail", "邮箱收取", "R1.2")
AddCheckboxSetting(doroGui, "Mission", "任务收取", "R1.2")
AddCheckboxSetting(doroGui, "Pass", "通行证收取", "R1.2")
AddCheckboxSetting(doroGui, "FreeRecruit", "活动期间每日免费招募", "R1.2")
AddCheckboxSetting(doroGui, "RoadToVillain", "德雷克·反派之路", "R1.2")
AddCheckboxSetting(doroGui, "Cooperate", "协同作战摆烂", "R1.2")
AddCheckboxSetting(doroGui, "SoloRaid", "单人突击日常", "R1.2")
Tab.UseTab("日志")
LogBox := doroGui.Add("Edit", "r20 w270 ReadOnly")
LogBox.Value := "日志开始...`r`n" ; 初始内容
Tab.UseTab()
doroGui.Add("Button", "Default w80 xm+100", "DORO!").OnEvent("Click", ClickOnDoro)
doroGui.Show()
;添加日志
AddLog(text, forceOutput := false) {  ; 默认参数设为false
    if (!IsObject(LogBox) || !LogBox.Hwnd) {
        return
    }
    static lastText := ""  ; 静态变量保存上一条内容
    global LogBox
    ; 如果内容与上一条相同且不强制输出，则跳过
    if (text = lastText && !forceOutput)
        return
    lastText := text  ; 保存当前内容供下次比较
    timestamp := FormatTime(, "HH:mm:ss")
    LogBox.Value .= timestamp " - " text "`r`n"
    SendMessage(0x0115, 7, 0, LogBox) ; 自动滚动到底部
}
;日志的时间戳转换
TimeToSeconds(timeStr) {
    ; 期望 "HH:mm:ss" 格式
    parts := StrSplit(timeStr, ":")
    if (parts.Length != 3) {
        return -1 ; 格式错误
    }
    ; 确保部分是数字
    if (!IsInteger(parts[1]) || !IsInteger(parts[2]) || !IsInteger(parts[3])) {
        return -1 ; 格式错误
    }
    hours := parts[1] + 0 ; 强制转换为数字
    minutes := parts[2] + 0
    seconds := parts[3] + 0
    ; 简单的验证范围（不严格）
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59 || seconds < 0 || seconds > 59) {
        return -1 ; 无效时间
    }
    return hours * 3600 + minutes * 60 + seconds
}
; 读取日志框内容，根据 HH:mm:ss 时间戳推算跨度，输出到日志框
CalculateAndShowSpan(ExitReason := "", ExitCode := "") {
    local logContent := LogBox.Value
    local lines := StrSplit(logContent, "`n")  ; 按换行符分割
    local timestamps := []
    local match := ""
    ; 提取所有时间戳（格式 HH:mm:ss）
    for line in lines {
        if (RegExMatch(line, "^\d{2}:\d{2}:\d{2}(?=\s*-\s*)", &match)) {
            timestamps.Push(match[])
        }
    }
    ; 直接取最早（第1个）和最晚（最后1个）时间戳（日志已按时间顺序追加）
    earliestTimeStr := timestamps[1]
    latestTimeStr := timestamps[timestamps.Length]
    ; 转换为秒数
    earliestSeconds := TimeToSeconds(earliestTimeStr)
    latestSeconds := TimeToSeconds(latestTimeStr)
    ; 检查转换是否有效
    if (earliestSeconds = -1 || latestSeconds = -1) {
        AddLog("推算跨度失败：日志时间格式错误。")
        return
    }
    ; 处理跨午夜情况（如 23:59:59 → 00:00:01）
    if (latestSeconds < earliestSeconds) {
        latestSeconds += 24 * 3600  ; 加上一天的秒数（86400）
    }
    ; 计算总时间差（秒）
    spanSeconds := latestSeconds - earliestSeconds
    spanMinutes := Floor(spanSeconds / 60)
    remainingSeconds := Mod(spanSeconds, 60)
    ; 格式化输出
    outputText := "Doro已帮你节省时间: "
    if (spanMinutes > 0) {
        outputText .= spanMinutes " 分 "
    }
    outputText .= remainingSeconds " 秒"
    ; 添加到日志
    AddLog(outputText)
    MsgBox outputText
}
^1:: {
    ExitApp
}
^2:: {
    Pause
}
^3:: {
    Initialization()
}
;调试指定函数
^0:: {
    ;添加基本的依赖
    Initialization()
    ;下面写要调试的函数
    SoloRaid
}
