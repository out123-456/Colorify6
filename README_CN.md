<p align="right">
  <b>语言：<a href="README.md">English</a></b>
</p>

![](assets/c6mask2.png)

基于 Flutter 开发的 Minecraft BE 粒子/方块画生成器。

## 支持的游戏版本

几乎所有现代版本的 MCBE（基岩版）。

## 支持平台

<table>
    <tr>
        <td rowspan="2">Windows</td>   
        <td>Win10+</td> 
        <td>&#10003</td> 
   </tr>
       <tr>
        <td>其他版本</td> 
        <td>&#10005</td> 
   </tr>
    <tr>
        <td rowspan="2">Android</td>    
       <td>鸿蒙 (HarmonyOS)</td> 
       <td>&#10005</td> 
    </tr>
    <tr>
        <td>其他版本</td> 
        <td>&#10003</td> 
    </tr>
    <tr>
        <td>Linux</td>
        <td colspan="2", align="right">&#10005</td> 
    </tr> 
    <tr>
        <td>iOS/MacOS</td> 
        <td colspan="2", align="right">&#10005</td> 
    </tr> 
</table>

*注：不支持也不打算支持网易版*

## 安装指南

- **Android (安卓)**

下载最新发布版本（Release），安装并授予所需的所有权限。

如果你不知道该下载哪个文件，请选择 `app-arm64-v8a-release.apk`。

生成的工程文件将保存在：`/storage/emulated/0/Download/`。

- **Windows**

下载发布包 `windows.zip` 并解压缩到你喜欢的路径。

运行 `colorify.exe`，生成的工程文件将保存在：`C:\Users\用户名\Documents\colorify`。

## 自行构建 (编译)

1. 确保你已安装 Dart SDK 和 Flutter SDK。

2. 将项目克隆到你的本地电脑：

```bash
git clone https://github.com/ComeixAlpha/Colorify6.git
```

3. 获取项目依赖：

```bash
flutter pub get
```

4. 根据你的需求，带上平台参数进行构建：

- Android

```bash
flutter build apk --split-per-abi
```

- Windows

```bash
flutter build windows
```

## 功能特性

- **生成高度可定制的粒子画**
  - 通过资源包自动生成所需的全部粒子。
  - 支持带有动态色彩控制的浮尘（Dust）粒子。
- **生成高度可定制的方块画**
  - 内置插值算法，直接在 Colorify 中调整图像尺寸。
  - 内置 Floyd-Steinberg 抖动算法，提升色彩过渡效果。
  - 支持 RGB 及 RGB+ 颜色距离算法。
  - 兼容所有游戏版本。
- **自动创建 .mcpack 与 .mcaddon 文件**
  - 支持自定义包信息。
  - 自动生成精美的哈希风格包图标。
  - 包含函数 (Functions)。
  - 包含脚本 (Scripts)。
  - 包含结构 (Structures)。
  - 包含粒子 JSON。
- **WebSocket 支持**
  - 所有生成内容均支持通过 WebSocket 远程发送。
