# 服务器代理服务

如果你觉得本项目对你有用,而且你也恰巧有这方面的需求,你也可以选择通过我的购买链接赞助我  
- [搬瓦工GIA服务器](https://bandwagonhost.com/aff.php?aff=41846)  - - - 仅推荐购买GIA套餐 - - -   

如果你希望购买一些现成的代理服务,可选择下述代理服务
- [搬瓦工官方机场](https://justmysocks.net/members/aff.php?aff=16884)  

# X-UI 文档目录

- [功能介绍](#功能介绍)  
- [一键安装](#一键安装)  
- [效果预览](#效果预览)  
- [快捷方式](#快捷方式)  
- [变更记录](#变更记录)

# 功能介绍

- 系统状态监控
- 支持单端口多用户、多协议，网页可视化操作
- 支持的协议：vmess、vless、trojan、shadowsocks、shadowsocks 2022、dokodemo-door、socks、http
- 支持配置更多传输配置：http、tcp、ws、grpc、kcp、quic
- 流量统计，限制流量，限制到期时间，一键重置与设备监控
- 可自定义 xray 配置模板
- 支持 https 访问面板（自备域名 + ssl 证书）
- 支持一键SSL证书申请且自动续签
- Telegram bot通知、控制功能
- 更多高级配置项，详见面板 

# 一键安装
在安装前请确保你的系统支持`bash`环境,且系统网络正常  

&#x26A1;从原版升级也可使用该命令，数据不会丢失&#x26A1;

```
bash <(curl -Ls https://raw.githubusercontent.com/uszhen/x-ui/master/install.sh)
```    
For English Users,please use the following command to install English supported version:  
```
bash <(curl -Ls https://raw.githubusercontent.com/uszhen/x-ui/master/install_en.sh)
```
如需安装指定的版本,可以在上述命令中指定版本号,如指定版本为`0.3.4.4`,安装命令如下：    
```
bash <(curl -Ls https://raw.githubusercontent.com/uszhen/x-ui/master/install.sh) 0.3.4.4   
```

# 效果预览  
`面板使用`:  
<details>
<summary><b>点击查看效果预览</b></summary>  
  
![image](https://user-images.githubusercontent.com/38254177/180629631-f76a05c8-ecf0-4685-bbc7-a7058747d213.png)  
![image](https://user-images.githubusercontent.com/38254177/180629662-b7a325fc-1ebb-47c9-992c-1e7c758a326b.png)


 </details>  
 
`Bot使用`:  
<details>
<summary><b>点击查看效果预览</b></summary>  
  
![image](https://user-images.githubusercontent.com/38254177/178551055-893936b7-b75f-4ee8-a773-eee7c6f43f51.png)  
 
</details>  

`流量提醒`:  
<details>
<summary><b>点击查看效果预览</b></summary> 
  
![image](https://user-images.githubusercontent.com/38254177/180039760-dc987a30-e21c-49a3-8e03-19666566a822.png)

</details>  

`SSH提醒`:  
<details>
<summary><b>点击查看效果预览</b></summary> 
  
![image](https://user-images.githubusercontent.com/38254177/180040129-2ec1a7c0-abd3-41dc-aab0-8cd22415c943.png)

</details>  

`限额提醒`:  
<details>
<summary><b>点击查看效果预览</b></summary> 
  
![image](https://user-images.githubusercontent.com/38254177/180040521-af6e9ef8-d7e5-44e8-834e-25b3b8e3e1b5.png)

</details>  

`到期提醒`:  
<details>
<summary><b>点击查看效果预览</b></summary> 
  
![image](https://user-images.githubusercontent.com/38254177/180041690-90ca4b1f-3a2d-470b-bc0c-eca9261a739a.png)

</details>  

`登录提醒`:  
<details>
<summary><b>点击查看效果预览</b></summary> 
  
![image](https://user-images.githubusercontent.com/38254177/180040913-b8bf2fe1-6fc1-43ab-a683-ae23db1866b2.png)  
![image](https://user-images.githubusercontent.com/38254177/180041179-a5f4cd52-a1ba-4aa9-abb2-b94e36722385.png)

</details>  

`用户速览`:  
<details>
<summary><b>点击查看效果预览</b></summary> 
  
![image](https://user-images.githubusercontent.com/38254177/230761101-20431dd7-5bce-489e-9139-0ceb9ab9a2dc.png)

</details>  

`用户查询`:  
<details>
<summary><b>点击查看效果预览</b></summary> 
  
![image](https://user-images.githubusercontent.com/38254177/230761252-c283c02d-82a4-46ce-a180-dfab4048180d.png)

</details>  



# 快捷方式
安装成功后，通过键入`x-ui`进入控制选项菜单，目前菜单内容：
```
  x-ui 面板管理脚本
  0. 退出脚本
————————————————
  1. 安装 x-ui
  2. 更新 x-ui
  3. 卸载 x-ui
————————————————
  4. 重置用户名密码
  5. 重置面板设置
  6. 设置面板端口
  7. 查看当前面板设置
————————————————
  8. 启动 x-ui
  9. 停止 x-ui
  10. 重启 x-ui
  11. 查看 x-ui 状态
  12. 查看 x-ui 日志
————————————————
  13. 设置 x-ui 开机自启
  14. 取消 x-ui 开机自启
————————————————
  15. 一键安装 bbr (最新内核)
  16. 一键申请SSL证书(acme申请)
 
面板状态: 已运行
是否开机自启: 是
xray 状态: 运行

请输入选择 [0-16]: 
```
# 配置要求  
## 内存  
- 128MB minimal/256MB+ recommend  
## OS  
- CentOS 7+
- Ubuntu 16+
- Debian 8+




