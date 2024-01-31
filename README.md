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
1. enabling PWM
1. enabling battery state readings
1. enabling thermal zones support

#### Prerequisites
1. make sure `/usr/ports` are updated
1. make sure `/usr/ports/sysutils/u-boot` can be built for `FLAVOR=aarch64`

#### Building
1. execute `./prepare.sh` from repository root
