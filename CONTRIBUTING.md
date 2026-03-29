# Contributing Guide

## 开发流程

1. 从 `main` 创建功能分支：`feat/<description>` 或 `fix/<description>`
2. 修改代码后运行 `xcodegen generate` 更新项目
3. 确认 `xcodebuild` 编译通过，0 errors 0 warnings
4. 运行测试（如有模拟器）
5. 提交（Conventional Commits 格式），推送，创建 PR

## 添加新行星/天体

1. 在 `Planet.swift` 的 `allPlanets` 数组中添加数据
2. 下载对应纹理到 `Resources/Textures/<id>_texture.jpg`
3. 运行 `xcodegen generate`
4. 运行 `PlanetTests` 确认缩放范围仍在合理区间

## 添加新的 ECS System

1. 在 `Systems/` 创建 `XxxComponent.swift`（实现 `Component` 协议）
2. 在 `Systems/` 创建 `XxxSystem.swift`（实现 `System` 协议）
3. 在 `SolarExplorerApp.init()` 中注册
4. 在 `EntityFactory` 中给需要的实体设置新 Component

## 添加新的交互手势

1. 确保目标 Entity 有 `CollisionComponent` + `InputTargetComponent`
2. 在对应 View 的 `RealityView` 上添加 `.gesture()` modifier
3. `DragGesture` 注意追踪 delta（translation 是累积值）
4. `MagnifyGesture` 注意保存 baseScale

## 代码风格

- Swift 6 strict concurrency：所有操作 RealityKit 的类型需要 `@MainActor`
- 优先使用 `guard let` 而非 force-unwrap
- ECS 系统中四元数操作后调用 `simd_normalize()`
- 纯计算逻辑提取到 `enum`（如 `OrbitMath`）方便单元测试
