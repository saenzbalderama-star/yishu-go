# 永久分享（零成本方案）

朋友要访问你电脑上的易数，难点只有一个：**免费隧道的地址会变**。

解决办法是加一层「固定入口」——朋友永远访问同一个地址，那个页面自动跳到你当前
的隧道地址。地址变了，你跑一条命令同步即可，朋友完全不用改。

## 原理

```
朋友收藏的固定地址（永久不变）
   ↓ 读取 address.txt
自动跳转到 → 你当前的 cpolar 隧道地址（随时在变）
```

## 需要的东西

一个免费的静态托管，用来放那个跳转页。三选一（都要注册，都免费）：

| 服务 | 得到的固定地址 | 说明 |
|---|---|---|
| GitHub Pages | `你的用户名.github.io/仓库名` | 最稳，推荐 |
| Cloudflare Pages | `xxx.pages.dev` | 国内访问相对稳定 |
| Vercel | `xxx.vercel.app` | 部署最快 |

下面的步骤以 **GitHub Pages** 为例。

## 配置步骤（只需做一次）

### 1. 建仓库

在 GitHub 新建一个公开仓库（比如 `yishu-go`），把本目录下的两个文件放进去：

```bash
cp -r share-redirect /tmp/yishu-go && cd /tmp/yishu-go
git init && git remote add origin git@github.com:你的用户名/yishu-go.git
git add . && git commit -m "初始化固定入口" && git push -u origin main
```

### 2. 开启 Pages

仓库 → **Settings → Pages** → Source 选 `main` 分支、根目录 `/` → Save。
等一两分钟，就会得到固定地址，形如：

```
https://你的用户名.github.io/yishu-go
```

**这个地址就是发给朋友的**，一辈子不用变。

### 3. 让脚本能推送

把 `share-redirect` 目录放在能 push 到那个仓库的地方，最简单的做法是
直接在项目里 git 子模块或独立仓库初始化：

```bash
cd share-redirect
git init && git remote add origin git@github.com:你的用户名/yishu-go.git
```

## 日常使用

### 开隧道（你会得到一个随机地址）

```bash
cpolar http 8002 > /tmp/cpolar.log 2>&1 &
```

> 注意：一定要在你**自己的终端**里跑，别关窗口。
> 电脑关机或终端关闭，隧道就没了，朋友会看到「站长没开电脑」的提示页。

### 同步地址（隧道起来后跑一次）

```bash
./share-redirect/update-current-url.sh
```

它会把当前地址写进 `address.txt` 并自动推送。朋友刷新固定入口就会跳到新地址。

想更省事，可以把这两步串起来：

```bash
cpolar http 8002 > /tmp/cpolar.log 2>&1 &
sleep 10 && ./share-redirect/update-current-url.sh
```

## 另一种零成本思路：IPv6 直连（更快，但要调路由器）

你家宽带**有公网 IPv6**（已验证，无公网 IPv4）。可以注册 [dynv6](https://dynv6.com)
拿一个免费域名（形如 `yishu.dynv6.net`），再跑 DDNS 脚本把本机 IPv6 更新上去，
配合路由器放行 8002 端口，朋友就能**直连**你的电脑——不经过任何中转，速度最快。

代价是需要在光猫/路由器里放行 IPv6 入站，不同运营商做法不一样，得自己试。
跳转页方案虽然多一次跳转，但零配置、一定能成，建议先用它。

## 二维码（可选）

固定入口配好后，把那个永久地址生成二维码贴出来，朋友扫码即可，
连打字都省了。
