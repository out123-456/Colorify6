![](assets/c6mask2.png)

基于 Flutter 开发的 Minecraft BE 粒子/方块画生成器。

## 支持的游戏版本

几乎所有现代版本的 MC 基岩版。

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

2. 将项目克隆到你的电脑：

```bash
git clone [https://github.com/ComeixAlpha/Colorify6.git](https://github.com/ComeixAlpha/Colorify6.git)
```