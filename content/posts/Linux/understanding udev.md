---
title: understanding udev
created: 2025-05-22 14:53:55
---

udev是一个用户空间应用程序，用来监听（内核通过`netlink`套接字发出的）设备事件。用户可以通过udev在发生某事件时执行自定义脚本。

## udev事件

udev事件也被称为uevent，由Linux内核发出，用来向用户通知设备状态变化情况。

有一个简单的方式感受一下udev事件：

```shell
udevadm monitor
```

现在重新插拔下鼠标或键盘，你就能看到许多udev事件。

以下是一个键盘连接事件：

<details open>
<summary>
</summary>

```shell
KERNEL[1611.009806] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2 (usb)
KERNEL[1611.057741] change   /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2 (usb)
KERNEL[1611.057760] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.0 (usb)
KERNEL[1611.073746] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.0/0003:31E3:1322.000C (hid)
KERNEL[1611.073774] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.0/usbmisc/hiddev3 (usbmisc)
KERNEL[1611.073793] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.0/0003:31E3:1322.000C/hidraw/hidraw4 (hidraw)
KERNEL[1611.073808] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.0/0003:31E3:1322.000C (hid)
KERNEL[1611.073820] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.0 (usb)
KERNEL[1611.073833] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1 (usb)
KERNEL[1611.091783] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D (hid)
KERNEL[1611.091802] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/wakeup/wakeup67 (wakeup)
KERNEL[1611.091851] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28 (input)
KERNEL[1611.142102] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::numlock (leds)
KERNEL[1611.155046] change   /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::numlock (leds)
KERNEL[1611.155063] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::capslock (leds)
KERNEL[1611.165045] change   /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::capslock (leds)
KERNEL[1611.165058] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::scrolllock (leds)
KERNEL[1611.175014] change   /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::scrolllock (leds)
KERNEL[1611.175027] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::compose (leds)
KERNEL[1611.175032] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::kana (leds)
KERNEL[1611.193039] change   /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::kana (leds)
KERNEL[1611.193061] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/event3 (input)
KERNEL[1611.193092] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/hidraw/hidraw5 (hidraw)
KERNEL[1611.193134] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D (hid)
KERNEL[1611.193145] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1 (usb)
KERNEL[1611.193162] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.2 (usb)
KERNEL[1611.208738] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.2/0003:31E3:1322.000E (hid)
KERNEL[1611.208776] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.2/usbmisc/hiddev4 (usbmisc)
KERNEL[1611.208797] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.2/0003:31E3:1322.000E/hidraw/hidraw6 (hidraw)
KERNEL[1611.208834] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.2/0003:31E3:1322.000E (hid)
KERNEL[1611.208841] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.2 (usb)
KERNEL[1611.208856] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3 (usb)
KERNEL[1611.226746] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F (hid)
KERNEL[1611.226794] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input29 (input)
KERNEL[1611.277102] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input29/event4 (input)
KERNEL[1611.277125] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input30 (input)
KERNEL[1611.277150] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input30/event5 (input)
KERNEL[1611.277163] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input31 (input)
KERNEL[1611.277175] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input31/event6 (input)
KERNEL[1611.277193] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input31/mouse1 (input)
KERNEL[1611.277211] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/hidraw/hidraw7 (hidraw)
KERNEL[1611.277227] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F (hid)
KERNEL[1611.277235] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3 (usb)
KERNEL[1611.277248] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.4 (usb)
KERNEL[1611.292725] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.4/0003:31E3:1322.0010 (hid)
KERNEL[1611.292751] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.4/usbmisc/hiddev5 (usbmisc)
KERNEL[1611.292765] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.4/0003:31E3:1322.0010/hidraw/hidraw8 (hidraw)
KERNEL[1611.292779] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.4/0003:31E3:1322.0010 (hid)
KERNEL[1611.292786] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.4 (usb)
KERNEL[1611.292797] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2 (usb)
UDEV  [1611.300431] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2 (usb)
UDEV  [1611.302098] change   /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2 (usb)
UDEV  [1611.303512] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.0 (usb)
UDEV  [1611.303647] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/wakeup/wakeup67 (wakeup)
UDEV  [1611.303960] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1 (usb)
UDEV  [1611.304464] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.4 (usb)
UDEV  [1611.304480] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.2 (usb)
UDEV  [1611.304596] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3 (usb)
UDEV  [1611.304711] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.0/0003:31E3:1322.000C (hid)
UDEV  [1611.305024] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.0/usbmisc/hiddev3 (usbmisc)
UDEV  [1611.305226] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D (hid)
UDEV  [1611.305753] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.2/0003:31E3:1322.000E (hid)
UDEV  [1611.305773] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.4/0003:31E3:1322.0010 (hid)
UDEV  [1611.305858] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F (hid)
UDEV  [1611.306035] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.4/usbmisc/hiddev5 (usbmisc)
UDEV  [1611.306282] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.2/usbmisc/hiddev4 (usbmisc)
UDEV  [1611.306739] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28 (input)
UDEV  [1611.307662] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input29 (input)
UDEV  [1611.308171] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input30 (input)
UDEV  [1611.308208] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input31 (input)
UDEV  [1611.308222] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::scrolllock (leds)
UDEV  [1611.308415] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::numlock (leds)
UDEV  [1611.308430] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::capslock (leds)
UDEV  [1611.308561] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::compose (leds)
UDEV  [1611.308578] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.0/0003:31E3:1322.000C/hidraw/hidraw4 (hidraw)
UDEV  [1611.308619] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/hidraw/hidraw5 (hidraw)
UDEV  [1611.308744] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::kana (leds)
UDEV  [1611.309145] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.2/0003:31E3:1322.000E/hidraw/hidraw6 (hidraw)
UDEV  [1611.309550] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.4/0003:31E3:1322.0010/hidraw/hidraw8 (hidraw)
UDEV  [1611.309640] change   /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::scrolllock (leds)
UDEV  [1611.309745] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.0/0003:31E3:1322.000C (hid)
UDEV  [1611.309761] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/hidraw/hidraw7 (hidraw)
UDEV  [1611.309954] change   /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::numlock (leds)
UDEV  [1611.310298] change   /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::capslock (leds)
UDEV  [1611.310311] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.2/0003:31E3:1322.000E (hid)
UDEV  [1611.310552] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input31/mouse1 (input)
UDEV  [1611.310583] change   /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/input28::kana (leds)
UDEV  [1611.311037] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.4/0003:31E3:1322.0010 (hid)
UDEV  [1611.311174] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.0 (usb)
UDEV  [1611.311739] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.2 (usb)
UDEV  [1611.312291] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.4 (usb)
UDEV  [1611.325747] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input31/event6 (input)
UDEV  [1611.325775] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input29/event4 (input)
UDEV  [1611.326236] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F/input/input30/event5 (input)
UDEV  [1611.326520] add      /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D/input/input28/event3 (input)
UDEV  [1611.327331] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3/0003:31E3:1322.000F (hid)
UDEV  [1611.327582] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:31E3:1322.000D (hid)
UDEV  [1611.328595] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.3 (usb)
UDEV  [1611.328916] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2/1-3.2:1.1 (usb)
UDEV  [1611.331054] bind     /devices/pci0000:00/0000:00:02.1/0000:02:00.0/0000:03:0c.0/0000:0d:00.0/usb1/1-3/1-3.2 (usb)
```
</details>

可以看到事件分别由内核和udev发出。udev工作流程大概如下：

- 内核通过`netlink`套接字发送事件
- `udev`接收内核发出的事件并进行处理
- `udev`处理完毕，发送事件给监听者

这边我们主要关注一下事件的动作（action字段），uevent提供有如下事件类型：

- add：设备添加
- bind：驱动程序绑定到设备
- change：设备已更改（如更换sd读卡器中的卡片或设备属性发生变化）
- remove：设备已移除
- unbind：驱动程序与设备解绑
- offline：设备已下线（休眠）
- online：设备已上线（唤醒）
- move：移至新设备或重命名

因此，我们可以利用这些事件，创建udev规则，以在这些事件发生时执行自定义命令。

## 自定义hook

在`/etc/udev/rules.d/`下创建一个名为`99-hook.rules`的文件，并填入以下内容：

```shell
SUBSYSTEM=="usb", ACTION=="add", RUN+="/tmp/udev-hook.sh"
```

这条规则表示：当usb设备被添加时，执行`/tmp/udev-hook.sh`脚本。

然后在创建`/tmp/udev-hook.sh`，填入以下内容：

```shell
#!/bin/bash
echo hello >/tmp/udev-info.txt
```

这个脚本如果被正确执行，会往`/tmp/udev-info.txt`写入`hello`。然后使用`chmod`为这个脚本添加可执行权限。

```shell
sudo chmod +x /tmp/udev-hook.sh
```

最后别忘记应用udev规则：

```shell
sudo udevadm control --reload
```

然后当我们插入usb设备（插入U盘、鼠标、键盘等）时，可以看到脚本被执行：

```shell
❯ cat /tmp/udev-info.txt
hello
```

另外，为了实现精细控制，可以利用一些额外的属性来对设备进行筛选，如idVendor和idProduct等。这些信息可以通过`lsusb -v`命令进行查看。一种更为准确的方式（包括准确的键值对名称）是通过：

```shell
udevadm info -a -n /dev/input/by-id/<此处替换为你的USB设备id>
```

以下是Wacom CTL-472数位板的详细信息。

<details open>
<summary>
</summary>

```shell
  looking at parent device '/devices/pci0000:00/0000:00:08.3/0000:11:00.0/usb7/7-1/7-1.4':
    KERNELS=="7-1.4"
    SUBSYSTEMS=="usb"
    DRIVERS=="usb"
    ATTRS{authorized}=="1"
    ATTRS{avoid_reset_quirk}=="0"
    ATTRS{bConfigurationValue}=="1"
    ATTRS{bDeviceClass}=="00"
    ATTRS{bDeviceProtocol}=="00"
    ATTRS{bDeviceSubClass}=="00"
    ATTRS{bMaxPacketSize0}=="64"
    ATTRS{bMaxPower}=="498mA"
    ATTRS{bNumConfigurations}=="1"
    ATTRS{bNumInterfaces}==" 2"
    ATTRS{bcdDevice}=="0100"
    ATTRS{bmAttributes}=="80"
    ATTRS{busnum}=="7"
    ATTRS{configuration}==""
    ATTRS{devnum}=="3"
    ATTRS{devpath}=="1.4"
    ATTRS{idProduct}=="037a"
    ATTRS{idVendor}=="056a"
    ATTRS{ltm_capable}=="no"
    ATTRS{manufacturer}=="Wacom Co.,Ltd."
    ATTRS{maxchild}=="0"
    ATTRS{power/active_duration}=="9386663"
    ATTRS{power/autosuspend}=="2"
    ATTRS{power/autosuspend_delay_ms}=="2000"
    ATTRS{power/connected_duration}=="9386663"
    ATTRS{power/control}=="on"
    ATTRS{power/level}=="on"
    ATTRS{power/persist}=="1"
    ATTRS{power/runtime_active_time}=="9386517"
    ATTRS{power/runtime_status}=="active"
    ATTRS{power/runtime_suspended_time}=="0"
    ATTRS{product}=="CTL-472"
    ATTRS{quirks}=="0x0"
    ATTRS{removable}=="unknown"
    ATTRS{remove}=="(not readable)"
    ATTRS{rx_lanes}=="1"
    ATTRS{serial}=="2FA00L1039531"
    ATTRS{speed}=="12"
    ATTRS{tx_lanes}=="1"
    ATTRS{urbnum}=="1912"
    ATTRS{version}==" 2.00"
```
</details>

一般来说，可以通过以下三个属性逐级筛选规则对应的设备：

- idVendor：设备的品牌/厂商名称，此处就是0x056a，对应Wacom
- idProduct：设备的型号，对应同一型号的所有设备，此处为0x037a，对应CTL-472
- serial：设备的序列号，任何设备应该都有唯一的序列号，因此最为严格

将上面的规则修改为：

```shell
SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ACTION=="add", RUN+="/tmp/udev-hook.sh"
```

然后应用规则：

```shell
sudo udevadm control --reload
```

再remove掉之前生成的测试文件：

```shell
sudo rm /tmp/udev-info.txt
```

现在重新插拔下之前填入的idVendor所对应的设备，可以看到`/tmp/udev-info.txt`被重新生成了，表示命令执行成功。与此同时，添加其他品牌的usb设备并不会触发该hook。

## 权限控制

udev还能够控制用户访问设备的权限。如果你有一个wooting键盘，你会发现在官网有如下的workaround，以允许在linux上写入固件：

```shell
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", TAG+="uaccess"
SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", TAG+="uaccess"
```

对比一下`lsusb`列出的usb设备信息，可以发现idVendor和键盘匹配：

```shell
❯ lsusb | grep -i wooting
Bus 001 Device 009: ID 31e3:1322 Wooting Wooting 60HE+
```

因此这条规则也就可以翻译为：对于Wooting设备，赋予用户访问usb和hid的权限。

## libudev

udev另外还带有一个`libudev`库，提供了一些API以允许用户获取设备属性。以下是一个使用libudev获取idVendor的示例：

```cpp
#include <libudev.h>
#include <iostream>

int main() {
  udev* udev = udev_new();
  udev_device* device = udev_device_new_from_syspath(
    udev,
    "/sys/devices/pci0000:00/0000:00:08.3/0000:11:00.0/usb7/7-1/7-1.4/7-1.4:1.0/0003:056A:037A.0034/input/input60/mouse0"
  );
  udev_device* parent =
    udev_device_get_parent_with_subsystem_devtype(device, "usb", "usb_device");
  if (parent) {
    const char* vendor = udev_device_get_sysattr_value(parent, "idVendor");
    std::cout << "device vendor: " << vendor << std::endl;
  }
  udev_device_unref(device);
  udev_unref(udev);
}
```

这输出；
```shell
device vendor: 056a
```

其中`syspath`可以通过以下命令获取：

```shell
udevadm info -q path -n /dev/input/by-id/usb-Wacom_Co._Ltd._CTL-472_2FA00L1039531-mouse
```

libudev还能枚举设备列表，详情可见[man page](https://man.archlinux.org/man/libudev.3.en)。不过直接使用`libudev`的情形较少，一般推荐使用`systemd/sd-device.h`替代。

## 参考资料

[1] https://opensource.com/article/18/11/udev

[2] https://sid-project.github.io/context.html

