# Installing DevSwitch DEB Package

## Prerequisites
```bash
sudo apt-get update
sudo apt-get install dpkg-dev
```

## Build the package
```bash
cd packages/deb
dpkg-deb --build devswitch_0.1.0-1
```

## Install
```bash
sudo dpkg -i devswitch_0.1.0-1.deb
```

## Verify installation
```bash
devswitch --version
devswitch --help
```

## Start using
```bash
devswitch create work --template corporate
devswitch list
devswitch apply work
```
