'use strict';
'require form';
'require network';
'require tools.widgets as widgets';

network.registerPatternVirtual(/^t2s-.+$/);

return network.registerProtocol('tun2socks', {
	getI18n: function() {
		return _('tun2socks');
	},

	getIfname: function() {
		return this._ubus('l3_device') || 't2s-%s'.format(this.sid);
	},

	getOpkgPackage: function() {
		return 'tun2socks';
	},

	isFloating: function() {
		return true;
	},

	isVirtual: function() {
		return true;
	},

	getDevices: function() {
		return null;
	},

	containsDevice: function(ifname) {
		return (network.getIfnameOf(ifname) == this.getIfname());
	},

	renderFormOptions: function(s) {
		var dev = this.getL3Device() || this.getDevice(), o;
		var bufParamWrapper = function(o_) {
			o_.editable = true;
			o_.optional = true;
			o_.datatype = 'uinteger';
			for (var i = 0; i < 10; i++) {
				o_.value(2 ** i);
			}
		};
		
		o = s.taboption('general', form.Value, 'proxy', _('Proxy'), _('Use this proxy [protocol://]host[:port].'));
		o.optional = false;
		o.placeholder = 'socks5://127.0.0.1:1080';

		o = s.taboption('general', form.DynamicList, 'addresses', _('IP Addresses'), _('IP addresses of the tun2soxks interface.'));
                o.datatype = 'ipaddr';
                o.optional = true;

		o = s.taboption('general', widgets.NetworkSelect, 'interface', _('Bind interface'), _('Bind the tunnel to this network interface (optional).'));
		o.optional = true;

		o = s.taboption('advanced', form.Value, 'mtu', _('Override MTU'), _('Set device maximum transmission unit (MTU).'));
		o.optional = true;
		o.placeholder = dev ? (dev.getMTU() || '1500') : '1500';
		o.datatype = 'range(68, 9200)';

		o = s.taboption('advanced', form.Flag, 'tcp_auto_tuning', _('TCP Auto-Tuning'), _('Enable TCP receive buffer auto-tuning.'));
		o.optional = true;

		o = s.taboption('advanced', form.Value, 'tcp_rcvbuf', _('TCP Receive Buffer Size'), _('Set TCP receive buffer size for netstack.'));
		bufParamWrapper(o);

		o = s.taboption('advanced', form.Value, 'tcp_sndbuf', _('TCP Send Buffer Size'), _('Set TCP send buffer size for netstack.'));
		bufParamWrapper(o);

		o = s.taboption('advanced', form.Value, 'udp_timeout', _('UDP Timeout'), _('Set timeout for each UDP session.'));
		o.optional = true;
		o.placeholder = '30';
		o.datatype = 'uinteger';

		o = s.taboption('advanced', form.Value, 'fwmark', _('Firewall Mark'), _('Set firewall MARK (Linux only).'));
		o.optional = true;
		o.datatype = 'uinteger';

		o = s.taboption('advanced', form.ListValue, 'loglevel', _('Log Level'), _('Logging level of the tun2socks tunnel.'));
		o.optional = true;
		o.value('debug', _('Debug'));
		o.value('info', _('Info'));
		o.value('warning', _('Warning'));
		o.value('error', _('Error'));
		o.value('silent', _('Silent'));
		o.default = 'info';

		o = s.taboption('advanced', form.Value, 'restapi', _('REST API'), _('HTTP statistic server listen address and port.'));
		o.optional = true;
		o.placeholder = '127.0.0.1:8080';

		o = s.taboption('advanced', form.Value, 'tun_pre_up', _('Pre-Up Command'), _('Execute a command before tunnel device setup.'));
		o.optional = true;

		o = s.taboption('advanced', form.Value, 'tun_post_up', _('Post-Up Command'), _('Execute a command after tunnel device setup.'));
		o.optional = true;
	}
});
