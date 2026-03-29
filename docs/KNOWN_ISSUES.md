# Known Issues & Future Improvements

## 已知问题

### P1
- **Immersion style 切换未即时生效** — 需要退出再重进 immersive space 才能切换 mixed/full 模式

### P2
- **SourceKit 误报** — IDE 显示大量 "Cannot find type" 错误，以 `xcodebuild` 输出为准
- **土星缺少环** — 当前为纯球体
- **行星大小差异被压缩** — 对数缩放副作用

### P3
- **无 Volume → Immersive 过渡动画**
- **无声音/音效**
- **View/Entity 缺少自动化测试**

## 路线图

### v1.1 — 视觉增强
- [ ] 土星环
- [ ] 地球月球
- [ ] 行星轨道倾角
- [ ] 高分辨率纹理 (4K/8K)

### v1.2 — 交互增强
- [ ] 过渡动画
- [ ] 双击行星飞近
- [ ] 时间控制滑块

### v2.0 — 高级功能
- [ ] Hand tracking 抓取行星
- [ ] 多人共享空间
- [ ] 实时天文数据 API
