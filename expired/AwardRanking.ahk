#Requires AutoHotkey v2.0
;region 方舟排名奖励
;tag 排名奖励
AwardRanking() {
    EnterToArk()
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.979 * NikkeW . " ", NikkeY + 0.138 * NikkeH . " ", NikkeX + 0.979 * NikkeW + 0.010 * NikkeW . " ", NikkeY + 0.138 * NikkeH + 0.018 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X - 30 * TrueRatio, Y + 30 * TrueRatio, "L")
    }
    else {
        AddLog("没有可领取的排名奖励，跳过")
        return
    }
    AddLog("===排名奖励任务开始===")
    loop 2 {
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.623 * NikkeW . " ", NikkeY + 0.213 * NikkeH . " ", NikkeX + 0.623 * NikkeW + 0.047 * NikkeW . " ", NikkeY + 0.213 * NikkeH + 0.125 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击大标题上的红点")
            FindText().Click(X, Y, "L")
            Sleep 1000
            while (ok1 := FindText(&X := "wait", &Y := 3, NikkeX + 0.632 * NikkeW . " ", NikkeY + 0.799 * NikkeH . " ", NikkeX + 0.632 * NikkeW + 0.012 * NikkeW . " ", NikkeY + 0.799 * NikkeH + 0.023 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击领取")
                FindText().Click(X, Y, "L")
            }
            Confirm
            GoBack
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.330 * NikkeW . " ", NikkeY + 0.513 * NikkeH . " ", NikkeX + 0.330 * NikkeW + 0.340 * NikkeW . " ", NikkeY + 0.513 * NikkeH + 0.109 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            loop ok.Length {
                FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
                AddLog("点击小标题上的红点")
                Sleep 1000
                while (ok1 := FindText(&X := "wait", &Y := 3, NikkeX + 0.632 * NikkeW . " ", NikkeY + 0.799 * NikkeH . " ", NikkeX + 0.632 * NikkeW + 0.012 * NikkeW . " ", NikkeY + 0.799 * NikkeH + 0.023 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击领取")
                    FindText().Click(X, Y, "L")
                }
                Confirm
                GoBack
            }
        }
        UserMove(1858, 615, TrueRatio)
        Send "{WheelDown 30}"
        Sleep 1000
    }
    AddLog("===排名奖励任务结束===")
    BackToHall
}
;endregion 方舟排名奖励
