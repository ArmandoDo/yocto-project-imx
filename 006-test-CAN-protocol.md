## Test CAN protocol in core-image-minimal

Test the CAN protocol using 2 terminal sessions.

### 1. Set up the bitbake-core kernel

```bash
bitbake -c menuconfig virtual/kernel
```

Enable the CAN bus system support. Go to `CAN Device Drivers` and enable it:

```
-> Device Drivers  
  -> Network device support  
    -> CAN Device Drivers  <*>
      -> Raw CAN Protocol                 <*>
      -> Broadcast Manager CAN Protocol   <*>
      -> CAN Gateway/Router               <*>
```

Enable the drivers:

```
-> Device Drivers  
   -> Network device support  
      -> CAN Device Drivers
         -> Virtual Local CAN Interface (vcan)        <*>
         -> CAN Device Drivers with Netlink support   [*]
         -> CAN bit-timing calculation                [*]

```

Save the `.conf` file and load the changes. After that, compile Bitbake kernel with
the new configuration:

```bash
bitbake -c compile -f virtual/kernel
```

### 2. Launch the core-image-minimal image with 2 screens

Run the image in Qemu with 2 screens available for the CAN testing.

```bash
runqemu qemux86-64 nographic slirp qemuparams="-m 2048, -serial pty -serial pty"
```

The command provides 2 screens. Take a look at the logs.

```bash
char device redirected to /dev/pts/3
char device redirected to /dev/pts/4
```

Open another 2 terminals and access to the redirections:

```bash
char device redirected to /dev/pts/3
char device redirected to /dev/pts/4
```

First terminal:
```bash
screen /dev/pts/3
```

Second terminal:
```bash
screen /dev/pts/4
```

Now log in with the `root` user.


### 3. Set up the Virtual CAN in the Yocto-Linux virtual environment

```bash
ip link add dev vcan0 type vcan
ip link set vcan0 up

# Show the new virtual CAN
ip link show
```

### 4. Run the CAN testing

Run the dump command in the first terminal:
```bash
candump vcan0
```

Now, run the send command in the second terminal:
```bash
cansend vcan0 123#DEADBEEF
```

Look for the CAN message in the first terminal.