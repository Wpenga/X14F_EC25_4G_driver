#include <linux/build-salt.h>
#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

BUILD_SALT;

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(.gnu.linkonce.this_module) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

#ifdef CONFIG_RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif

static const struct modversion_info ____versions[]
__used __section(__versions) = {
	{ 0x8218e0cf, "module_layout" },
	{ 0x117078c1, "param_ops_uint" },
	{ 0x3804937c, "param_ops_long" },
	{ 0x9c765947, "ethtool_op_get_link" },
	{ 0xe0f3219c, "usbnet_tx_timeout" },
	{ 0xee913673, "usbnet_change_mtu" },
	{ 0x849cfd7b, "eth_validate_addr" },
	{ 0xa7b47a30, "usbnet_stop" },
	{ 0x6d35ea1c, "usbnet_open" },
	{ 0x99e6badf, "usb_deregister" },
	{ 0x27935455, "usb_register_driver" },
	{ 0xcbd4898c, "fortify_panic" },
	{ 0xdcb764ad, "memset" },
	{ 0x6cbbfc54, "__arch_copy_to_user" },
	{ 0xa916b694, "strnlen" },
	{ 0x12a4e128, "__arch_copy_from_user" },
	{ 0x3c3fce39, "__local_bh_enable_ip" },
	{ 0xacf60475, "netif_schedule_queue" },
	{ 0xab9c941b, "__alloc_skb" },
	{ 0xfbdfc558, "hrtimer_start_range_ns" },
	{ 0x365acda7, "set_normalized_timespec64" },
	{ 0xa13cab64, "softnet_data" },
	{ 0x907f7057, "consume_skb" },
	{ 0x9c40721b, "netif_receive_skb" },
	{ 0x5e9c7146, "dev_queue_xmit" },
	{ 0x37a0cba, "kfree" },
	{ 0x5f181631, "usbnet_disconnect" },
	{ 0x82072614, "tasklet_kill" },
	{ 0x2d296b16, "unregister_netdev" },
	{ 0xc9ec4e21, "free_percpu" },
	{ 0xe0787b73, "netdev_rx_handler_unregister" },
	{ 0xfc03727f, "kfree_skb" },
	{ 0x9c1e5bf5, "queued_spin_lock_slowpath" },
	{ 0x37793ec0, "cancel_work_sync" },
	{ 0xa0c6befa, "hrtimer_cancel" },
	{ 0x9545af6d, "tasklet_init" },
	{ 0xcad0288, "usbnet_skb_return" },
	{ 0x4f6de69, "netif_rx" },
	{ 0xbdd03add, "eth_type_trans" },
	{ 0x8a894e4d, "skb_dequeue" },
	{ 0x8c413d20, "skb_put" },
	{ 0x574ad7ac, "__netdev_alloc_skb" },
	{ 0xe9cd26d2, "skb_queue_tail" },
	{ 0x37b6d7a, "skb_trim" },
	{ 0xb66dfde4, "skb_pull" },
	{ 0x4e314195, "skb_clone" },
	{ 0xf21e41e7, "netif_rx_ni" },
	{ 0x349cba85, "strchr" },
	{ 0x7c52b546, "arp_create" },
	{ 0xc5850110, "printk" },
	{ 0x6989e1dc, "queue_work_on" },
	{ 0x2d3385d3, "system_wq" },
	{ 0x6e720ff2, "rtnl_unlock" },
	{ 0x4a452ce2, "netdev_rx_handler_register" },
	{ 0xc7a4fbed, "rtnl_lock" },
	{ 0xff1e5d24, "netdev_info" },
	{ 0x9acc32b5, "free_netdev" },
	{ 0xe914e41e, "strcpy" },
	{ 0xec5e091f, "netdev_err" },
	{ 0x2af384ac, "netif_device_attach" },
	{ 0x7ab0dd5e, "register_netdev" },
	{ 0xaf793668, "__alloc_percpu_gfp" },
	{ 0x5e515be6, "ktime_get_ts64" },
	{ 0x1ee7d3cd, "hrtimer_init" },
	{ 0x3c3ff9fd, "sprintf" },
	{ 0x2a09820c, "alloc_etherdev_mqs" },
	{ 0xae79154e, "usbnet_suspend" },
	{ 0x2b216f5f, "usbnet_resume" },
	{ 0xa245c4b2, "usbnet_probe" },
	{ 0x64821234, "usb_string" },
	{ 0x9f771822, "kmem_cache_alloc" },
	{ 0xa6937eb9, "kmalloc_caches" },
	{ 0x79aa04a2, "get_random_bytes" },
	{ 0xda25655b, "_dev_err" },
	{ 0x4829a47e, "memcpy" },
	{ 0x17108c96, "usb_cdc_wdm_register" },
	{ 0xd7ee9e8a, "usbnet_get_endpoints" },
	{ 0x70756722, "usbnet_start_xmit" },
	{ 0x81418194, "eth_commit_mac_addr_change" },
	{ 0xa7dda8b7, "eth_prepare_mac_addr_change" },
	{ 0xc1e2adb0, "usbnet_get_drvinfo" },
	{ 0x656e4a6e, "snprintf" },
	{ 0xff73cb38, "netif_tx_wake_queue" },
	{ 0x38d0239, "netif_carrier_on" },
	{ 0xf538c6cd, "netif_carrier_off" },
	{ 0xdecd0b29, "__stack_chk_fail" },
	{ 0xfaef0ed, "__tasklet_schedule" },
	{ 0x3feea40, "cpumask_next" },
	{ 0x3928efe9, "__per_cpu_offset" },
	{ 0x17de3d5, "nr_cpu_ids" },
	{ 0xa5f7cf37, "__cpu_possible_mask" },
	{ 0xad995dac, "netdev_stats_to_stats64" },
	{ 0xbb33f1fc, "_dev_info" },
	{ 0x20000329, "simple_strtoul" },
	{ 0x84033440, "usb_control_msg" },
	{ 0xc32d1877, "usb_driver_release_interface" },
	{ 0x89cc266f, "usb_autopm_put_interface" },
	{ 0x1a5ff4ff, "__dynamic_dev_dbg" },
	{ 0x7c1d2d63, "usb_autopm_get_interface" },
	{ 0x6657218a, "skb_push" },
	{ 0xe17a4d4a, "__dev_kfree_skb_any" },
};

MODULE_INFO(depends, "usbnet,cdc-wdm");

MODULE_ALIAS("usb:v05C6p9003d*dc*dsc*dp*ic*isc*ip*in04*");
MODULE_ALIAS("usb:v05C6p9215d*dc*dsc*dp*ic*isc*ip*in04*");
MODULE_ALIAS("usb:v2C7Cp0125d*dc*dsc*dp*ic*isc*ip*in04*");
MODULE_ALIAS("usb:v2C7Cp0121d*dc*dsc*dp*ic*isc*ip*in04*");
MODULE_ALIAS("usb:v2C7Cp0191d*dc*dsc*dp*ic*isc*ip*in04*");
MODULE_ALIAS("usb:v2C7Cp0195d*dc*dsc*dp*ic*isc*ip*in04*");
MODULE_ALIAS("usb:v2C7Cp0306d*dc*dsc*dp*ic*isc*ip*in04*");
MODULE_ALIAS("usb:v2C7Cp0512d*dc*dsc*dp*ic*isc*ip*in04*");
MODULE_ALIAS("usb:v2C7Cp0296d*dc*dsc*dp*ic*isc*ip*in04*");
MODULE_ALIAS("usb:v2C7Cp0435d*dc*dsc*dp*ic*isc*ip*in04*");
MODULE_ALIAS("usb:v2C7Cp0620d*dc*dsc*dp*ic*isc*ip*in04*");
MODULE_ALIAS("usb:v2C7Cp0800d*dc*dsc*dp*ic*isc*ip*in04*");

MODULE_INFO(srcversion, "A5F1BE81B3E2952BE5BE5A0");
