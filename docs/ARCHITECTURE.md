# Architecture

## 系统概览

```
┌──────────────────────────────────────────────────────────────┐
│                    SolarExplorerApp                          │
│                                                              │
│  ┌─────────────┐  ┌────────────────┐  ┌──────────────────┐  │
│  │ WindowGroup │  │ WindowGroup    │  │ ImmersiveSpace   │  │
│  │ (Window)    │  │ (Volume)       │  │                  │  │
│  │  HomeView   │  │ SolarSystem-   │  │ ImmersiveView    │  │
│  │             │  │ View           │  │                  │  │
│  └──────┬──────┘  └───────┬────────┘  └────────┬─────────┘  │
│         └─────────────────┼─────────────────────┘            │
│              ┌────────────▼────────────┐                     │
│              │   SolarSystemModel      │                     │
│              │   (@Observable)         │                     │
│              └─────────────────────────┘                     │
└──────────────────────────────────────────────────────────────┘
```

## RealityKit ECS 架构

```
Entity (行星)
    ├── ModelComponent          ← 球体 mesh + 纹理材质
    ├── OrbitComponent          ← radius, speed, angle
    ├── RotationComponent       ← speed, axis
    ├── CollisionComponent      ← 手势检测
    ├── InputTargetComponent    ← 启用手势输入
    └── HoverEffectComponent    ← 注视高亮

OrbitSystem → 每帧更新行星位置 (OrbitMath.position)
RotationSystem → 每帧更新行星朝向 (simd_quatf + normalize)
```

## 缩放策略

采用 **对数缩放** 压缩太阳系尺度差异：

| 属性 | 输入范围 | 输出范围 (Volume) | 缩放方式 |
|------|----------|-------------------|----------|
| 轨道半径 | 57.9 ~ 4495.1 M km | 0.08 ~ 0.45 m | log + clamp |
| 球体半径 | 4,879 ~ 139,820 km | 0.005 ~ 0.05 m | log + clamp |
| 公转速度 | 88 ~ 59,800 天 | ~4s ~ ~100s/圈 | 倒数 sqrt |

Immersive 模式在 Volume 基础上乘以 5x 系数。

## 纹理加载

`PlanetTextures.material(for:)` 异步加载 → PBR 材质，失败自动 fallback 到纯色。

## 手势处理

| 手势 | 行为 | 实现要点 |
|------|------|----------|
| SpatialTapGesture | 选中行星 | entity.name 匹配 Planet.id |
| DragGesture | 旋转太阳系 | 追踪 delta（非累积值） |
| MagnifyGesture | 缩放太阳系 | 保存 baseScale 跨手势 |
