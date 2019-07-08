# A64 additions to OpenBSD u-boot port
####  Please, do not use kernel with these patches on a board without proper cooling!
#### I'm not responsible for any damage.
#### Please, review the code before use.

---
#### Description
This repository contains A64 additions from FreeBSD overlays that seem to work nicely with OpenBSD u-boot port.

Enabling:
1. getting/setting CPU speed
1. getting/setting CPU voltage
1. reading e-fuses values (required by temp. sensor)
1. calibrated CPU/GPU temperature readings

#### FreeBSD vs this repository
The only thing added to overlay is:
```
clock-names = "cpu";
```
for `sun50i-a64-opp.dtso`.

#### Prerequisites
1. make sure `/usr/ports` are updated
1. make sure `/usr/ports/sysutils/u-boot` can be built for `FLAVOR=aarch64`

#### Building
1. set correct `FLAVOR`
```
export FLAVOR=aarch64
```
1. clean up previous u-boot installation, from `/usr/ports/sysutils/u-boot` excute:
```
doas make uninstall
make clean=all
```
1. execute `./prepare.sh` from repository root
1. `cd /usr/ports/sysutils/u-boot`
1. build: `make`
1. install `doas make install`
