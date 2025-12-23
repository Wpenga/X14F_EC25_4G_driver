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
	.arch = MODULE_ARCH_INIT,
};

#ifdef CONFIG_RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif

static const struct modversion_info ____versions[]
__used __section(__versions) = {
	{ 0x8218e0cf, "module_layout" },
	{ 0xa6937eb9, "kmalloc_caches" },
	{ 0x94d439fa, "usb_get_from_anchor" },
	{ 0xeb989fe3, "usb_kill_urb" },
	{ 0x7c1d2d63, "usb_autopm_get_interface" },
	{ 0x409bcb62, "mutex_unlock" },
	{ 0xcdf316d1, "usb_unlink_urb" },
	{ 0x15ba50a6, "jiffies" },
	{ 0xd9a5ea54, "__init_waitqueue_head" },
	{ 0x85941fe3, "usb_autopm_put_interface_async" },
	{ 0x84033440, "usb_control_msg" },
	{ 0xe0afea74, "tty_insert_flip_string_fixed_flag" },
	{ 0x2ab7989d, "mutex_lock" },
	{ 0xda25655b, "_dev_err" },
	{ 0xc6cbbc89, "capable" },
	{ 0x8bf71d9a, "usb_submit_urb" },
	{ 0x9f771822, "kmem_cache_alloc" },
	{ 0xa861814e, "usb_autopm_get_interface_async" },
	{ 0x6a5cb5ee, "__get_free_pages" },
	{ 0x9c1e5bf5, "queued_spin_lock_slowpath" },
	{ 0xdecd0b29, "__stack_chk_fail" },
	{ 0x1a5ff4ff, "__dynamic_dev_dbg" },
	{ 0x4302d0eb, "free_pages" },
	{ 0x6a86931b, "usb_autopm_get_interface_no_resume" },
	{ 0x409873e3, "tty_termios_baud_rate" },
	{ 0x37a0cba, "kfree" },
	{ 0x4829a47e, "memcpy" },
	{ 0x94a65ba8, "tty_flip_buffer_push" },
	{ 0x6ebe366f, "ktime_get_mono_fast_ns" },
	{ 0x77a744e8, "usb_serial_port_softint" },
	{ 0x299d243a, "usb_free_urb" },
	{ 0x89cc266f, "usb_autopm_put_interface" },
	{ 0xdaaa0dbe, "usb_anchor_urb" },
	{ 0x46f8f905, "usb_alloc_urb" },
};

MODULE_INFO(depends, "usbserial");


MODULE_INFO(srcversion, "A19738BF0914C3827FEA72D");
