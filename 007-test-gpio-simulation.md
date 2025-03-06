# Test GPIO simulation in the core-image-minimal

Test GPIO simulation using the GPIO modules available in the core-image-minimal


## Test using the gpio-mockup library

The GPIO Testing Driver (gpio-mockup) provides a way to create simulated
GPIO chips for testing purposes. The lines exposed by these chips can be
accessed using the standard GPIO character device interface as well as
manipulated using the dedicated debugfs directory structure.

```
modinfo gpio-mockup
filename:       /lib/modules/6.6.35-yocto-standard/kernel/drivers/gpio/gpio-mockup.ko
license:        GPL v2
description:    GPIO Testing driver
author:         Bartosz Golaszewski <brgl@bgdev.pl>
depends:        
name:           gpio_mockup
vermagic:       6.6.35-yocto-standard SMP preempt mod_unload 
parm:           gpio_mockup_ranges:array of int
parm:           gpio_mockup_named_lines:bool
```

#### 1. Set up the bitbake-core kernel

```bash
bitbake -c menuconfig virtual/kernel
```

Enable the drivers:

Enable the GPIO support module. Go to `CAN Device Drivers` and enable it as module:

```
-> Device Drivers  
  -> GPIO Support [*]
    -> Virtual GPIO drivers
      -> GPIO simulator module  <M>
```

Save the `.config` file and load the changes. After that, compile Bitbake kernel with
the new configuration:

```bash
bitbake -c compile -f virtual/kernel
```

#### 2. Launch the core-image-minimal image.

Run the image in Qemu

```bash
runqemu qemux86-64 nographic slirp qemuparams="-m 2048"
```

Now log in with the `root` user.

#### 3. Enable the gpio-mockup module and test the creation of pines.

Run the next command to enable the module and create a gpiochip.

```bash
modprobe gpio-mockup gpio_mockup_ranges=-1,8
### Verify the gpiochip
gpioinfo 
    gpiochip0 - 8 lines:
    line   0:       unnamed                 input
    line   1:       unnamed                 input
    line   2:       unnamed                 input
    line   3:       unnamed                 input
    line   4:       unnamed                 input
    line   5:       unnamed                 input
    line   6:       unnamed                 input
    line   7:       unnamed                 input
```

#### 4. Set up the status of the pin.
```bash
gpioset --toggle 10s --consumer testing_pin_3  --chip gpiochip0 3=1
```

#### 5. Verify the status of the chip.
```bash
### Verify status of the chip
gpioinfo --chip gpiochip0
    gpiochip0 - 8 lines:
    line   0:       unnamed                 input
    line   1:       unnamed                 input
    line   2:       unnamed                 input
    line   3:       unnamed                 output consumer=testing_pin_3
    line   4:       unnamed                 input
    line   5:       unnamed                 input
    line   6:       unnamed                 input
    line   7:       unnamed                 input

### Verify status of the pin
cat /sys/kernel/debug/gpio
gpiochip0: GPIOs 512-519, parent: platform/gpio-mockup.0, gpio-mockup-A:
 gpio-515 (                    |testing_pin_3       ) out hi
### After 10 seconds
 gpio-515 (                    |testing_pin_3       ) out lo
```

**Note:** There is a limitation with the gpio-mockup interface, when `gpioset` 
is running, the resource will be busy, and it `gpioget` the message 
`gpioget: unable to request lines: Device or resource busy`. The gpio-mockup
debug is only available in the Kernel `/sys/kernel/debug/gpio`.