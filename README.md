# Solar Explorer

Apple Vision Pro 上的沉浸式太阳系探索 App。支持三种空间模式：2D 信息窗口、3D 桌面模型、全沉浸式星空体验。

## 功能

- **Window 模式** — 行星列表，点击查看详情卡片（名称、直径、轨道、冷知识）
- **Volume 模式** — 桌面大小的 3D 太阳系，行星实时公转/自转，手势旋转和缩放
- **Immersive 模式** — 全尺寸太阳系环绕用户，星空背景，支持 Mixed/Full 切换
- 太阳日冕粒子效果
- 2K 行星纹理贴图（PBR 材质）
- 注视高亮 + 点击选择 + 拖拽旋转 + 捏合缩放

## 环境要求

| 项目 | 版本 |
|------|------|
| Xcode | 16.0+ |
| macOS | Sonoma 14.0+ |
| visionOS SDK | 2.0+ |
| Swift | 6.0 |
| visionOS Simulator | 需单独下载（Xcode → Settings → Components） |

## 快速开始

```bash
# 1. 克隆项目
git clone git@github.com:syu-lk4b/ios_visonpro_test.git
cd ios_visonpro_test

# 2. 生成 Xcode 项目（需要 xcodegen）
brew install xcodegen  # 如果还没装
xcodegen generate

# 3. 打开项目
open SolarExplorer.xcodeproj

# 4. 选择 Apple Vision Pro 模拟器，⌘R 运行
```

**命令行编译（无需模拟器）：**

```bash
xcodebuild -project SolarExplorer.xcodeproj \
  -target SolarExplorer \
  -sdk xros26.2 \
  CODE_SIGNING_ALLOWED=NO build
```

## 项目结构

```
SolarExplorer/
├── SolarExplorerApp.swift       # App 入口，注册 3 种场景
├── Models/
│   ├── Planet.swift             # 行星数据模型 + 缩放逻辑
│   └── SolarSystemModel.swift   # @Observable 状态管理
├── Views/
│   ├── HomeView.swift           # Window: 行星列表
│   ├── SolarSystemView.swift    # Volume: 3D 太阳系 + 手势
│   ├── ImmersiveView.swift      # Immersive: 全沉浸体验
│   └── PlanetDetailCard.swift   # 行星详情卡片
├── Systems/
│   ├── OrbitComponent.swift     # ECS 公转组件 + OrbitMath
│   ├── OrbitSystem.swift        # ECS 公转系统
│   ├── RotationComponent.swift  # ECS 自转组件
│   └── RotationSystem.swift     # ECS 自转系统
├── Helpers/
│   ├── EntityFactory.swift      # 程序化创建 3D 实体
│   └── PlanetTextures.swift     # 纹理加载 + PBR 材质
└── Resources/
    └── Textures/                # 2K 行星纹理 (CC-BY 4.0)
```

## 架构

```
┌─────────────────────────────────────────────────┐
│  SolarExplorerApp                               │
│  ├── WindowGroup          → HomeView            │
│  ├── WindowGroup(Volume)  → SolarSystemView     │
│  └── ImmersiveSpace       → ImmersiveView       │
│                                                 │
│  共享状态: SolarSystemModel (@Observable)         │
└─────────────────────────────────────────────────┘
```

详见 [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## 测试

```bash
xcodebuild -project SolarExplorer.xcodeproj \
  -scheme SolarExplorer \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  test
```

10 个单元测试：PlanetTests (6) + OrbitSystemTests (4)

## 纹理说明

行星纹理来自 [Solar System Scope](https://www.solarsystemscope.com/textures/)，采用 **CC-BY 4.0** 许可证。删除 `Resources/Textures/` 后 App 自动 fallback 到纯色球体。

## License

MIT
