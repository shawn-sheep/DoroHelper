<div align="center">

<img alt="LOGO" src="./img/logo.png" width="256" height="256" />

# DoroHelper

PC 端日常任务清理助手。一键清理多项日常事务。支持除**国服**外的所有客户端。

<p align="center">
  <img alt="AutoHotkeyV2" src="https://img.shields.io/badge/AutoHotkeyV2-white?logo=AutoHotkey&logoColor=black">
  <img alt="platform" src="https://img.shields.io/badge/platform-Windows-blueviolet">
  <img alt="license" src="https://img.shields.io/github/license/1204244136/DoroHelper">
  <br/>
  <img alt="commit" src="https://img.shields.io/github/commit-activity/m/1204244136/DoroHelper">
  <img alt="stars" src="https://img.shields.io/github/stars/1204244136/DoroHelper?style=social">
  <a href="https://mirrorchyan.com/?source=doro-github-release" target="_blank"><img alt="mirrorc" src="https://img.shields.io/badge/Mirror%E9%85%B1-%239af3f6?logo=countingworkspro&logoColor=4f46e5"></a>
</p>

</div>

## 我们联合！

- 牢 N 写的功能类似的[手机脚本](https://github.com/Zebartin/autoxjs-scripts)

- 牢 D 功能类似的[模拟器脚本](https://github.com/takagisanmie/NIKKEAutoScript)

- 群友的[CDK 兑换网站](http://nikke.hayasa.link/)

## 版本问题

下方的功能介绍均针对最新版本，老版本的对应功能请查看[legacy-v0.1.22](https://github.com/1204244136/DoroHelper/tree/legacy-v0.1.22)分支处的自述文件。
老版本已停止维护！

**⚠️ 为了各自生活的便利，请不要在公开场合发布本软件国服相关的修改版本，谢谢配合！**

## 免责声明

本项目仅供个人学习研究使用，严禁用于商业用途。除 Github 和下方 qq 群以外其他任何网站、社交平台中有关本项目的内容**均非本人发布**，若造成侵犯著作权、版权或违反网络安全法规等任何后果，均与本人无关。

使用任何脚本程序均有封号风险，请谨慎。

程序可能会有操作不兼容的情况出现。第一次使用最好在旁边看着。万一 Doro 失控，请按 Ctrl + 1 组合键结束进程或者 Ctrl + 2 组合键暂停进程。

## 使用

### 运行仓库内的 ahk 文件（推荐）

1. 将整个项目文件下载到本地并解压（右上角绿色 code 按钮-Download ZIP）
1. 下载并安装[AutoHotkey V2.0](https://www.autohotkey.com/download/ahk-v2.exe)（不要修改默认安装路径）
1. 以管理员身份运行 DoroHelper.ahk

### 运行发行版的 exe 文件

1. 下载右边的 release 文件
1. 以管理员身份运行 DoroHelper.exe

## 功能介绍

Doro 只是想让你少被该死的读条、闪光弹和重复劳动折磨。一键清理多项日常事务（按顺序执行且均可选），包括：

- **付费商店**

  - 领取每日、周、月免费钻

- **普通商店**

  - 每天白嫖 2 次
  - 用信用点买芯尘盒
  - 购买简介个性化礼包

- **竞技场商店**

  - 购买指定类型的属性技能书
  - 购买代码手册宝箱
  - 购买简介个性化礼包
  - 购买公司武器熔炉

- **模拟室**

  - 普通模拟室（需解锁快速模拟）
  - 模拟室超频

- **竞技场**

  - 竞技场收菜
  - 新人竞技场
  - 特殊竞技场
  - 冠军竞技场

- **无限之塔**

  - 尽可能地爬企业塔
  - 尽可能地爬通用塔

- **常规奖励领取**

  - 前哨基地收菜
    - 进行派遣
  - 好感度咨询（通过收藏可调整优先级）
    - 花絮鉴赏
  - ~~方舟排名奖励~~
  - 好友点数收取
  - 邮箱收取
  - 任务收取
  - 通行证收取

- **限时奖励领取**

  - 活动期间每日免费招募
  - 协同作战摆烂
  - 单人突击日常
  - 德雷克·反派之路

## 妙妙工具

- 剧情模式
  - 对话时如果只有一个选项，在短暂延迟后点击该选项
  - 如果有两个选项，则等待玩家选择
  - 自动进行下一段剧情，自动启动 auto
  - 自动将观看过的剧情收藏

## 要求

1. 游戏分辨率需要设置成 **16:9** 的分辨率，小于 1080p 可能有问题，暂不打算特殊支持
2. 由于使用的是图像识别，请确保游戏画面完整在屏幕内，且**游戏画面没有任何遮挡**
   - 多显示器请支持的显示器作为主显示器，将游戏放在主显示器内
   - 不要使用微星小飞机、游戏加加等悬浮显示数据的软件
   - 游戏画质越高，脚本出错的几率越低。
   - 游戏帧数建议保持 60，帧数过低时，部分场景的行动可能会被吞，导致问题
3. 请不要开启会改变画面颜色相关的功能或设置，例如
   - 软件层面：各种驱动的色彩滤镜，部分笔记本的真彩模式
   - 设备层面：显示器的护眼模式、色彩模式、色温调节、HDR 等。
4. 游戏语言设置为**简体中文**，设定-画质-开启光晕效果，设定-画质-开启颜色分级，不要使用太亮的大厅背景
5. 以**管理员身份**运行 DoroHelper

## 步骤

打开 NIKKE 启动器。点击启动。等右下角腾讯 ACE 反作弊系统扫完，NIKKE 主程序中央 SHIFT UP logo 出现之后，再切出来点击“DORO!”按钮。如果你看到鼠标开始在左下角连点，那就代表启动成功了。然后就可以悠闲地去泡一杯咖啡，或者刷一会儿手机，等待 Doro 完成工作了。

也可以在游戏处在大厅界面时（有看板娘的页面）切出来点击“DORO!”按钮启动程序。

## 反馈和改进

加入[DoroHelper 反馈群](https://qm.qq.com/q/f0Q1yr7vzi)(584275905)

## 支持和鼓励

<table>
  <tr>
<img alt="支付宝收款码" src="./img/alipay.png" width="200" height="200" /><img alt="微信收款码" src="./img/weixin.png" width="200" height="200" />
  </tr>
</table>

知一一：前任作者[牢 H](https://github.com/kyokakawaii) 停更后，DoroHelper 的绝大部分维护和新功能的添加都是我在做，这耗费了我大量时间和精力，希望有条件的小伙伴们能支持一下

---

|              | 普通用户 | 铜 Doro 会员 | 银 Doro 会员 | 金 Doro 会员 |
| ------------ | -------- | ------------ | ------------ | ------------ |
| 价格         | 免费     | 6 元/月      | 18 元/月     | 30 元/月     |
| 绝大部分功能 | ✅️      | ✅️          | ✅️          | ✅️          |
| 专属对应图标 |          | ✅️          | ✅️          | ✅️          |
| 移除广告     |          | ✅️          | ✅️          | ✅️          |
| 移除赞助提示 |          | ✅️          | ✅️          | ✅️          |
| 活动结束提醒 |          | ✅️          | ✅️          | ✅️          |
| 轮换活动     |          |              | ✅️          | ✅️          |
| 群内专属称号 |          |              |              | ✅️          |

---

#### Q1： 我赞助了，怎么变成 Doro 会员？

#### A1： 加入[DoroHelper 反馈群](https://qm.qq.com/q/f0Q1yr7vzi)(584275905)，然后私信我，附带你的付款截图和设备唯一标识，24 小时内我会进行登记并通知，之后重启软件即可

---

#### Q1.1： 设备唯一标识在哪？

#### A1.1： 如果在用户组栏勾选「自动检查」，会在启动时出现在日志，未勾选的情况下，会在程序运行时出现在日志

---

#### Q1.2： 可以分期付款吗？

#### A1.2： 可以通过多张截图凑对应的额度

---

#### Q2： 其他游戏的脚本都是免费使用的，为什么到你这就收费？

#### A2： 基础功能仍然是免费使用的，但是维护新活动需要我付出相当多的精力，希望能够理解

---

## 星标历程

[![Star History Chart](https://api.star-history.com/svg?repos=1204244136/DoroHelper&type=Timeline)](https://www.star-history.com/#1204244136/DoroHelper&Timeline)

## 借物表

[Github.ahk-API-for-AHKv2](https://github.com/samfisherirl/Github.ahk-API-for-AHKv2)

[FindText-for-AHKv2](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116471)

## 鸣谢

代码参考

[M9A](https://github.com/MAA1999/M9A)
