#!/usr/bin/env ksh

export FLAVOR=aarch64
UBOOT_OVERLAYS_PATH=$(pwd)/overlays

doas chown -R ${USER}:wsrc /usr/local/ports/pobj

cd /usr/ports/sysutils/u-boot
WRKDIST=$(make show=WRKDIST)
echo ${WRKDIST}
doas make uninstall
make clean=all
make patch
cd -

#exit 0

WRKDIST_DTS_PATH="${WRKDIST}/arch/arm/dts/"
WRKDIST_OVERLAYS_PATH="${WRKDIST}/arch/arm/dts/overlays/"

if [ -z "${WRKDIST}" ]; then
    echo "no WRKDIST"
    exit 1
fi

cd "${WRKDIST}"

rm -rf "${WRKDIST_OVERLAYS_PATH}"
mkdir -p "${WRKDIST_OVERLAYS_PATH}"

for P in $(find "${UBOOT_OVERLAYS_PATH}" -name "*.dtso"); do
    F=$(basename "${P}")
    SUFFIX=${F##*-}
    TARGET_DTS=${WRKDIST_DTS_PATH}${F%-"${SUFFIX}"}.dts
    TARGET_DTSI=${WRKDIST_DTS_PATH}${F%-"${SUFFIX}"}.dtsi
    TARGET=""

    if [ -f "${TARGET_DTS}" ]; then
        TARGET="${TARGET_DTS}"
    elif [ -f "${TARGET_DTSI}" ]; then
        TARGET="${TARGET_DTSI}"
    fi

    if [ ! -z "${TARGET}" ]; then
        cp "${P}" "${WRKDIST_OVERLAYS_PATH}/${F}"
        echo -n "Adding ${F} include to $(basename ${TARGET})... "
        echo "#include <overlays/${F}>" >> ${TARGET}
        echo "OK"
    else
        echo "Couldn't fid target for ${P} overlay!"
    fi
done

cd /usr/ports/sysutils/u-boot
doas make -j2 install
cd -
