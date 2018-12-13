#pragma once
/*
 * WARNING: Auto-generated file from env.h.in
 *
 * This file is part of the libCEC(R) library.
 *
 * libCEC(R) is Copyright (C) 2011-2015 Pulse-Eight Limited.  All rights reserved.
 * libCEC(R) is an original work, containing original code.
 *
 * libCEC(R) is a trademark of Pulse-Eight Limited.
 *
 * This program is dual-licensed; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 *
 * Alternatively, you can license this library under a commercial license,
 * please contact Pulse-Eight Licensing for more information.
 *
 * For more information contact:
 * Pulse-Eight Licensing       <license@pulse-eight.com>
 *     http://www.pulse-eight.com/
 *     http://www.pulse-eight.net/
 */

#include "cectypes.h"
#include "p8-platform/os.h"

#ifdef UNUSED
#elif defined(__GNUC__)
#define UNUSED(x) UNUSED_ ## x __attribute__((unused))
#elif defined(__LCLINT__)
#define UNUSED(x) /**/ x
#else
#define UNUSED(x) x
#endif

#ifndef ON
#define ON (1)
#endif

/* Define to 1 for xrandr support */
/* #undef HAVE_RANDR */

/* Define to 1 if <sys/file.h> should be included for flock() */
#define HAVE_SYS_FILE_HEADER 1

/* Define to 1 for flock() support */
#define HAVE_FLOCK 1

/* Define to 1 for udev support */
/* #undef HAVE_LIBUDEV */

/* Define to 1 for Pulse-Eight CEC Adapter support */
#define HAVE_P8_USB ON

/* Define to 1 for Pulse-Eight CEC Adapter detection support */
/* #undef HAVE_P8_USB_DETECT */

/* Define to 1 for Raspberry Pi support */
/* #undef HAVE_RPI_API */

/* Define to 1 for TDA995x support */
/* #undef HAVE_TDA995X_API */

/* Define to 1 for Exynos support */
/* #undef HAVE_EXYNOS_API */

/* Define to 1 for AOCEC support */
/* #undef HAVE_AOCEC_API */

/* Define to 1 for nVidia EDID parsing support (on selected models) */
/* #undef HAVE_NVIDIA_EDID_PARSER */

/* Define to 1 for DRM EDID parsing support */
#define HAVE_DRM_EDID_PARSER ON

/* Define to 1 for Python support */
/* #undef HAVE_PYTHON */

/* information about how libCEC was compiled */
#define LIB_INFO ("git revision: libcec-4.0.3, compiled on Sun Nov 18 19:16:43 UTC 2018 by dkennett@Ysera.local on Darwin 18.2.0 (x86_64), features: P8_USB, DRM")
