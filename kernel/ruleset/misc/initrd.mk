######################### -*- Mode: Makefile-Gmake -*- ########################
## initrd.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
## Created On       : Mon Oct 31 18:09:11 2005
## Created On Node  : glaurung.internal.golden-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Wed Dec  7 09:53:43 2005
## Last Machine Used: glaurung.internal.golden-gryphon.com
## Update Count     : 4
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : This snippet uses hard coded version based heuristics to
##            	      determine which set of tools would be viable for providing
##            	      an initrd or initramdisk for the kernel being built, if
##            	      initrd's are selected by the user as desired.
## 
## arch-tag: 106aee24-dd25-4a7a-a323-47a4c1bcabcd
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


#
# INITRD tools.
#
initrdcmd:=
initrddep:=

ifneq ($(strip $(INITRD)),)
  ifneq ($(strip $(INITRD_CMD)),)
    initrdcmd := $(strip $(INITRD_CMD))
  else
    ifneq ($(shell if [ $(VERSION)  -lt  2 ]; then                               \
                        echo old;                                                \
                 elif [ $(VERSION)  -eq  2 ] && [ $(PATCHLEVEL) -lt 6 ]; then    \
                        echo old;                                                \
                 elif [ $(VERSION)  -eq  2 ] && [ $(PATCHLEVEL) -eq 6 ] &&       \
                      [ $(SUBLEVEL) -lt  8 ]; then                               \
                        echo old;                                                \
                 fi),)
      initrdcmd := mkinitrd
    else
      ifneq ($(shell if [ $(VERSION)  -eq  2 ] && [ $(PATCHLEVEL) -eq 6  ] &&    \
                        [ $(SUBLEVEL) -ge  8 ] && [ $(SUBLEVEL)   -le 12 ]; then \
                          echo old;                                              \
                   fi),)
        initrdcmd := mkinitrd mkinitrd.yaird
      else
        initrdcmd := mkinitrd.yaird mkinitramfs
      endif
    endif
  endif
  ifneq (,$(findstring initrd-tools, $(initrdcmd)))
    initrddep := initrd-tools (>= 0.1.84)
  endif
  #setup initrd dependencies
  ifneq (,$(findstring yaird,$(initrdcmd)))
    ifneq (,$(strip $(initrddep)))
      initrddep := $(initrddep) | yaird (>= 0.1.11)
    else
      initrddep := yaird (>= 0.0.11-8)
    endif
  endif
  ifneq (,$(findstring mkinitramfs,$(initrdcmd)))
    ifneq (,$(strip $(initrddep)))
      initrddep := $(initrddep) | initramfs-tools (>= 0.35)
    else
      initrddep := initramfs-tools (>= 0.35)
    endif
  endif
  # By this time initrddep is not empty, so we can dispense with the emptiness test
  ifneq (,$(findstring yaird,$(initrdcmd)))
    initrddep := $(initrddep) | linux-initramfs-tool
  else
    ifneq (,$(findstring mkinitramfs,$(initrdcmd)))
      initrddep := $(initrddep) | linux-initramfs-tool
    endif
  endif
  initrddep := $(initrddep), # There is a blank here
else
  initrdcmd :=
  initrddep :=
endif

#Local variables:
#mode: makefile
#End:
