/*
 * build with:
     cc -O2 -Wall -nostdlib -shared -fPIC -o libXNoRaise.so XNoRaise.c
 * run with:
     LD_PRELOAD=$PWD/libXNoRaise.so chromium
 */

#include <X11/Xlib.h>
#include <stdio.h>

int
XRaiseWindow (Display *display, Window w)
{
    fprintf(stderr, "Using mocked XRaiseWindow.\n");
    return Success;
}
