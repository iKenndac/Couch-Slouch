#pragma once
/*
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

/**
 * Convert a version number to an uint32_t
 * @param[in] major  Major version number
 * @param[in] minor  Minor version number
 * @param[in] patch  Patch number
 *
 * @return The version number as uint32_t
 */
#define LIBCEC_VERSION_TO_UINT(major, minor, patch)  \
  ((major < 2 || (major == 2 && minor <= 2)) ? \
    (uint32_t) (major << 8)  | (minor << 4) | (patch) : \
    (uint32_t) (major << 16) | (minor << 8) | (patch))

/* new style version numbers, 2.3.0 and later */
#define LIBCEC_UINT_TO_VERSION_MAJOR(x) ((x >> 16) & 0xFF)
#define LIBCEC_UINT_TO_VERSION_MINOR(x) ((x >> 8 ) & 0xFF)
#define LIBCEC_UINT_TO_VERSION_PATCH(x) ((x >> 0 ) & 0xFF)

/* old style version numbers, before 2.3.0 */
#define LIBCEC_UINT_TO_VERSION_MAJOR_OLD(x) ((x >> 8) & 0xFF)
#define LIBCEC_UINT_TO_VERSION_MINOR_OLD(x) ((x >> 4) & 0x0F)
#define LIBCEC_UINT_TO_VERSION_PATCH_OLD(x) ((x >> 0) & 0x0F)

/*!
 * libCEC's major version number
 */
#define CEC_LIB_VERSION_MAJOR        4

/*!
 * libCEC's major version number as string
 */
#define CEC_LIB_VERSION_MAJOR_STR    "4"

/*!
 * libCEC's minor version number
 */
#define CEC_LIB_VERSION_MINOR        0

/* current libCEC version number */
#define _LIBCEC_VERSION_CURRENT \
        LIBCEC_VERSION_TO_UINT(4, 0, 4)
 
