#cygalileo
A Cython library for Intel's Galileo Board

Heavily-inspired by C. Hofrock's [pyGalileo](http://github.com/chofrock/pygalileo) library, this implementation
is written in Cython and with a slightly different API. 

*WARNING* : this was a project undertaken more for my own learning. If you want to do heavy-lifting with the onboard Python on your Intel, take a look at [mraa](http://github.com/intel-iot-devkit/mraa). 

## Requirements

* An Intel Galileo board (only tested on Gen1, but should be okay with Gen2)
* A microSD card with a Linux image and Python

## Installing

For now, the easiest thing is to clone the repo, copy it onto your SD card, and use the compiler on your Linux image to build the extensions. 
I'm working on a way to make this easier. 

## Licensing

This library is licensed under the [GNU Public License v3](http://www.gnu.org/copyleft/gpl.html).

