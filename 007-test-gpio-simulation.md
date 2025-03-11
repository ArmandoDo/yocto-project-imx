# Test GPIO simulation in the core-image-minimal

Test GPIO simulation using the GPIO modules available in the core-image-minimal

## Enable the GPIO modules

#### 1. Enable the modules in the bitbake-core Kernel

```bash
bitbake -c menuconfig virtual/kernel
```

Enable the GPIO support module. Go to `CAN Device Drivers` and enable it as module:

```
-> Device Drivers  
  -> GPIO Support [*]
    -> Virtual GPIO drivers
      -> GPIO simulator module  <M>
```

Save the `.config` file and load the changes.

#### 2. Compile the Kernel and the image
Compile the Bitbake Kernel and the image with the new configuration:

```shell
bitbake -c compile -f virtual/kernel
bitbake core-image-minimal
```

## Test using the gpio-mockup library

The GPIO Testing Driver (gpio-mockup) provides a way to create simulated
GPIO chips for testing purposes. The lines exposed by these chips can be
accessed using the standard GPIO character device interface as well as
manipulated using the dedicated debugfs directory structure.

```shell
modinfo gpio-mockup
###
# filename:       /lib/modules/6.6.35-yocto-standard/kernel/drivers/gpio/gpio-mockup.ko
# license:        GPL v2
# description:    GPIO Testing driver
# author:         Bartosz Golaszewski <brgl@bgdev.pl>
# depends:        
# name:           gpio_mockup
# vermagic:       6.6.35-yocto-standard SMP preempt mod_unload 
# parm:           gpio_mockup_ranges:array of int
# parm:           gpio_mockup_named_lines:bool
```

#### 1. Launch the core-image-minimal image.

Run the image in Qemu

```shell
runqemu qemux86-64 nographic slirp qemuparams="-m 2048"
```

Now log in with the `root` user.

#### 2. Enable the gpio-mockup module and test the creation of pines.

Run the next command to enable the module and create a gpiochip.

```shell
modprobe gpio-mockup gpio_mockup_ranges=-1,4
### Verify the gpiochip
gpioinfo 
  # gpiochip0 - 4 lines:
  # line   0:       unnamed                 input
  # line   1:       unnamed                 input
  # line   2:       unnamed                 input
  # line   3:       unnamed                 input
```

#### 3. Set up the status of the pin.
```shell
gpioset --toggle 10s --consumer testing_pin_3  --chip gpiochip0 3=1
```

#### 4. Verify the status of the chip and the pin.
Verify status of the chip:
```shell
gpioinfo --chip gpiochip0
  # gpiochip0 - 4 lines:
  # line   0:       unnamed                 input
  # line   1:       unnamed                 input
  # line   2:       unnamed                 input
  # line   3:       unnamed                 output consumer=testing_pin_3
```

Verify status of the pin in the Kernel:
```shell
cat /sys/kernel/debug/gpio
  # gpiochip0: GPIOs 512-519, parent: platform/gpio-mockup.0, gpio-mockup-A:
  ### Before 10 seconds
  # gpio-515 (                    |testing_pin_3       ) out hi

  ### After 10 seconds
  # gpio-515 (                    |testing_pin_3       ) out lo
```

**Note:** There is a limitation with the gpio-mockup interface, when `gpioset` 
is running, the resource will be busy, and it `gpioget` the message 
`gpioget: unable to request lines: Device or resource busy`. The gpio-mockup
debug is only available in the Kernel `/sys/kernel/debug/gpio`.



## Test using the gpio-sim library

The configfs GPIO Simulator (gpio-sim) provides a way to create simulated GPIO chips
for testing purposes. The lines exposed by these chips can be accessed using the
standard GPIO character device interface as well as manipulated using sysfs attributes.

```
modinfo gpio-sim
filename:       /lib/modules/6.6.35-yocto-standard/kernel/drivers/gpio/gpio-sim.ko
license:        GPL
description:    GPIO Simulator Module
author:         Bartosz Golaszewski <brgl@bgdev.pl
name:           gpio_sim
vermagic:       6.6.35-yocto-standard SMP preempt mod_unload
```

#### 1. Launch the core-image-minimal image.

Run the image in Qemu

```shell
runqemu qemux86-64 nographic slirp qemuparams="-m 2048"
```

Now log in with the `root` user.

#### 2. Enable the gpio-sim module
Run the next command to enable the module and create a gpiochip.

```shell
modprobe gpio-sim
```

#### 2. Create and set up a new GPIO device
Set up new device:
```shell
# Create gpio folder
mkdir /sys/kernel/config/gpio-sim/gpio-device
mkdir /sys/kernel/config/gpio-sim/gpio-device/gpio-bank0
# Set up number of pines
echo 4 > /sys/kernel/config/gpio-sim/gpio-device/gpio-bank0/num_lines
# Rename pines
# Pin 0
mkdir /sys/kernel/config/gpio-sim/gpio-device/gpio-bank0/line0
echo "pin_0" > /sys/kernel/config/gpio-sim/gpio-device/gpio-bank0/line0/name
# Pin 1
mkdir /sys/kernel/config/gpio-sim/gpio-device/gpio-bank0/line1
echo "pin_1" > /sys/kernel/config/gpio-sim/gpio-device/gpio-bank0/line1/name
# Pin 2
mkdir /sys/kernel/config/gpio-sim/gpio-device/gpio-bank0/line2
echo "pin_2" > /sys/kernel/config/gpio-sim/gpio-device/gpio-bank0/line2/name
# Pin 3
mkdir /sys/kernel/config/gpio-sim/gpio-device/gpio-bank0/line3
echo "pin_3" > /sys/kernel/config/gpio-sim/gpio-device/gpio-bank0/line3/name
```

Enable the device and get the info of the device:
```shell
# Enable device
echo 1 > /sys/kernel/config/gpio-sim/gpio-device/live
# Get info of chip
gpioinfo
  # gpiochip0 - 4 lines:
  # line   0:       "pin_0"                 input
  # line   1:       "pin_1"                 input
  # line   2:       "pin_2"                 input
  # line   3:       "pin_3"                 input
```

#### 3. Set up the status of the pin.
```shell
gpioset --toggle 10s --consumer testing_pin_3  --chip gpiochip0 3=1
```

#### 4. Verify the status of the chip and the pin.
Verify status of the chip:
```shell
gpioinfo --chip gpiochip0
  # gpiochip0 - 4 lines:
  # line   0:       "pin_0"                 input
  # line   1:       "pin_1"                 input
  # line   2:       "pin_2"                 input
  # line   3:       "pin_3"                 output consumer="testing_pin_3"
```

Verify status of the pin in the Kernel:
```shell
cat /sys/kernel/debug/gpio
  # gpiochip0: GPIOs 512-515, parent: platform/gpio-sim.0, gpio-sim.0-node0, can sleep:
  #  gpio-512 (pin_0               )
  #  gpio-513 (pin_1               )
  #  gpio-514 (pin_2               )
  #  gpio-515 (pin_3               |testing_pin_3       ) out hi

  ### After 10 seconds
  # gpiochip0: GPIOs 512-515, parent: platform/gpio-sim.0, gpio-sim.0-node0, can sleep:
  #  gpio-512 (pin_0               )
  #  gpio-513 (pin_1               )
  #  gpio-514 (pin_2               )
  #  gpio-515 (pin_3               |testing_pin_3       ) out lo
```
