# 介绍

最好用的 V2Ray 一键安装脚本 &amp; 管理脚本

# 特点

- 快速安装
- 超级好用
- 零学习成本
- 自动化 TLS
- 简化所有流程
- 屏蔽 BT
- 屏蔽中国 IP
- 使用 API 操作
- 兼容 V2Ray 命令
- 强大的快捷参数
- 支持所有常用协议
- 一键添加 Shadowsocks
- 一键添加 VMess-(TCP/mKCP/QUIC)
- 一键添加 VMess-(WS/H2/gRPC)-TLS
- 一键添加 VLESS-(WS/H2/gRPC)-TLS
- 一键添加 Trojan-(WS/H2/gRPC)-TLS
- 一键添加 VMess-(TCP/mKCP/QUIC) 动态端口
- 一键启用 BBR
- 一键更改伪装网站
- 一键更改 (端口/UUID/密码/域名/路径/加密方式/SNI/动态端口/等...)
- 还有更多...

# 设计理念

设计理念为：**高效率，超快速，极易用**

脚本基于作者的自身使用需求，以 **多配置同时运行** 为核心设计

并且专门优化了，添加、更改、查看、删除、这四项常用功能

你只需要一条命令即可完成 添加、更改、查看、删除、等操作

例如，添加一个配置仅需不到 1 秒！瞬间完成添加！其他操作亦是如此！

脚本的参数非常高效率并且超级易用，请掌握参数的使用

# 脚本说明

[V2Ray 一键安装脚本](https://github.com/233boy/v2ray/wiki/V2Ray%E4%B8%80%E9%94%AE%E5%AE%89%E8%A3%85%E8%84%9A%E6%9C%AC)

# 搭建教程

[V2Ray搭建详细图文教程](https://github.com/233boy/v2ray/wiki/V2Ray%E6%90%AD%E5%BB%BA%E8%AF%A6%E7%BB%86%E5%9B%BE%E6%96%87%E6%95%99%E7%A8%8B)

# 帮助

使用: `v2ray help`

```
V2Ray script v4.21 by 233boy
Usage: v2ray [options]... [args]...

基本:
   v, version                                      显示当前版本
   ip                                              返回当前主机的 IP
   get-port                                        返回一个可用的端口

一般:
   a, add [protocol] [args... | auto]              添加配置
   c, change [name] [option] [args... | auto]      更改配置
   d, del [name]                                   删除配置**
   i, info [name]                                  查看配置
   qr [name]                                       二维码信息
   url [name]                                      URL 信息
   log                                             查看日志
   logerr                                          查看错误日志

更改:
   dp, dynamicport [name] [start | auto] [end]     更改动态端口
   full [name] [...]                               更改多个参数
   id [name] [uuid | auto]                         更改 UUID
   host [name] [domain]                            更改域名
   port [name] [port | auto]                       更改端口
   path [name] [path | auto]                       更改路径
   passwd [name] [password | auto]                 更改密码
   type [name] [type | auto]                       更改伪装类型
   method [name] [method | auto]                   更改加密方式
   seed [name] [seed | auto]                       更改 mKCP seed
   new [name] [...]                                更改协议
   web [name] [domain]                             更改伪装网站

进阶:
   dns [...]                                       设置 DNS
   dd, ddel [name...]                              删除多个配置**
   fix [name]                                      修复一个配置
   fix-all                                         修复全部配置
   fix-caddyfile                                   修复 Caddyfile
   fix-config.json                                 修复 config.json

管理:
   un, uninstall                                   卸载
   u, update [core | sh | dat | caddy] [ver]       更新
   U, update.sh                                    更新脚本
   s, status                                       运行状态
   start, stop, restart [caddy]                    启动, 停止, 重启
   t, test                                         测试运行
   reinstall                                       重装脚本

测试:
   client [name]                                   显示用于客户端 JSON, 仅供参考
   debug [name]                                    显示一些 debug 信息, 仅供参考
   gen [...]                                       同等于 add, 但只显示 JSON 内容, 不创建文件, 测试使用
   genc [name]                                     显示用于客户端部分 JSON, 仅供参考
   no-auto-tls [...]                               同等于 add, 但禁止自动配置 TLS, 可用于 *TLS 相关协议
   xapi [...]                                      同等于 v2ray api, 但 API 后端使用当前运行的 V2Ray 服务

其他:
   bbr                                             启用 BBR, 如果支持
   bin [...]                                       运行 V2Ray 命令, 例如: v2ray bin help
   api, convert, tls, run, uuid  [...]             兼容 V2Ray 命令
   h, help                                         显示此帮助界面

谨慎使用 del, ddel, 此选项会直接删除配置; 无需确认
反馈问题) https://github.com/233boy/v2ray/issues
文档(doc) https://233boy.com/v2ray/v2ray-script/
```
