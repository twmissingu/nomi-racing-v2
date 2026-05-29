[![English](https://img.shields.io/badge/English-blue.svg)](README.md)
[![中文](https://img.shields.io/badge/中文-red.svg)](README_zh.md)

---

# Velocity — NOMI Racing

一款 Forza 风格的 3D 赛车游戏，搭载名为 NOMI 的 AI 副驾驶，完全使用 Godot 4.6.3 + GDScript 构建。所有几何体均为程序化生成 — 零导入 3D 模型。

## 为什么选择这个项目？

Velocity 不只是另一款赛车游戏 — 它是一台有性格的完整赛车模拟器。NOMI AI 助手会实时评论你的驾驶，庆祝你的胜利，对你的碰撞做出反应。五种不同的赛车模式涵盖从城市赛道到沙漠越野赛段，每种模式都有独特的物理手感和冠军赛季系统。

每辆车、每条赛道、每个网格都由 CSG 原语和 ArrayMesh 程序化构建，整个游戏完全自包含，无外部资源依赖。

## 功能特性

- **5 种赛车模式**：街道赛 (GT)、一级方程式 (F1)、巴哈沙漠越野 (Baja)、纳斯卡 (NASCAR)、蔚来 (NIO)
- **46 辆赛车**，涵盖 11 种车型 — 包括 4 款蔚来车型（ES7、ET5、ET7、EP9）
- **14 条赛道** — 椭圆赛道、城市街道、山路、点对点沙漠赛段、超级高速赛道
- **NOMI AI 副驾驶** — 实时语音评论、表情系统、漂移追踪、胜利庆祝
- **完整赛季锦标赛**，每种模式配备真实积分系统（FIA、NASCAR、SCORE）
- **AI 对手**，3 种难度等级，动态平衡系统，障碍物避让
- **分屏多人**（2 名玩家，独立 HUD）
- **车库与进度系统** — 赚取积分、解锁赛车、12 项成就
- **高级物理** — 120Hz VehicleBody3D、重量转移、漂移模型、尾流效应、DRS
- **程序化音频** — 引擎声、漂移声、碰撞声、UI 音效全部运行时生成

## 快速开始

### 前置条件

- [Godot 4.6.3+](https://godotengine.org/download)（Windows、macOS 或 Linux）

### 运行

```bash
# 克隆
git clone git@github.com:twmissingu/nomi-racing-v2.git
cd nomi-racing-v2

# 启动
godot --path .
```

或在 Godot 编辑器中打开项目文件夹并按 F5。

## 操作说明

| 按键 | 操作 |
|------|------|
| W / S | 加速 / 刹车 |
| A / D | 转向 |
| 空格 | 手刹 |
| Q | 回头看 |
| R | 重置车辆 |
| ESC | 暂停 |

支持手柄：右扳机（油门）、左扳机（刹车）、左摇杆（转向）。

分屏玩家 2：方向键 + 小键盘。

## 给 AI Agent

本项目为 AI agent 无缝交互而设计：

```bash
# 克隆并进入
git clone git@github.com:twmissingu/nomi-racing-v2.git
cd nomi-racing-v2

# 无头验证（无需显示器）
/opt/homebrew/bin/godot --headless --path . --quit

# 运行游戏
/opt/homebrew/bin/godot --path .
```

**核心架构：**
- 4 个自动加载：`InputManager`、`SaveManager`、`GameManager`、`RaceManager`（加载顺序很重要）
- 所有 UI 由 GDScript 代码构建（无 .tscn UI 场景）
- 车辆使用组合模式：控制器作为 VehicleBody3D 的子节点
- 赛道在 `_ready()` 中通过 ArrayMesh + CSG 生成几何体
- 120Hz 物理以确保 VehicleBody3D 稳定性

详见 [CLAUDE.md](CLAUDE.md) 完整技术文档。

## 项目结构

```
autoloads/          # InputManager、SaveManager、GameManager、RaceManager
cars/               # CarBase、控制器、46 个车辆定义、11 个网格构建器
tracks/             # TrackData、14 个赛道场景、检查点系统
scenes/             # 赛事编排器、分屏、相机、倒计时、结果展示
ui/                 # 主菜单、车库、赛道选择、赛事设置、HUD、暂停、设置、赛季
nomi/               # NOMI 控制器、HUD 头像、评论系统
data/               # 玩家档案、比赛结果结构
```

## 许可证

[MIT](LICENSE)
