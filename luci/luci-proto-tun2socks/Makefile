include $(TOPDIR)/rules.mk

LUCI_TITLE:=Protocol support for tun2socks
LUCI_DEPENDS:=+tun2socks
LUCI_PKGARCH:=all

PKG_MAINTAINER:=Alexander Ryazanov <alryaz@alryaz.com>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_PROVIDES:=luci-app-tun2socks

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature