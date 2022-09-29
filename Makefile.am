AUTOMAKE_OPTIONS = foreign
bin_SCRIPTS = fpgacompile vfpgacompile
CLEANFILES = $(bin_SCRIPTS)
EXTRA_DIST = fpgacompile.in fpgaemu.c COPYING README examples vfpgacompile.in vfpgaemu.c vexamples
fpgaemudir = $(datadir)/$(PACKAGE)
dist_fpgaemu_DATA = fpgaemu.vhd fpgatest.vhd board.bmp vfpgaemu.v
fpgaemu_DATA = fpgaemu_c.o vfpgaemu.o vfpgaemu.vpi

DEFS = -DBOARD_IMAGE=\"$(fpgaemudir)/board.bmp\"

CFLAGS = $(GTK3_CFLAGS)
CLIBS = $(GTK3_LIBS)

WLCLIBS := $(shell echo $(CLIBS) | sed -e "s/ -/ -Wl,-/g" -e "s/^\(.\)/-Wl,\1/g")

fpgaemu_c.o: fpgaemu.c 
	$(CC) -c -Wall -W -D_REENTRANT -lpthread ${CFLAGS} ${DEFS} $(CLIBS) \
                fpgaemu.c -o fpgaemu_c.o

fpgacompile: fpgacompile.in
	sed -e 's#GHDL_BIN#$(GHDL_BIN)#g' \
		-e 's#DATADIR#$(fpgaemudir)#g' \
		-e 's/WLCLIBS/$(WLCLIBS)/g' \
		fpgacompile.in > $@ 

vfpgaemu.o: vfpgaemu.c 
	iverilog-vpi -c -Wall -W -D_REENTRANT -lpthread ${CFLAGS} ${DEFS} $(CLIBS) \
                vfpgaemu.c

vfpgacompile: vfpgacompile.in
	sed -e 's#DATADIR#$(fpgaemudir)#g' \
		vfpgacompile.in > $@ 
