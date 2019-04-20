#	$OpenBSD: Makefile,v 1.52 2019/04/09 22:32:48 patrick Exp $

BROKEN-sparc64=	Error: the specified option is not accepted in ISB at operand 1 -- isb sy

FLAVORS=	aarch64 arm
FLAVOR?=	arm

COMMENT=	U-Boot firmware
VERSION=	2019.01
REVISION=	5
DISTNAME=	u-boot-${VERSION}
PKGNAME=	u-boot-${FLAVOR}-${VERSION:S/-//}
FULLPKGNAME=	${PKGNAME}
CATEGORIES=	sysutils
HOMEPAGE=	http://www.denx.de/wiki/U-Boot
MAINTAINER=	Jonathan Gray <jsg@openbsd.org>

# GPLv2
PERMIT_PACKAGE_CDROM=	Yes

MASTER_SITES=	ftp://ftp.denx.de/pub/u-boot/
EXTRACT_SUFX=	.tar.bz2
PKG_ARCH=	*

BUILD_DEPENDS=	devel/bison \
		devel/dtc \
		devel/swig \
		textproc/gsed

MODULES=	lang/python
MODPY_RUNDEP=	No

MODPY_ADJ_FILES=\
	arch/arm/mach-rockchip/make_fit_atf.py

MAKE_ENV=	KBUILD_VERBOSE=1 \
		PYTHON="${MODPY_BIN}"

.if "${FLAVOR}" == "aarch64"
BUILD_DEPENDS+=	devel/arm-none-eabi/gcc-linaro,aarch64 \
		devel/py-elftools \
		sysutils/arm-trusted-firmware
MAKE_ENV+=	CROSS_COMPILE="aarch64-none-elf-"
RK3399_BL31=	"${LOCALBASE}/share/arm-trusted-firmware/rk3399-bl31.elf"
SUNXI_BL31=	"${LOCALBASE}/share/arm-trusted-firmware/sun50i_a64-bl31.bin"
.elif "${FLAVOR}" == "arm"
BUILD_DEPENDS+=	devel/arm-none-eabi/gcc-linaro
MAKE_ENV+=	CROSS_COMPILE="arm-none-eabi-"
.endif

USE_GMAKE=	Yes
NO_TEST=	Yes

.if "${FLAVOR}" == "aarch64"
SUNXI64=\
	a64-olinuxino \
	bananapi_m64 \
	nanopi_a64 \
	nanopi_neo2 \
	orangepi_pc2 \
	orangepi_prime \
	orangepi_win \
	pine64-lts \
	pine64_plus \
	pinebook \
	sopine_baseboard
BOARDS=\
	firefly-rk3399 \
	mvebu_espressobin-88f3720 \
	mvebu_mcbin-88f8040 \
	qemu_arm64 \
	rpi_3
.elif "${FLAVOR}" == "arm"
OMAP=\
	omap4_panda \
	am335x_boneblack \
	am335x_evm
SUNXI64=
SUNXI=\
	A10-OLinuXino-Lime \
	A10s-OLinuXino-M \
	A20-OLinuXino-Lime \
	A20-OLinuXino-Lime2 \
	A20-OLinuXino-Lime2-eMMC \
	A20-OLinuXino_MICRO \
	Bananapi \
	Bananapi_m2m \
	bananapi_m2_zero \
	Bananapro \
	CHIP \
	Cubieboard \
	Cubieboard2 \
	Cubieboard4 \
	Cubietruck \
	Lamobo_R1 \
	Linksprite_pcDuino \
	Linksprite_pcDuino3 \
	Linksprite_pcDuino3_Nano \
	nanopi_neo \
	Orangepi \
	Orangepi_mini \
	orangepi_2 \
	orangepi_lite \
	orangepi_one \
	orangepi_pc \
	orangepi_pc_plus \
	orangepi_plus \
	orangepi_plus2e \
	orangepi_zero \
	Sinovoip_BPI_M2_Plus
IMX=\
	cm_fx6 \
	mx6cuboxi \
	mx6qsabrelite \
	nitrogen6q \
	novena \
	udoo \
	usbarmory \
	wandboard
BOARDS=\
	${OMAP} \
	${SUNXI} \
	${IMX} \
	clearfog \
	qemu_arm \
	rpi_2 \
	rpi_3_32b \
	tinker-rk3288 \
	turris_omnia \
	vexpress_ca15_tc2
.endif

FILES=\
	MLO \
	SPL \
	u-boot \
	u-boot.img \
	u-boot.bin \
	u-boot-sunxi-with-spl.bin \
	u-boot.imx \
	u-boot-spl.kwb \
	u-boot-with-spl.bin \
	u-boot.itb \
	idbspl.img \
	spl/sunxi-spl.bin \

pre-build:
.for f in ${MODPY_ADJ_FILES}
	${MODPY_BIN_ADJ} ${WRKSRC}/${f}
.endfor

do-build:
.for BOARD in ${BOARDS}
	cd ${WRKSRC} && \
	    mkdir -p build/${BOARD} && \
	    ${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${MAKE_FLAGS} \
	        O="build/${BOARD}" \
	        -f ${MAKE_FILE} "${BOARD}"_defconfig && \
	    ${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${MAKE_FLAGS} \
	        O="build/${BOARD}" \
	        -f ${MAKE_FILE} ${ALL_TARGET}
.if "${BOARD}" == "tinker-rk3288"
	cd ${WRKSRC}/build/${BOARD} && \
	    tools/mkimage -n rk3288 -T rksd -d spl/u-boot-spl-dtb.bin \
	        u-boot-with-spl.bin && \
	    cat u-boot-dtb.bin >> u-boot-with-spl.bin
.endif
.if "${BOARD}" == "firefly-rk3399"
	cd ${WRKSRC}/build/${BOARD} && \
	    ln -s ${RK3399_BL31} bl31.elf && \
	    ${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${MAKE_FLAGS} \
	        O="build/${BOARD}" \
	        -f ${MAKE_FILE} u-boot.itb && \
	    tools/mkimage -n rk3399 -T rksd -d spl/u-boot-spl.bin idbspl.img
.endif
.endfor
.for BOARD in ${SUNXI64}
	cd ${WRKSRC} && \
	    mkdir -p build/${BOARD} && \
	    ${SETENV} ${MAKE_ENV} BL31=${SUNXI_BL31} ${MAKE_PROGRAM} \
	        ${MAKE_FLAGS} O="build/${BOARD}" \
	        -f ${MAKE_FILE} "${BOARD}"_defconfig && \
	    ${SETENV} ${MAKE_ENV} BL31=${SUNXI_BL31} ${MAKE_PROGRAM} \
	        ${MAKE_FLAGS} O="build/${BOARD}" \
	        -f ${MAKE_FILE} ${ALL_TARGET}
	if [[ -f ${WRKSRC}/build/${BOARD}/spl/sunxi-spl.bin && \
	      -f ${WRKSRC}/build/${BOARD}/u-boot.itb ]]; then \
		cd ${WRKSRC}/build/${BOARD} && \
		    cat spl/sunxi-spl.bin u-boot.itb > u-boot-sunxi-with-spl.bin ; \
	fi
.endfor

do-install:
	${INSTALL_DATA_DIR} ${PREFIX}/share/u-boot
.for BOARD in ${BOARDS} ${SUNXI64}
	${INSTALL_DATA_DIR} ${PREFIX}/share/u-boot/${BOARD}
	-cd ${WRKSRC}/build/${BOARD} && \
	    cp ${FILES} ${PREFIX}/share/u-boot/${BOARD}/
.endfor

.include <bsd.port.mk>
