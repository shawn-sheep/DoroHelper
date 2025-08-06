#Requires AutoHotkey v2.0
;tag 德雷克·反派之路
AwardRoadToVillain() {
    BackToHall()
    AddLog("===反派之路任务开始===")
    Text := "|<ROAD>*200$29.zzzznzzzy3zzwtbztlnCDbVaEC73BaNA6HQaPAYtAqN9WPgWOAq11kNw270XNYSN6bzxm9DznY5zy7AzzwCTzzzU"
    while (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2 * PicTolerance, 0.2 * PicTolerance, Text, , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    else {
        AddLog("===找不到反派之路任务===")
        return
    }
    loop 3 {
        if A_Index = 1 {
            Text := "|<任务>*181$41.1U103U03Uz0D00Dzz0zzkTzs3zzVvz0Tzy7US0zXsD0w0rzUy1s0Tz3w3kDzzvzzyTsznzzwQQ33zzs0w070w1zzwC1s3zzsQ3k0T3ks7U0w71nzw7kC3bztzDw7DzlsTkC0030T2"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, Text, , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("点击任务")
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
        }
        if A_Index = 2 {
            Text := "|<周任务>*183$62.7zz0Q1s0s03zzs7zz0TzUzzy3zzkDzwDzzUzzkDzz3XlsSTk7yTUzzyDUw1zzkDzzbsD0Bzs3zxty3k7zzszzyTzztzzzDzzXzzyTwzXzzsTzzX7U0vzS7zzkzzwSzrVsD0Dzz7jxsS3k3zzlvrS7Uw07kwQzrUsDU3sDDDzsCzzXw7nnny3jztyTsMET0vzyS3w003UC0000Q2"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, Text, , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("点击周任务")
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
        }
        if A_Index = 3 {
            Text := "|<奖励>*181$40.3VU0031CD0DzQCtzszxkzzzXzr1jwSC0Q1vvkzzzTXy3zzzyDkDzzyzy0z1rnjU3zbQCs0TyRk3U1rtrzzzbRbTzzyRytzzztrvb0zU7zyQTzUTjlzwTtzzyzUzjzttk0Q/Mb8"
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, Text, , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("点击奖励")
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
        }
        Text := "|<灰色的全部领取>*170$81.zrzzbzzxzzzzzzwTzwz0zDU707zzVzw0s7sy0s107lbz07Qy3xzbA0wSDwsvbrDjwvX67szrjRww0DUSw1zUytvD9wsw3rcDw7nDPzjjbaSNs07s0PDxxgwvnDwDz03Rw3hbaTNznzzzvbkBgw3sTyTzzzQznhbWT3w0Dw0vbyRgwlwTU1zU7QzrVba7Xznzwwv7kzDs0sTyTzjbNyDsz0C1znzwsvztyNzlX400DU7TzbbbzQwU"
        while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2 * PicTolerance, 0.2 * PicTolerance, Text, , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("点击全部领取")
            UserClick(1662, 2013, TrueRatio)
            Sleep 500
        }
        Text := "|<活动结束>*150$67.byDztzbnzwzsUDUQzXsy00SuDzyTnU300Dzjzw1nQDzbzzXzy0FDDw06A040n873w03Xsz0ta60SQtzyznwnbzzCQzyDtivUzzU0TM0xqRUM3s0D4yQlCvwtz0zaTC06Tywz07bDb77D1SS4lnU3zW61UCCQ/k1zv3jk7DDg"
        while !(ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2 * PicTolerance, 0.2 * PicTolerance, Text, , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("点击全部领取")
            UserClick(1662, 2013, TrueRatio)
            Sleep 500
        }
        Sleep 1000
    }
    AddLog("===反派之路任务结束===")
    BackToHall()
}
