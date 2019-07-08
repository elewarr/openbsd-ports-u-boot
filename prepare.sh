#!/usr/bin/env ksh

FLAVOR=aarch64
UBOOT_OVERLAYS_PATH=$(pwd)/overlays

cd /usr/ports/sysutils/u-boot
WRKDIST=$(make show=WRKDIST)
make clean=all
make patch
cd -

WRKDIST_OVERLAYS_PATH=${WRKDIST}/arch/arm/dts/overlays/arm64

if [ -z "${WRKDIST}" ]; then
	echo "no WRKDIST"
	exit 1
fi

cd ${WRKDIST}

rm -rf ${WRKDIST_OVERLAYS_PATH}
mkdir -p ${WRKDIST_OVERLAYS_PATH}

for F in $(find ${UBOOT_OVERLAYS_PATH} -name "sun50i-a64*.dtso"); do
	tail -n+3 ${F} > ${WRKDIST_OVERLAYS_PATH}/$(basename ${F}.updated)
	echo "#include <overlays/arm64/$(basename ${F}).updated>" >> ${WRKDIST}/arch/arm/dts/sun50i-a64.dtsi
done
