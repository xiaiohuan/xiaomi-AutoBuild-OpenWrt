#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# 复制小米路由配置文件到编译目录
cp -R $GITHUB_WORKSPACE/patchs/4.14/dts/mt7628an_xiaomi_mi-router-3c.dts $GITHUB_WORKSPACE/openwrt/target/linux/ramips/dts/mt7628an_xiaomi_mi-router-3c.dts
cp -R $GITHUB_WORKSPACE/patchs/4.14/mt76x8/mt76x8.mk $GITHUB_WORKSPACE/openwrt/target/linux/ramips/image/mt76x8.mk
cp -R $GITHUB_WORKSPACE/patchs/4.14/mt76x8/02_network $GITHUB_WORKSPACE/openwrt/target/linux/ramips/base-files/etc/board.d/02_network
cp -R $GITHUB_WORKSPACE/patchs/4.14/mt76x8/mac80211.sh $GITHUB_WORKSPACE/openwrt/package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 修改软件包版本为大杂烩-openwrt19.07
sed -i 's/git.openwrt.org\/feed\/packages.git;openwrt-19.07/github.com\/Lienol\/openwrt-packages.git;19.07/g' feeds.conf.default
sed -i 's/git.openwrt.org\/project\/luci.git;openwrt-19.07/github.com\/coolsnowwolf\/luci.git;master/g' feeds.conf.default
# 增加软件包
sed -i '$a src-git helloworld https://github.com/fw876/helloworld.git;master' feeds.conf.default
sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages.git;master' feeds.conf.default
sed -i '$a src-git small https://github.com/kenzok8/small.git;master' feeds.conf.default
sed -i '$a src-git small8 https://github.com/kenzok8/small-package.git;main' feeds.conf.default
# sed -i '$a src-git kiddin9 https://github.com/kiddin9/openwrt-packages.git;master' feeds.conf.default


# 预下载主题
#git clone https://github.com/jerrykuku/luci-theme-argon package/yuos/luci-theme-argon

# 修改默认dnsmasq为dnsmasq-full
sed -i 's/dnsmasq/dnsmasq-full luci/g' include/target.mk

# 修改默认编译LUCI进系统
sed -i 's/ppp-mod-pppoe/ppp-mod-pppoe default-settings luci curl/g' include/target.mk

# 单独拉取软件包
git clone -b Lienol-default-settings https://github.com/yuos-bit/other package/default-settings
git clone -b main --single-branch https://github.com/yuos-bit/other package/yuos
git clone -b master https://github.com/yuos-bit/luci-theme-netgear.git package/yuos/luci-theme-netgear

# 补充包
# 修改默认斐讯K2 wifi驱动为闭源驱动
# sed -i 's/kmod-mt76x2/kmod-mt7612e luci-app-mtwifi/g' target/linux/ramips/image/mt7621.mk

# 设置闭源驱动开机自启
# sed -i '2a ifconfig rai0 up\nifconfig ra0 up\nbrctl addif br-lan rai0\nbrctl addif br-lan ra0' package/base-files/files/etc/rc.local

# 添加4.14内核ACC、shortcut-fe补丁

# 修改feeds里的luci-app-firewall加速开关等源码包
wget -P ./feeds/luci/applications/luci-app-firewall/ https://raw.githubusercontent.com/zxlhhyccc/acc-imq-bbr/master/master/feeds/luci/applications/luci-app-firewall/patches/001-luci-app-firewall-Enable-FullCone-NAT.patch
pushd feeds/luci/applications/luci-app-firewall
patch -p1 < 001-luci-app-firewall-Enable-FullCone-NAT.patch
popd
# 全锥形NAT修复
mkdir package/network/config/firewall/patches
wget -P package/network/config/firewall/patches/ https://github.com/LGA1150/fullconenat-fw3-patch/raw/master/fullconenat.patch
# Patch LuCI
pushd feeds/luci
wget -O- https://github.com/LGA1150/fullconenat-fw3-patch/raw/master/luci.patch | git apply
popd
