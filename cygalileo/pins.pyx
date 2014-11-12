from __future__ import division

include "config.pxi"  # conditional compilation values
import mmap
from os import path


cdef class AnalogPin:
    """Class for controlling an analog pin on the board

    Naively creates itself and its properties as supplied by an AnalogPinManager class.
    """

    cdef int number  # the number of the analog pin
    cdef char* gpio_pin  # Linux Logical GPIO pin to access analog pin

    cdef char* mux_pin  # Linux Logical GPIO pin for first level mux
    cdef char* mux_value  # drive value for first level mux

    cdef char* mux2_pin  # Linux Logical GPIO pin for second level mux
    cdef char* mux2_value  # drive value for second level mux

    def __cinit__(self, int number, char* gpio_pin, char* mux_pin,
                  char* mux_value, char* mux2_pin, char* mux2_value):
        """Initialize the analog pin for pin `name`

        Creates an object of type `AnalogPin` that can be used to access the
        functionality of an analog pin on the Galileo Board

        Parameters
        ----------
        name : char*
            the name of the analog pin
        """
        #initialize instance properties
        self.number = number
        self.gpio_pin = gpio_pin
        self.mux_pin = mux_pin
        self.mux_value = mux_value
        self.mux2_pin = mux2_pin
        self.mux2_value = mux2_value

        #setup first level mux, if needed
        if self.mux_pin != bytes("00"):
            self.setup_mux(1)
        #setup the second level mux, if needed
        if self.mux2_pin != bytes("00"):
            self.setup_mux(2)
        #memory map the value file
        with open('/sys/bus/iio/devices/iio:device0/in_voltage' + str(self.number) +
                  '_raw', 'r') as f:
            self._value = mmap.mmap(f.fileno(), 0, prot=mmap.PROT_READ)

    cdef void setup_mux(self, int level):
        """Sets up the first level mux for this pin

        Parameters
        ----------
        level : int
            the level of the mux to set up

        Returns
        -------
        void

        Raises
        ------
        ValueError
            if `level` != 1 | 2
        """
        #set which mux level we are setting
        if level == 1:
            pin = self.mux_pin
            value = self.mux_value
        elif level == 2:
            pin = self.mux2_pin
            value = self.mux2_value
        else:
            raise ValueError("invalid level specified")

        file_path = '/sys/class/gpio/gpio' + pin
        export_pin(pin)
        IF WABUG075:  # need to set drive strength to strong for firmware v0.75
            with open(file_path + '/drive') as f:
                f.write('strong')
        #set the GPIO direction to out
        with open('file_path' + '/direction', 'w') as f:
            f.write('out')
        #set the value on the pin to the mux_drive
        with open('file_path' + '/value', 'w') as f:
            f.write(value)

    property value:
        def __get__(self):
            self._value.seek(0)  #set pointer to beginning of mapping
            return self._value[:].strip()

    def __dealloc__(self):
        #unexport the mux pins
        exported_muxes = [p for p in [self.mux_pin, self.mux2_pin]
                          if str(p) != '00']
        for mux in exported_muxes:
            unexport_pin(mux)
        self._value.close()  #unmap the memory


cdef class DigitalPin:
    """Class representing a digital pin without PWM
    """

    cdef int number
    cdef char* gpio_pin
    cdef char* mux_pin
    cdef char* mux_value
    cdef char* mux2_pin
    cdef char* mux2_value

    def __init__(self, int number, char* gpio_pin, char* mux_pin, char* mux_value,
                 char* mux2_pin, char* mux2_value):
        """Initialize the digital pin
        """
        #set instance attributes
        self.number = number
        self.gpio_pin = gpio_pin
        self.mux_pin = mux_pin
        self.mux_value = mux_value
        self.mux2_pin = mux2_pin
        self.mux2_value = mux2_value

        #setup muxes, if necessary
        if self.mux_pin != bytes('00'):
            self.setup_mux(1)
        if self.mux2_pin != bytes('00'):
            self.setup_mux(2)

    def set_mode(self, char* direction):
        """Sets the mode for this pin as input or output

        Parameters
        ----------
        direction : char*
            the direction for the pin (valid values are `input` or `output`)

        Returns
        -------
        void

        Raises
        ------
        ValueError
            if an invalid value for `direction` is specified
        """
        if self.is_setup:
            raise GPIOError("This pin has already been setup")

        # setup the gpio pin
        self.setup_gpio_pin(direction)

        # memorymap the value file
        with open('/sys/class/gpio/gpio' + self.gpio_pin + '/value', 'r+') as f:
            self._value = mmap.mmap(f.fileno(), 0)
        self.is_setup = True  # mark as having already been setup

    property value:
        def __get__(self):
            """Gets the current value of the pin

            Returns
            -------
            char*
                the current value on the pin as either `HIGH` or `LOW`

            Raises
            ------
            GPIOError
                if a valid value is not read from the pin
            """
            cdef char num_val
            self._value.seek(0)
            num_val = self._value.read_byte()  #read the first byte in the file

            #validate that the value we got was OK
            if num_val == '1':
                return 'HIGH'
            elif num_val == '0':
                return 'LOW'
            else:
                raise GPIOError('Did not read valid value from pin')

        def __set__(self, char* value):
            """Set the value of the pin

            Parameters
            ----------
            value : char*
                the value to set the pin to (valid values are `high` or `low`)

            Returns
            -------
            void

            Raises
            ------
            """
            cdef char set_value
            if str(value).upper() == 'HIGH':
                set_value = '1'
            elif str(value).upper() == 'LOW':
                set_value = '0'
            else:
                raise ValueError('did not specify a valid value')
            self._value.seek(0)  # ensure pointer is @ start of mmap
            self._value.write_byte(set_value)
            self._value.flush()  # flush the value back to the actual file

    cdef void setup_mux(self, int level):
        """Sets up the mux at the given level

        Parameters
        ----------
        level: int
            the level of the mux to set
            valid values are 1 or 2

        Returns
        -------
        void

        Raises
        ------
        ValueError
            if the level is not specified as 1 or 2
        """
        #set which mux level we are setting
        if level == 1:
            pin = self.mux_pin
            value = self.mux_value
        elif level == 2:
            pin = self.mux2_pin
            value = self.mux2_value
        else:
            raise ValueError("invalid level specified")

        file_path = '/sys/class/gpio/gpio' + pin
        export_pin(pin)
        IF WABUG075:  # need to set drive strength to strong for firmware v0.75
            with open(file_path + '/drive') as f:
                f.write('strong')
                #set the GPIO direction to out
        with open('file_path' + '/direction', 'w') as f:
            f.write('out')
        #set the value on the pin to the mux_drive
        with open('file_path' + '/value', 'w') as f:
            f.write(value)

    cdef void setup_gpio_pin(self, char* direction):
        """Sets up the gpio pin and gives it an IO direction

        Parameters
        ----------
        direction : char*
            whether the pin is INPUT or OUTPUT
            valid values are `input` or `output`

        Returns
        -------
        void

        Raises
        ------
        ValueError
            if an invalid direction value is specified
        """
        cdef char* write_dir
        #export the gpio pin
        file_path = '/sys/class/gpio/gpio' + self.gpio_pin
        export_pin(self.gpio_pin)

        #set drive to strong if firmware is v0.75
        IF WABUG075:
            with open('/sys/class/gpio/gpio' + self.gpio_pin + '/drive') as f:
                f.write('strong')

        #make sure the direction put in is valid
        if str(direction).upper() == 'INPUT':
            write_dir = 'in'
        elif str(direction).upper() == 'OUTPUT':
            write_dir = 'out'
        else:
            raise ValueError("did not specify a valid IO direction")

        with open(file_path + '/direction', 'w') as f:
            f.write(write_dir)

    def __dealloc__(self):
        if self.is_setup:
            unexport_pin(self.gpio_pin)  # unexport the gpio pin
            self._value.close()  # close the mmap for the value file
        #unexport the mux pin
        exported_muxes = [p for p in [self.mux_pin, self.mux2_pin]
                          if str(p) != '00']
        for mux in exported_muxes:
            unexport_pin(mux)


cdef class DigitalPWMPin(DigitalPin):
    """Class representing a digital pin with pulse width modulation
    """

    cdef char* pwm_pin
    cdef char* pwm_mux_pin
    cdef char* pwm_mux_value
    cdef char* pwm_mux2_pin
    cdef char* pwm_mux2_value

    def __init__(self, int number, char* gpio_pin, char* mux_pin,
                  char* mux_value, char* mux2_pin, char* mux2_value,
                  char* pwm_pin, char* pwm_mux_pin, char* pwm_mux_value,
                  char* pwm_mux2_pin, char* pwm_mux2_value):
        """Initializes the specified pin
        """
        #setup instance attributes
        self.pwm_pin = pwm_pin
        self.pwm_mux_pin = pwm_mux_pin
        self.pwm_mux_value = pwm_mux_value
        self.pwm_mux2_pin = pwm_mux2_pin
        self.pwm_mux2_value = pwm_mux2_value

        #call DigitalPin class constructor
        super(DigitalPWMPin, self).__init__(number, gpio_pin, mux_pin,
                                            mux_value, mux2_pin, mux2_value)

        self.setup_pwm()  # setup pwm for the pin

    property pwm_cycle:
        def __get__(self):
            """Get the value of the duty cycle for the PWM pin"""
            return self._pwm_duty[:].strip()

        def __set__(self, int value):
            """Sets the value of a digital pin using PWM

            Parameters
            ----------
            value: int
                the value for the pin (valid values between 0-255)

            Raises
            ------
            ValueError
                if the value specified isn't in range 0-255
            """
            cdef int period = 1000000  # period of the pulse, in ms

            #validate the value passed in
            if value < 0 or value > 255:
                raise ValueError("did not specify a valid value")

            duty_cycle = int(round(period * value / 255))  # calculate the duty cycle

            #need to turn off the digital driver for the pin
            self.value = 'low'

            #write the values out to the appropriate files
            self._pwm_period.seek(0)  # ensure we're at start of file
            self._pwm_period.write(str(period))  # write value into mapping
            self._pwm_period.flush()  # flush back to F/S
            self._pwm_duty.seek(0)
            self._pwm_duty.write(str(duty_cycle))

    cdef void setup_pwm(self):
        """Sets up PWM for this pin
        """
        base_path = '/sys/class/pwm/pwmchip0/pwm' + self.pwm_pin
        if not path.exists(base_path + '/enable'):
            #export the pin
            with open('/sys/class/pwm/pwmchip0/export', 'w') as f:
                f.write(self.pwm_pin)
        #create memory mappings for period and duty cycle files
        with open(base_path + '/period', 'r+') as f:
            self._pwm_period = mmap.mmap(f.fileno(), 0)
        with open(base_path + '/duty_cycle', 'r+') as f:
            self._pwm_duty = mmap.mmap(f.fileno(), 0)

    def __dealloc__(self):
        unexport_pin(self.pwm_pin)  # unexport the pwm pin
        #close all pwm-related mappings
        self._pwm_period.close()
        self._pwm_duty.close()

        super(DigitalPWMPin, self).__dealloc__()


def export_pin(int pin_number):
    """Exports the pin at the given number

    Parameters
    ----------
    pin_number : int
        the number of the pin to export

    Returns
    -------
    void

    Raises
    ------
    GPIOError
        if the pin could not be exported (/sys/class/gpio/gpio{#} not created)
    """
    with open('/sys/class/gpio/export') as f:
        f.write(pin_number)
    if not path.isdir('/sys/class/gpio/gpio' + pin_number):
        raise GPIOError("Could not export pin", pin_number)


def unexport_pin(int pin_number):
    """Unexports the pin at the given number

    Parameters
    ----------
    pin_number : int
        the number of the pin to export

    Returns
    -------
    void

    Raises
    ------
    GPIOError
        if the pin could not be unexported
        if the specified pin hasn't been exported already
    """
    if not path.isdir('/sys/class/gpio/gpio' + pin_number):
        raise GPIOError("this pin has not been exported")
    with open('/sys/class/gpio/unexport') as f:
        f.write(pin_number)
    if path.isidir('/sys/class/gpio/gpio' + pin_number):
        raise GPIOError("pin was not properly exported")


class GPIOError(Exception):
    """Exceptions raised when something goes wrong while interacting with the
    GPIO-related files on the Galileo
    """
    pass
