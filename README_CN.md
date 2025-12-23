# X14F_EC25_4G_driver 项目说明

## 项目概述

本项目是基于Quectel-CM v1.6.1的X14F_EC25 4G/5G模块驱动程序，提供了4G和5G网络连接的管理功能。

## 主要功能

### 1. 4G网络管理

- **4G on**: 启动4G网络连接
- **4G off**: 关闭4G网络连接

### 2. 5G网络管理

- **5G on**: 启动5G网络连接
- **5G off**: 关闭5G网络连接

## 安装说明

1. 下载本项目的代码到本地
2. 进入项目目录，执行`sudo ./install.sh`安装

## 使用方法

### 4G网络操作

```bash
# 启动4G网络
./4G on

# 关闭4G网络
./4G off
```

### 5G网络操作

```bash
# 启动5G网络
./5G on

# 关闭5G网络
./5G off
```

## 实现原理

- **4G/5G on**: 通过执行`quectel_su`脚本，启动`quectel-CM.sh`守护进程，该进程会持续运行`quectel-CM`命令来维护网络连接
- **4G/5G off**: 通过`killall`命令终止`quectel-CM`和`quectel-CM.sh`进程，关闭网络连接

## 支持的网络类型

- 4G LTE
- 5G NSA (非独立组网)
- 5G SA (独立组网)

## 注意事项

1. 执行命令需要root权限
2. 5G功能需要硬件模块支持5G网络
3. 请确保SIM卡已正确插入并激活
4. 网络连接状态可通过`quectel-CM`的输出查看

## 文件说明

- `4G`: 4G网络管理脚本
- `5G`: 5G网络管理脚本
- `quectel_su`: 启动网络连接的脚本
- `quectel-CM.sh`: 网络连接守护进程脚本
- `quectel-CM`: 主网络连接程序
- `libmnl`: 网络管理库
- `default.script`: DHCP配置脚本

## 编译说明

如需重新编译项目，请执行以下命令：

```bash
make clean
make
```

编译完成后，将生成新的`quectel-CM`可执行文件。