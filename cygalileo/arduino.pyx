"""
Arduino-like API for this library
"""
from __future__ import division
import time
from cygalileo.board import GalileoBoard


cdef class Arduino:
    """A class that tries to emulate the functions/API of a standard Arduino
    """

    def __cinit__(self, board):
        """Initializes the class

        Parameters
        ----------
        board : GalileoBoard
             A `GalileoBoard` object to read/write to/from
        """
        if not isinstance(board, GalileoBoard):
            raise TypeError("board must be a GalileoBoard")
        self.board = board

    @staticmethod
    def delay(int milliseconds):
        """Delays the execution of the script for `time` number of milliseconds

        Parameters
        ----------
        milliseconds : int
            the number of milliseconds to delay execution
        """
        time.sleep(milliseconds)

    @staticmethod
    def micros():
        """Gives the current time, in microseconds

        Returns
        -------
        int
            the current time, in microseconds
        """
        return int(round(time.time() * 1000000))

    @staticmethod
    def millis():
        """Gives the current time, in microseconds

        Returns
        -------
        int
            the current time, in microseconds
        """
        return int(round(time.time() * 1000))

    def pin_mode(self, int pin, char* direction):
        """Sets the direction for the specified digital pin

        Parameters
        ----------
        pin : int
            the number of the digital pin to be set
        direction: char*
            the direction of the pin (valid values are `input` or `output`)

        Returns
        -------
        void

        Raises
        ------
        ValueError
            if a valid `direction` is not specified

        """
        pin = self.board.digital_pin(pin)
        pin.set_mode(direction)

    def digital_write(self, int pin, char* value):
        """Writes a high or low value to the specified digital pin

        Parameters
        ----------
        pin : int
            the pin to write to
        value : char*
            the value to write (valid values are `high` or `low`)

        Returns
        -------
        void

        Raises
        ------
        ValueError
            if invalid value is specified
        """
        pin = self.board.digital_pin(pin)
        pin.value = value

    def digital_read(self, int pin):
        """Reads the value of the specified pin

        Parameters
        ----------
        pin : int
            the pin to be read

        Returns
        -------
        char*
            the value of the pin ("HIGH" or "LOW")
        """
        pin = self.board.digital_pin(pin)
        return pin.value

    def analog_write(self, int pin, int value):
        """Writes the provided voltage value to the specified PWM pin

        Parameters
        ----------
        pin : int
            the pin to write to (must be a pin with PWM)
        value : int
            the voltage value to write (valid values are between 0 and 255)
            0 = 0V
            255 = 5V
        Raises
        ------
        ValueError
             if a value outside the range 0-255 is specified
        """
        pin = self.board.digital_pin(pin)
        try:
            pin.pwm_cycle = value
        except AttributeError:
            raise ValueError("the specified pin cannot be written to")

    def analog_read(self, int pin):
        """Reads the voltage on the specified analog pin

        Parameters
        ----------
        pin : int
            the analog pin number to read from

        Returns
        -------
        int
            the value on the pin
            0 = 0 Volts
            1023 = 5 Volts
        """
        pin = self.board.analog_pin(pin)
        return pin.value
