# Solar Explorer — visionOS 太阳系探索器设计文档

## 概述

一个面向 Apple Vision Pro 的沉浸式太阳系探索 App。用户可以在三种空间模式下浏览太阳系：从 2D 信息窗口，到 3D 桌面模型，再到全沉浸式星空体验。目标是作为 visionOS 入门学习项目，同时具备足够的视觉冲击力用于展示。

## 目标用户

开发者本人（学习 + 技术探索 + 展示）

## 三层空间架构

### Layer 1: Window（2D 窗口）

- App 启动后的主界面
- 展示太阳系概览列表，包含各行星缩略图和基本信息
- 标准 SwiftUI 平面 UI，浮在用户面前
- 入口按钮："探索太阳系" → 打开 Volume

### Layer 2: Volume（3D 体积窗口）

- 桌面大小的 3D 太阳系模型出现在用户面前
- 行星绕太阳公转，可手势旋转整个模型
- 点击行星弹出信息卡片（Attachment）
- 入口按钮："沉浸体验" → 进入 Immersive Space

### Layer 3: Immersive Space（全沉浸空间）

- 行星放大到环绕用户的比例
- 星空 Skybox 背景包裹四周
- 默认使用 `.mixed` 风格（虚拟物体叠加真实环境），可切换为 `.full`（纯虚拟星空）
- 手势退出回到 Volume

## 用户流程

```
启动 App (Window)
  → 点击 "探索太阳系"
  → 打开 Volume（桌面太阳系模型）
  → 手势拖拽旋转、缩放
  → 点击某颗行星
  → 弹出行星信息卡片 (Attachment)
  → 点击 "沉浸体验"
  → 进入 Full Immersive Space
  → 手势退出回到 Volume
```

## 3D 内容与视觉设计

### 太阳系模型

| 元素 | 实现方式 |
|------|----------|
| 太阳 | 程序化生成的发光球体 + 粒子效果模拟日冕 |
| 8 大行星 | USDZ 模型，带真实纹理贴图 |
| 轨道线 | 半透明椭圆环，程序化生成 |
| 背景星空 | Immersive Space 中用 Skybox 全景星空图 |

### 动画效果

- 行星持续公转（速度按比例缩放，保证视觉可读性）
- 行星自转
- 太阳光照效果，行星实时阴影
- 进入沉浸模式时缩放过渡动画

### 交互设计

| 交互方式 | 行为 |
|----------|------|
| 注视 (Gaze) | 看向行星时高亮显示名称标签 |
| 捏合拖拽 (Pinch & Drag) | 旋转整个太阳系模型（Volume 模式） |
| 点击 (Tap) | 选中行星，弹出信息卡片 |
| 缩放 (Magnify) | 双手捏合放大/缩小模型 |

### 行星信息卡片内容

- 行星名称
- 大小（直径）
- 距太阳距离
- 有趣的冷知识

## 技术选型

| 技术 | 用途 |
|------|------|
| SwiftUI | 2D 界面层（Window、信息卡片） |
| RealityKit | 3D 渲染（行星模型、粒子效果、光照） |
| Reality Composer Pro | 构建 3D 场景、管理 USDZ 资源 |
| ARKit | 手势追踪和空间锚定（Immersive Space） |

### 架构模式

- RealityKit **ECS（Entity-Component-System）** 架构管理行星运动
- 行星数据用 Swift `struct` + 静态数据，无需后端
- SwiftUI `@Observable` 进行状态管理

## 项目结构

```
SolarExplorer/
├── SolarExplorerApp.swift          # App 入口，注册 Window/Volume/ImmersiveSpace
├── Views/
│   ├── HomeView.swift              # 主窗口（行星列表）
│   ├── SolarSystemView.swift       # Volume 中的 3D 太阳系
│   ├── ImmersiveView.swift         # 全沉浸空间
│   └── PlanetDetailCard.swift      # 行星信息卡片（Attachment）
├── Models/
│   ├── Planet.swift                # 行星数据模型
│   └── SolarSystem.swift           # 太阳系状态管理
├── Systems/
│   ├── OrbitSystem.swift           # ECS 公转系统
│   └── RotationSystem.swift        # ECS 自转系统
├── Resources/
│   └── SolarSystem.rkassets/       # Reality Composer Pro 场景包
└── Extensions/
    └── Entity+Planet.swift         # Entity 扩展工具方法
```

## 开发环境要求

- Xcode 16+（含 visionOS SDK）
- macOS Sonoma 14.0+
- visionOS Simulator 可用于调试，不需要实体 Vision Pro 设备

## 分阶段实施建议

### Phase 1: 基础骨架
- 创建 visionOS 项目
- 实现 Window 主界面（行星列表）
- 在 Volume 中显示一个静态球体

### Phase 2: 太阳系模型
- 添加太阳和 8 大行星
- 实现公转和自转动画（ECS）
- 添加轨道线

### Phase 3: 交互
- 注视高亮
- 点击选中 + 信息卡片
- 手势旋转和缩放

### Phase 4: 沉浸体验
- 实现 Immersive Space
- 星空 Skybox 背景
- 过渡动画
- 太阳光照和阴影

### Phase 5: 打磨
- 太阳粒子效果（日冕）
- 行星纹理优化
- 动画平滑度调优
- 性能优化
