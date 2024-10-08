include $(TOPDIR)/rules.mk

PKG_NAME:=tun2socks
PKG_VERSION:=2.5.2
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/xjasonlyu/tun2socks.git
PKG_SOURCE_VERSION:=c8c08cfeea01e38af3ae1b93329d3be8659fff46

## Keep original maintainer here
# PKG_MAINTAINER:=Konstantine Shevlakov <shevlako@132lan.ru>
PKG_MAINTAINER:=Alexander Ryazanov <alryaz@alryaz.com>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG=github.com/xjasonlyu/tun2socks

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

GO_MOD_ARGS:=
GO_PKG_BUILD_VARS+= GO111MODULE=on

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=tun to socks proxy redirector written on golang
  URL:=https://github.com/xjasonlyu/tun2socks
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle +kmod-tun
endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/lib/netifd/proto/
	$(INSTALL_BIN) ./files/tun2socks.sh $(1)/lib/netifd/proto/
endef

$(eval $(call GoBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))