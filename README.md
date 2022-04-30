# x64dbg-xmake
x64dbg xmake 工程

## 安装
* [xmake](https://github.com/xmake-io/xmake)
* [visual Studio 2013](https://my.visualstudio.com/Downloads?q=visual%20studio%202013&wt.mc_id=o~msft~vscom~older-downloads)
* [Qt 5.6.3 (x86) for MSVC2013](https://osdn.net/projects/x64dbg/storage/qt/qt-opensource-windows-x86-msvc2013-5.6.3.exe) 安装到 `C:\Qt\qt-5.6.3-x86-msvc2013`
* [Qt 5.6.3 (x64) for MSVC2013](https://osdn.net/projects/x64dbg/storage/qt/qt-opensource-windows-x86-msvc2013_64-5.6.3.exe) 安装到 `C:\Qt\qt-5.6.3-x64-msvc2013`
* vs2013 + qt5.6.3 x64dbg 推荐配置
## 配置

#### 克隆
```bash
$ git clone --recurse-submodules https://github.com/yecate/x64dbg-xmake.git
```

#### x32dbg

```bash
$ xmake f --qt=C:\Qt\qt-5.6.3-x86-msvc2013 --vs=2013 -a x86
$ xmake
```

#### x64dbg

```bash
$ xmake f --qt=C:\Qt\qt-5.6.3-x64-msvc2013 --vs=2013 -a x64
$ xmake
```