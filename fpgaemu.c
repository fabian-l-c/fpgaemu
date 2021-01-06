/*  fpgaemu.c - Graphical interface for the FPGA board emulator.
    Copyright (C) 2020  Fabian L. Cabrera

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

e-mail: fabian.c at ufsc.br
*/

#include <gtk/gtk.h>
#include <gdk-pixbuf/gdk-pixbuf.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>

int init_done=0;
char inmem[4] = {0x00, 0x00,0xF0,0x00};
//inmem[0] - sw7 sw6 sw5 sw4 sw3 sw2 sw1 sw0
//inmem[1] - sw15 sw14 sw13 sw12 sw11 sw10 sw9 sw8
//inmem[2] - key3 key2 key1 key0 X X sw17 sw16
char lastout[12] = {0x00, 0x00, 0x00, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x00};
char outmem[12] = {0xFF, 0xFF, 0xFF, 0x00,0x00, 0x00, 0x00, 0x00,0x00, 0x00, 0x00, 0x00};
//outmem[0] - ledr7 ledr6 ledr5 ledr4 ledr3 ledr2 ledr1 ledr0 
//outmem[1] - ledr15 ledr14 ledr13 ledr12 ledr11 ledr10 ledr9 ledr8 
//outmem[2] - X X X X X X ledr17 ledr16
//outmem[3] - X hex76 hex75 hex74 hex73 hex72 hex71 hex70 
//outmem[4] - X hex66 hex65 hex64 hex63 hex62 hex61 hex60 
//outmem[5] - X hex56 hex55 hex54 hex53 hex52 hex51 hex50 
//outmem[6] - X hex46 hex45 hex44 hex43 hex42 hex41 hex40 
//outmem[7] - X hex36 hex35 hex34 hex33 hex32 hex31 hex30 
//outmem[8] - X hex26 hex25 hex24 hex23 hex22 hex21 hex20 
//outmem[9] - X hex16 hex15 hex14 hex13 hex12 hex11 hex10 
//outmem[10]- X hex06 hex05 hex04 hex03 hex02 hex01 hex00 
int hexpos[8] = {0, 75, 150, 225, 300, 375, 450, 525};
int hexseg[7][5] = {
	{48,116,73,122,0}, // segment a
	{67,120,73,144,1}, // segment b
	{62,148,68,172,1}, // segment c
	{40,170,65,176,0}, // segment d
	{37,148,43,172,1}, // segment e
	{41,120,47,144,1}, // segment f
	{43,143,69,149,0}}; // segment g

char ckmem[2] = {0};
//ckmem[0] - X X X X X X endsim clock
guchar *pixels, *pixelsoff;
int rowstride;
GtkWidget *wleds;
GdkPixbuf *ledspixbufoff;
GdkPixbuf *ledspixbuf;
GtkWidget *wsw[18];

void paint_ledr(int iled, int status)
{
   int i,j,idx;
   int xdelta = (261 * iled)/5;
   if (iled >= 0)
   for (i = 36 + xdelta; i < 49 + xdelta; ++i)
   for (j = 260; j < 280; ++j)
   {
	idx= j*rowstride + 3*i;
	if (pixelsoff[idx] > 85)
		pixelsoff[idx] = 85;
	pixels[idx] = pixelsoff[idx] + status * pixelsoff[idx];
   }
}

void paint_hex(int ihex, int isegm, int status)
{
   int i,j,idx;
   if (isegm < 7)
   for (i = hexseg[isegm][0]+hexpos[ihex]; i < hexseg[isegm][2]+hexpos[ihex]; ++i)
   for (j = hexseg[isegm][1]; j < hexseg[isegm][3]; ++j)
   {
	idx= j*rowstride + 3*(i + hexseg[isegm][4]*(hexseg[isegm][3]-j)/6);
	if (pixelsoff[idx] > 85)
		pixelsoff[idx] = 85;
	pixels[idx] = pixelsoff[idx] + status * pixelsoff[idx];
   }
}

void update_leds(void)
{
   int change = 0;
   int currentbyte, comparebyte,currentbit;
   int i,j;
   for (i = 0; i < 11; ++i)
   {
	currentbyte = outmem[i];	// backup byte value
	currentbit = currentbyte;
	comparebyte = currentbyte ^ lastout[i];
	if (comparebyte != 0)
	{
		for (j = 0; j < 8; ++j)
		{
			if ((comparebyte & 1) == 1)
        		{
				change = 1;
				if (i < 3)
				   paint_ledr(17-8*i-j,2*(currentbit & 1));
				else
				   paint_hex(i-3,j,2*(1-(currentbit & 1)));
			}
			comparebyte >>= 1;
			currentbit >>= 1;
		}
		lastout[i] = currentbyte;
	}
   }
   if (change == 1)
	gtk_image_set_from_pixbuf (GTK_IMAGE(wleds), ledspixbuf);

   ckmem[0] = ckmem[0] ^ 1;
   j=i; //dummy instruction
}

void clear_input(GtkWidget *widget, gpointer   data)
{
   char mask = ~(1 << ((int) data)+4);
   inmem[2] = inmem[2] & mask; 
}

void set_input(GtkWidget *widget, gpointer   data)
{
   char mask = 1 << ((int) data)+4;
   inmem[2] = inmem[2] | mask; 
}

void switch_input(GtkWidget *widget, gpointer   data)
{
   int isw = (int) data;
   int idx = isw / 8; 
   int ipos = isw % 8; 
   char mask = 1 << ipos;
   if (gtk_range_get_value(GTK_RANGE(wsw[isw])) == 0)
	inmem[idx] = inmem[idx] & (~mask);
   else 
	inmem[idx] = inmem[idx] | mask; 
}

void myquit()
{
   ckmem[0] = ckmem[0] | 2;
   gtk_main_quit();
}

void *main_gui(void *arg)
{
   GtkWidget *window;
   GtkWidget *myGrid, *wsep1;
   GtkWidget *wkey3, *wkey2, *wkey1, *wkey0; 
   GtkWidget *lsw[18];
   char strlabel[60];
   int i;

   gtk_init(0, NULL);
   window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
   gtk_window_set_default_size(GTK_WINDOW(window), 1000, 480);

   g_signal_connect(window, "destroy", G_CALLBACK(myquit), NULL);

   myGrid = gtk_grid_new();

   wkey3 = gtk_button_new_with_label("KEY3");
   wkey2 = gtk_button_new_with_label("KEY2");
   wkey1 = gtk_button_new_with_label("KEY1");
   wkey0 = gtk_button_new_with_label("KEY0");
   gtk_widget_set_size_request(wkey3, 80, 80); 
   gtk_widget_set_size_request(wkey2, 80, 80); 
   gtk_widget_set_size_request(wkey1, 80, 80); 
   gtk_widget_set_size_request(wkey0, 80, 80); 

   g_signal_connect (wkey3, "pressed", G_CALLBACK (clear_input),(gpointer) 3);
   g_signal_connect (wkey3, "released", G_CALLBACK (set_input),(gpointer) 3);
   g_signal_connect (wkey2, "pressed", G_CALLBACK (clear_input),(gpointer) 2);
   g_signal_connect (wkey2, "released", G_CALLBACK (set_input),(gpointer) 2);
   g_signal_connect (wkey1, "pressed", G_CALLBACK (clear_input),(gpointer) 1);
   g_signal_connect (wkey1, "released", G_CALLBACK (set_input),(gpointer) 1);
   g_signal_connect (wkey0, "pressed", G_CALLBACK (clear_input),(gpointer) 0);
   g_signal_connect (wkey0, "released", G_CALLBACK (set_input),(gpointer) 0);

   for (i = 0; i < 18; ++i)
   {
	wsw[i] = gtk_scale_new_with_range (GTK_ORIENTATION_VERTICAL,0, 1, 1);
	gtk_widget_set_size_request(wsw[i], 5, 70); 
	gtk_range_set_inverted (GTK_RANGE(wsw[i]),TRUE);
	gtk_scale_set_draw_value (GTK_SCALE(wsw[i]),FALSE);
	gtk_range_set_round_digits (GTK_RANGE(wsw[i]),0);
	gtk_grid_attach(GTK_GRID(myGrid), wsw[i], 18-i, 1, 1, 1);
	g_signal_connect (wsw[i], "value-changed", G_CALLBACK (switch_input),(gpointer) i);

	lsw[i] = gtk_label_new (NULL);
	sprintf(strlabel, "<span size=\"x-small\" stretch=\"extracondensed\">SW%d</span>", i);
	gtk_label_set_markup (GTK_LABEL (lsw[i]), strlabel);
	gtk_grid_attach(GTK_GRID(myGrid), lsw[i], 18-i, 2, 1, 1);
   }
   gtk_grid_attach(GTK_GRID(myGrid), wkey3, 11, 3, 2, 1);
   gtk_grid_attach(GTK_GRID(myGrid), wkey2, 13, 3, 2, 1);
   gtk_grid_attach(GTK_GRID(myGrid), wkey1, 15, 3, 2, 1);
   gtk_grid_attach(GTK_GRID(myGrid), wkey0, 17, 3, 2, 1);

   ledspixbuf = gdk_pixbuf_new_from_file( BOARD_IMAGE ,NULL);
   ledspixbufoff = gdk_pixbuf_copy(ledspixbuf);

   pixels = gdk_pixbuf_get_pixels (ledspixbuf);
   pixelsoff = gdk_pixbuf_get_pixels (ledspixbufoff);
   rowstride = gdk_pixbuf_get_rowstride (ledspixbuf);

   wleds = gtk_image_new_from_pixbuf (ledspixbuf);

   gtk_grid_attach(GTK_GRID(myGrid), wleds, 0, 0, 19, 1);
   wsep1 = gtk_separator_new (GTK_ORIENTATION_VERTICAL);
   gtk_grid_attach(GTK_GRID(myGrid), wsep1, 0, 1, 1, 1);

   gtk_grid_set_column_homogeneous(GTK_GRID(myGrid),FALSE);
   gtk_grid_set_row_spacing(GTK_GRID(myGrid),5);
   gtk_container_add(GTK_CONTAINER (window), myGrid);
   gtk_widget_show_all (window);
   gdk_threads_add_timeout(1, update_leds, NULL);
   gtk_main();
   return NULL;
}

static pthread_t thread_id; 
void init_gui()
{
   pthread_create(&thread_id, NULL, main_gui, NULL); 
   init_done=1;
}

long int get_cmem(int w) {
   if (init_done==0)
	init_gui();

   if (init_done!=1)
	return 0;

   switch(w) {
    	case 0 : return (long) inmem;
    	case 1 : return (long) outmem;
    	case 2 : return (long) ckmem;
   }
   return 0;
}


