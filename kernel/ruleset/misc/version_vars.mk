######################### -*- Mode: Makefile-Gmake -*- ########################
## version_vars.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 18:07:50 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Sat Sep 30 09:34:00 2006
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 13
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : This file looks at the top level kernel Makefile, and
##                    extracts the components of the version string. It
##                    uses the kernel Makefile itself, so it takes into
##                    account everything the kernel Makefile itrself pays
##                    attention to. 
## 
## arch-tag: 024a242d-938b-4391-a812-e5ab9099a8a6
## 
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##
###############################################################################


ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
  localversion_files := $(wildcard localversion*)


  # VERSION =$(shell grep -E '^VERSION +=' Makefile 2>/dev/null | \
  #  sed -e 's/[^0-9]*\([0-9]*\)/\1/')
  # PATCHLEVEL =$(shell grep -E '^PATCHLEVEL +=' Makefile 2>/dev/null | \
  #  sed -e 's/[^0-9]*\([0-9]*\)/\1/')
  # SUBLEVEL =$(shell grep -E '^SUBLEVEL +=' Makefile 2>/dev/null | \
  #  sed -e 's/[^0-9]*\([0-9]*\)/\1/')
  # EXTRA_VERSION =$(shell grep -E '^EXTRAVERSION +=' Makefile 2>/dev/null | \
  #  sed -e 's/EXTRAVERSION *= *\([^ \t]*\)/\1/')
  # LOCALVERSION = $(subst $(space),, $(shell cat /dev/null $(localversion_files)) \
  #                  $(CONFIG_LOCALVERSION))

  # Could have used :=, but some patches do seem to patch the
  # Makefile. perhaps deferring the rule makes that better
  $(eval $(which_debdir))
  ifneq ($(strip $(KERNEL_ARCH)),)
    K_ARG="ARCH=$(KERNEL_ARCH)"
  endif
  # Call this twice; if there are problems in the .config, kbuild rewrites 
  # .config, and the informational message messes up the variable.
  TEST         :=$(shell $(MAKE) $(CROSS_ARG) $(K_ARG) --no-print-directory \
                   -sf $(DEBDIR)/ruleset/kernel_version.mk debian_VERSION)
  VERSION      :=$(shell $(MAKE) $(CROSS_ARG) $(K_ARG) --no-print-directory \
                   -sf $(DEBDIR)/ruleset/kernel_version.mk debian_VERSION)
  PATCHLEVEL   :=$(shell $(MAKE) $(CROSS_ARG) $(K_ARG) --no-print-directory \
                   -sf $(DEBDIR)/ruleset/kernel_version.mk debian_PATCHLEVEL)
  SUBLEVEL     :=$(shell $(MAKE) $(CROSS_ARG) $(K_ARG) --no-print-directory \
                   -sf $(DEBDIR)/ruleset/kernel_version.mk debian_SUBLEVEL)
  EXTRA_VERSION:=$(shell $(MAKE) $(CROSS_ARG) $(K_ARG) --no-print-directory \
                   -sf $(DEBDIR)/ruleset/kernel_version.mk debian_EXTRAVERSION)
  LOCALVERSION :=$(shell $(MAKE) $(CROSS_ARG) $(K_ARG) --no-print-directory \
                   -sf $(DEBDIR)/ruleset/kernel_version.mk debian_LOCALVERSION)
  # If the variable TEST did get a mesage about .config beng written, pass it on.
  ifneq ($(strip $(TEST)),$(strip $(VERSION)))
    $(warn configuration written to .config)
  endif
else
  ifeq ($(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu)
    VERSION        =$(shell grep '^REVISION=' conf/newvers.sh |                   \
      sed -e 's/[^0-9]*\([0-9]\)\..*/\1/')
    PATCHLEVEL =$(shell grep '^REVISION=' conf/newvers.sh |                       \
     sed -e 's/[^0-9]*[0-9]*\.\([0-9]*\)[^0-9]*/\1/')
    SUBLEVEL =0
    EXTRA_VERSION =$(shell grep '^RELEASE=' conf/newvers.sh |                     \
     sed -e 's/[^0-9]*\([0-9]*\)[^0-9]*/\1/')
    LOCALVERSION = $(subst $(space),,                                             \
       $(shell cat /dev/null $(localversion_files)) $(CONFIG_LOCALVERSION))
  endif
endif

KERNELRELEASE = $(shell if [ -f .kernelrelease ]; then          \
                           cat .kernelrelease 2> /dev/null ;    \
                        else                                    \
                          echo "";                              \
                       fi;)  

HAVE_NEW_MODLIB =$(shell grep -E '\(INSTALL_MOD_PATH\)' Makefile 2>/dev/null )

ifneq ($(strip $(EXTRA_VERSION)),)
HAS_ILLEGAL_EXTRA_VERSION =$(shell                                                  \
    perl -e '$$i="$(EXTRA_VERSION)"; $$i !~ m/^[a-z\.\-\+][a-z\d\.\-\+]*$$/o && print YES;')
  ifneq ($(strip $(HAS_ILLEGAL_EXTRA_VERSION)),)
    $(error Error: The EXTRAVERSION may only contain lowercase alphanumerics        \
 and  the  characters  - +  . The current value is: $(EXTRA_VERSION). Aborting.)
  endif
endif

EXTRAVERSION =$(strip $(EXTRA_VERSION))
ifneq ($(strip $(APPEND_TO_VERSION)),)
iatv := $(strip $(APPEND_TO_VERSION))
EXTRAV_ARG := EXTRAVERSION=${EXTRA_VERSION}${iatv}
else
iatv :=
EXTRAV_ARG :=
endif

UTS_RELEASE_HEADER=$(shell if [ -f include/linux/utsrelease.h ]; then \
	                       echo include/linux/utsrelease.h;       \
	                   else                                       \
                               echo include/linux/version.h ; \
	                   fi)
UTS_RELEASE_VERSION=$(shell if [ -f $(UTS_RELEASE_HEADER) ]; then                        \
                 grep 'define UTS_RELEASE' $(UTS_RELEASE_HEADER) |                       \
                 perl -nle  'm/^\s*\#define\s+UTS_RELEASE\s+("?)(\S+)\1/g && print $$2;';\
                 else echo "" ;                                                          \
                 fi)

version = $(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)$(iatv)$(LOCALVERSION)

# Bug out if the version number id not all lowercase
lc_version = $(shell echo $(version) | tr A-Z a-z)
ifneq ($(strip $(version)),$(strip $(lc_version)))
  ifeq ($(strip $(IGNORE_UPPERCASE_VERSION)),)
    $(error Error. The version number \
       $(strip $(version))            \
 VERSION=[$(VERSION)], PATCHLEVEL=[$(PATCHLEVEL)], \
 SUBLEVEL=[$(SUBLEVEL)], EXTRAVERSION=[$(EXTRAVERSION)], \
 iatv=[$(iatv)], LOCALVERSION=[$(LOCALVERSION)],   \
 UTS_RELEASE_VERSION=[$(UTS_RELEASE_VERSION)],      \
 KERNELRELEASE=[$(KERNELRELEASE)].                 \
 is not all lowercase. Since the version ends up in the package\
 name of the kernel image package, this is a Debian policy \
 violation, and the packaging system shall refuse to package \
 the image. )
  else
    $(warn Error. The version number $(strip $(version)) is not all \
 lowercase. Since the version ends up in the package name of the \
 kernel image package, this is a Debian policy violation, and \
 the packaging system shall refuse to package the image. Lower -casing version.)

    version := $(strip $(lc_version))
  endif
endif


AM_OFFICIAL := $(shell if [ -f debian/official ]; then echo YES; fi )

# See if we are being run in the kernel directory
ifeq ($(DEB_HOST_GNU_SYSTEM), linux-gnu)
  define check_kernel_dir
  IN_KERNEL_DIR := $(shell if test -d drivers && test -d kernel && test -d fs && test \
                                   -d include/linux ; then                            \
                                      echo YES;                                       \
                           fi )
  endef
else
  ifeq ($(DEB_HOST_GNU_SYSTEM), kfreebsd-gnu)
    define check_kernel_dir
    IN_KERNEL_DIR := $(shell if test -d dev && test -d kern && test -d fs &&          \
                             test -d i386/include ; then echo YES; fi)
    endef
  endif
endif

define check_kernel_headers
IN_KERNEL_HEADERS=$(shell if [ -f $(INT_STEM)-headers.revision ]; then                \
                               cat $(INT_STEM)-headers.revision;                      \
                            else echo "" ;                                            \
                            fi)
endef


$(eval $(check_kernel_dir))
$(eval $(check_kernel_headers))
ifeq ($(strip $(IN_KERNEL_DIR)),)
ifneq ($(strip $(IN_KERNEL_HEADERS)),)
version=$(UTS_RELEASE_VERSION)
debian =$(IN_KERNEL_HEADERS)
endif
endif

#Local variables:
#mode: makefile
#End:
