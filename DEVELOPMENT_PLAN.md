# NOMI Racing — 开发方案

> 融合蔚来元素的 3D 赛车游戏，运行于 macOS Apple Silicon
> 引擎：Godot 4.6.1 | 语言：GDScript | 基础项目：amarcuss/racing-game

---

## 项目概览

**NOMI Racing** 是一款以蔚来品牌为核心的 3D 赛车游戏。玩家默认驾驶蔚来 ES7，通过比赛解锁 ET5、ET7，最终获得旗舰超跑 EP9。蔚来车载 AI 助手 NOMI 担任比赛领航员和评论员，在 HUD 角落以表情动画陪伴全程。

- **视觉风格**：写实 PBR + NIO 品牌感（深色底 + NIO Blue `#00A1E0`）
- **优先级**：视觉冲击 + 驾驶手感 > 内容丰富 > 性能
- **目标水平**：PS3/早期 PS4 时代赛车游戏（类似《赛车计划》初代）

---

## 技术选型

| 项目 | 选择 | 理由 |
|------|------|------|
| 引擎 | Godot 4.6.1 (MIT) | macOS 原生支持最佳，完全开源 |
| 语言 | GDScript | LLM 生成质量高，学习曲线低 |
| 基础项目 | `amarcuss/racing-game` | Forza 风格，42 车 14 赛道，AI 对手，VehicleBody3D 物理 |
| 渲染 | Vulkan Forward+ | PBR 材质，SSR 反射，SSAO，粒子系统 |
| 资产 | Kenney CC0 + Sketchfab CC-BY + Poly Haven + ambientCG | 全部免费开源 |

---

## 蔚来元素

### NOMI 助手

| 功能 | 说明 |
|------|------|
| 比赛领航员 | 播报位置变化、圈数、剩余时间、对手距离 |
| 比赛评论员 | 对超车、漂移、碰撞做出实时反应 |
| 表情动画 | 开心、紧张、惊讶、庆祝等状态 |
| HUD 集成 | 角落显示 NOMI 圆形头像 + 文字气泡 |

### 蔚来车型

| 车型 | 性能 | 游戏定位 | 3D 模型来源 |
|------|------|----------|------------|
| **ES7** | 653hp, 5.0s 0-100 | 默认车（新手友好） | Sketchfab CC-BY (589K 面，需减面) |
| **ET5** | 490hp, 4.0s 0-100 | 中期解锁 | Kenney sedan_sports 替代 |
| **ET7** | 653hp, 3.8s 0-100 | 中后期解锁 | Sketchfab CC-BY (需减面) |
| **EP9** | 1360hp, 2.7s 0-100 | 终极奖励 | Sketchfab CC-BY (56K 面) |

### 品牌元素

- **UI 主题**：NIO Blue `#00A1E0` 强调色 + 深色底 `#0A0E1A`
- **NIO Power 换电站**：比赛中的 Pit Stop 机制（动画：驶入 → 机器人换电 → 驶出）
- **Formula E 涂装**：NIO 333 Racing 蓝色涂装作为 EP9 特殊皮肤
- **纽北记录挑战**：特定赛道模式，目标打破 EP9 的 6:45.9 记录
- **成就系统**：蔚来社区文化命名（"牛屋常客"、"换电达人"、"纽北传奇"）
- **NOMI 语音**：倒计时、完赛祝贺等关键时刻的 NOMI 风格提示音

---

## 资产来源

| 资产 | 来源 | 许可证 | 用途 |
|------|------|--------|------|
| 通用车辆 (45) | kenney.nl/assets/car-kit | CC0 | 非 NIO 车辆补充 |
| NIO EP9 (56K 面) | sketchfab.com | CC-BY | 蔚来超跑 |
| NIO ET7 | sketchfab.com | CC-BY | 蔚来轿车 |
| NIO ES7 (589K 面) | sketchfab.com | CC-BY | 蔚来 SUV |
| 赛道组件 (110) | kenney.nl/assets/racing-kit | CC0 | 赛道装饰 |
| 自然素材 (330) | kenney.nl/assets/nature-kit | CC0 | 环境美化 |
| UI 元素 (430) | kenney.nl/assets/ui-pack | CC0 | 界面素材 |
| HDR 天空 | polyhaven.com | CC0 | 天空盒 |
| PBR 纹理 | ambientcg.com | CC0 | 路面材质 |
| 引擎音效 | opengameart.org | CC0/CC-BY | 音效 |
| 碰撞音效 | kenney.nl/assets/impact-sounds | CC0 | 音效 |

---

## 开发计划

### Sprint 0：环境搭建（1-2天）

1. 安装 Godot 4.6.1（`brew install --cask godot`）
2. 克隆 `amarcuss/racing-game` 作为基础
3. 验证项目在 macOS 上运行
4. 创建资产目录结构
5. 下载所有免费资产（Kenney 系列、Sketchfab NIO 模型、Poly Haven HDR、ambientCG 纹理）
6. 初始化 git 仓库

### Sprint 1：核心驾驶（1-2周）

**目标**：替换程序化网格为 3D 模型，优化驾驶手感

- 创建 `cars/car_model_loader.gd` — 模型加载器（支持 Kenney + NIO）
- 创建 `cars/car_model_registry.gd` — 模型注册表
- 修改 `cars/car_base.gd` — 使用 GLB 模型替换 CSG 网格
- 创建 `shaders/car_paint.gdshader` — 金属车漆着色器
- NIO 车型专属物理参数（EP9 赛道级、ET7 豪华级、ES7 SUV 级）
- 重建 City Streets 赛道（Kenney 组件替换 CSG 基元）
- 改进摄像机（速度 FOV、转向倾斜）

### Sprint 2：视觉升级（2-3周）

**目标**：PBR 材质、HDR 天空、环境美化

- `environment/sky_manager.gd` — HDR 天空 + SSAO + Bloom + SSR
- `materials/road_materials.gd` — PBR 路面材质
- `materials/terrain_material.gd` — 世界空间 UV 地形着色器
- `tracks/nature_placer.gd` — 自动放置树木、岩石、灌木
- `environment/reflection_manager.gd` — 反射探针
- 修改所有 14 条赛道的环境和材质
- NIO 车型专属材质（EP9 碳纤维、ET7 内饰质感）

### Sprint 3：游戏玩法 + NOMI（2-3周）

**目标**：AI 验证、UI 系统、NOMI 助手、比赛模式

- AI 对手验证和调优
- NIO 风格 UI 主题（NIO Blue 强调色）
- **NOMI 系统**：
  - `nomi/nomi_controller.gd` — 状态机（闲置、领航、评论、庆祝）
  - `nomi/nomi_expressions.gd` — 表情管理
  - `nomi/nomi_hud.gd` — HUD 头像组件
  - `nomi/nomi_commentary.gd` — 评论文本生成
- 启动菜单、车库（NIO Space 风格）、赛道选择、比赛设置、HUD
- EP9 纽北记录挑战模式
- NIO Power 换电 Pit Stop 动画

### Sprint 4：特效与氛围（2-3周）

**目标**：粒子系统、天气、昼夜循环、后处理

- 增强粒子系统（烟雾、排气、火花、尘土）
- 轮胎印系统（Decal 池化）
- 天气系统（晴天、阴天、雨天、暴风雨）
- 昼夜循环
- 体积雾 + 后处理（运动模糊、暗角、色彩分级）
- EP9 电动机声浪效果
- NOMI 天气反应表情

### Sprint 5：打磨与发布（2-3周）

**目标**：改装、音效、优化、打包

- 车辆涂装系统（NIO 蓝默认、Formula E 涂装、自定义颜色）
- 音效系统（电动机声浪、漂移音、NOMI 语音提示）
- 性能管理器（Low/Medium/High/Ultra 画质预设）
- MultiMesh 合批、LOD、粒子裁剪优化
- macOS 导出（universal binary + .dmg 打包）
- 成就系统
- 最终集成测试

---

## 技术注意事项

- **120Hz 物理**：VehicleBody3D 在 60Hz 下不稳定，保持 `physics_ticks_per_second=120`
- **Vulkan 兼容**：所有着色器需兼容 MoltenVK，避免 compute shader
- **性能目标**：Apple M3 1080p Medium 预设 60 FPS（< 2000 draw calls, < 500K 三角形）
- **NIO 模型优化**：Sketchfab 高面数模型需在 Blender 中减面至 30K-60K
- **CC-BY 合规**：NIO 模型需在游戏 Credits 中标注原作者
- **架构保持**：保留基础项目的 4 个 Autoload、组合模式、ArrayMesh 赛道生成

---

## 视觉效果能力

Godot 4 Vulkan Forward+ 支持的效果：

| 效果 | 实现方式 | 视觉提升 |
|------|----------|----------|
| PBR 车漆 | 自定义着色器（金属 + 清漆 + 闪粉） | 车辆质感大幅增强 |
| 环境反射 | HDR 天空 + SSR + 反射探针 | 车漆映射环境 |
| 屏幕空间反射 | WorldEnvironment SSR | 路面湿滑反射 |
| 全局光照 | SDFGI / 烘焙光照 | 场景光照真实 |
| SSAO | WorldEnvironment | 阴影细节增强 |
| Bloom/Glow | WorldEnvironment | 车灯、阳光光晕 |
| GPU 粒子 | GPUParticles3D | 烟雾、火花、尘土 |
| 体积雾 | WorldEnvironment | 大气深度感 |
| 色调映射 | Filmic tonemap | 电影级色彩 |
| 暗角 | 自定义着色器 | 画面聚焦感 |
| 运动模糊 | 自定义着色器 | 速度感增强 |
| 天气系统 | 粒子 + 着色器 + 物理参数 | 雨天/晴天切换 |
| 昼夜循环 | 光照旋转 + 色温变化 | 时间变化感 |

---

*文档版本：v1.0 | 2026-05-29*
