#!/usr/bin/env python
"""
BLINK

Turn on an LED for 1 second, then off for 1 second.
Repeat ad infinitum.
"""
from cygalileo.board import GalileoBoard
from cygalileo.arduino import Arduino

_board = GalileoBoard([0], [13])
arduino = Arduino(_board)

def setup():
    """The setup routine runs once you press `reset` on the board
    """
    arduino.pin_mode(13, 'OUTPUT')  # set pin13 for output


def loop():
    """This function should be wrapped in a loop and called from there
    to do something repeatedly

    In this loop, we will turn the LED on, then delay for 1 second,
    then turn the LED off and delay for one second
    """
    arduino.digital_write(13, 'HIGH')  # turn the LED on
    arduino.delay(1000)  # delay for 1 sec
    arduino.digital_write(13, 'LOW')


if __name__ == "__main__":
    """When the file is run from the command line, this routine is run

    It calls setup() once, then loop forever
    """
    setup()
    while True:
        loop()
