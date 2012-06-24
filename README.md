iSprinkle
=========

This is iSprinkle, a pet project for controlling my home sprinklers with Linux, Python, OpenWRT, USB, iOS, and my own sweat.

I can say with near 100% confidence that unless you know me personally, you probably don't want to be here.

However, if you like pain, here's a description of this software:

isprinkle-server
----------------
* The Python scheduler that runs on the control computer (an OpenWRT board in my case).
* Provides a very basic, unauthenticated web service to set up watering schedules using YAML.
* It's almost RESTful, but the URLs are RPC-style.
* Uses pickles to persist the watering schedules.
* Shells out to isprinkle-control to actually turn on and off sprinkler valves.
* Seems pretty stable. I've left it running for months at a time with no problem.

isprinkle-control
-----------------
* The C program that turns on and off the USB relays that control my sprinkler valves.
* Requires a very specific version of libusb (included) and libftdi (also included).
* Must be cross-compiled for the embedded board using OpenWRT's build system.
* Might compile on regular PCs with Linux, but recently it has been failing to build for me on Ubuntu. 
* Designed to support a *lot* of valves (I have 16, but it's designed to support hundreds).
* Has a very basic command line interface that lets you do the following:
   1. Turn on a single valve at a time
   2. Turn off all valves
   2. Display status of which valve is currently on

isprinkle-pyqt-gui
------------------
* A prototype GUI built with pyqt that never came to fruition.
* Left here for sentimental reasons only.

isprinkle-iphone-gui
--------------------
* An iOS project that allows one to configure the watering schedules and see current status. 
* Not my finest work, and it seems to leak memory if left running too long (i.e., many hours).

openwrt
-------
* My OpenWRT configuration (about a year old now).
* Includes a file-system overlay for customized configs.

cron
----
* Just an example cron job for using isprinkle-control directly without the Python scheduler and web service.
