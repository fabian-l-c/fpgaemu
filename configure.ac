#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([fpgaemu],[1.0],[fabian.c at ufsc.br])
AC_CONFIG_SRCDIR([fpgaemu.c])

AM_INIT_AUTOMAKE


# Checks for programs.
AC_PROG_CC
AX_PTHREAD()
PKG_CHECK_MODULES([GTK3], [gtk+-3.0])

GHDL_BIN=ghdl
AC_ARG_WITH(ghdl,
[  --with-ghdl=PATH          Use GHDL in PATH], [
  GHDL_BIN=$withval
], )
AC_SUBST(GHDL_BIN)

# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([stdlib.h string.h])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_CONFIG_FILES([Makefile])

AC_OUTPUT
