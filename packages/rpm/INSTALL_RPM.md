# Installing DevSwitch RPM Package

## Prerequisites
```bash
# RHEL/CentOS/Fedora
sudo dnf install rpm-build rpmdevtools

# Or for older systems
sudo yum install rpm-build rpmdevtools
```

## Build the package
```bash
cd packages/rpm
rpmbuild --define '_topdir $(pwd)' -bb SPECS/devswitch.spec
```

## Install
```bash
sudo rpm -i RPMS/x86_64/devswitch-0.1.0-1.*.rpm
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
