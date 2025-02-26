# The Yocto Project for I.MX95 SMARC SOM

## Set up The Yocto Project for I.MX95

### 1. Set up Repo utility

```bash
./001-set-up-repo-utility
```

### 2. Install needed packages on the server

```bash
./002-install-host-package.sh
```

### 3. Set up git credentials (optional)

Modify the env.tmpl and load the env variables
```bash
cp env.tmpl .env
source .env
./003-set-up-git-credentials.sh
```

### 4. Install The Yocto Project layer for the I.MX95

```bash
./004-install-yocto-project-layer.sh
```

### 5. Run the Poky layer for for the I.MX95
Read the instruccions in `005-build-core-image-minimal.md`

### 6. Test the CAN protocol
Read the instruccions in `006-test-CAN-protocol.md`