### Build core-image-minimal for the I.MX95

### 1. Set up build

```bash
MACHINE=qemux86-64 source iwg61m-setup-release.sh -b qemux86-64-imx95
```

### 2. Build image in Bitbake
```bash
bitbake core-image-minimal
```

#### Fix error related to wap-supplicant
Link: https://community.nxp.com/t5/i-MX-Processors/Qemu-image-of-kernel-6-1/td-p/1711750

```bash
## Add defconfig for NXP Wi-Fi version
## SRC_URI:prepend:imx-nxp-bsp = "file://defconfig"

## do_configure:prepend:imx-nxp-bsp () {
## # Overwrite defconfig with NXP Wi-Fi version
## install -m 0755 ${WORKDIR}/defconfig wpa_supplicant/defconfig
```

### 3. Run Qemu
```bash
# Review path
runqemu qemux86-64 tmp/deploy/images/qemux86-64/core-image-minimal-qemux86-64.rootfs.qemuboot.conf nographic
```

### 4. Login

The user is: **root**

The password is empty