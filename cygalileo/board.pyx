cimport cygalileo.pins as _pins

cdef class GalileoBoard:
    """Class representing the GalileoBoard
    """

    def __cinit__(self, int[:] analog_pins, int[:] digital_pins):
        """Initializes a 'fresh' board

        Parameters
        ----------
        analog_pins : int[:]
        digital_pins : int[:]

        Raises
        ------
        ValueError
            if an invalid pin number if specified
        """
        #initialize the pin managers
        self._apm = AnalogPinManager(analog_pins)
        self._dpm = DigitalPinManager(digital_pins)

    def activate_pin(self, char* pin_type, int pin_number):
        """Adds/initializes a new pin on the board

        Parameters
        ----------
        pin_type : char*
            the type of pin (valid values are 'analog' or 'digital')
        pin_number : int
            the number of the new pin

        Returns
        -------
        void

        Raises
        ------
        ValueError
            if an invalid pin_type or pin_number is specified
        """
        if str(pin_type).lower() == 'analog':
            self._apm.activate_pin(pin_number)
        elif str(pin_type).lower() == 'digital':
            self._dpm.activate_pin(pin_number)
        else:
            raise ValueError("invalid pin type")

    def deactivate_pin(self, char* pin_type, int pin_number):
        """Deactivates a pin from the board

        Parameters
        ----------
        pin_type : char*
            the type of pin (valid values are 'analog' or 'digital')
        pin_number : int
            the number of the new pin

        Returns
        -------
        void

        Raises
        ------
        ValueError
            if an invalid pin_type or pin_number is specified
        """
        if str(pin_type).lower() == 'analog':
            self._apm.deactivate_pin(pin_number)
        elif str(pin_type).lower() == 'digital':
            self._dpm.deactivate_pin(pin_number)
        else:
            raise ValueError("invalid pin type")

    def analog_pin(self, int pin_number):
        """Get the analog pin with the given pin number
        """
        return self._apm.get_pin(pin_number)

    def digital_pin(self, int pin_number):
        """Gets the digital pin with the given pin number
        """
        return self._dpm.get_pin(pin_number)


cdef class AnalogPinManager:
    """Manages the analog pins on the Galileo board
    """

    def __cinit__(self, int[:] initial_pins):
        """Initialize the analog pin factory for a board

        Parameters
        ----------
        board : GalileoBoard

        Returns
        -------
        void

        Raises
        ------

        """
        self.pins = {i : None for i in range(0, 6)}
        for pin in initial_pins:
            self.activate_pin(pin)

    def activate_pin(self, int pin_number):
        """Initializes a new pin with name, `name`

        Parameters
        ----------
        name : char*
            the pin to initialize

        Returns
        -------
        AnalogPin
            a new `AnalogPin` with initialized properties/exported GPIO

        Raises
        ------
        ValueError
            if an invalid pin name is passed in
        """

        #validate that the pin number is in the proper range
        if pin_number not in self.pins:
            raise ValueError("invalid analog pin number")
        #make sure the pin isn't already active
        if self.pins[pin_number]:
            raise Exception("this pin is already initialized!")

        #activate it
        cdef char* gpio = analog_gpio[pin_number]
        cdef char* mux_pin = analog_mux_pin[pin_number]
        cdef char* mux_val = analog_mux_val[pin_number]
        cdef char* mux2_pin = analog_mux2_pin[pin_number]
        cdef char* mux2_val = analog_mux2_val[pin_number]

        pin = _pins.AnalogPin(pin_number, gpio, mux_pin, mux_val,
                              mux2_pin, mux2_val)

        self.pins[pin_number] = pin

    def deactivate_pin(self, int pin_number):
        """Deletes the pin object with specified pin number
        """
        self.pins[pin_number] = None

    cdef bint pin_is_active(self, int pin_number):
        """Checks if the pin with number `pin_number` is active

        Parameters
        ----------
        pin_number : int
            the number of the pin to check

        Returns
        -------
        bint
            0 (False) if inactive, 1 (True) if active
        """
        return True if self.pin[pin_number] else False

    def get_pin(self, int pin_number):
        if self.pin_is_active(pin_number):
            try:
                return self.pins[pin_number]
            except KeyError:
                raise ValueError("did not specify a valid pin number")
        else:
            raise Exception("the specified pin is not active")


cdef class DigitalPinManager:
    """Manages the digital pins on the board
    """
    valid_pwm = {3: 3, 5: 5, 6: 6, 9: 1, 10: 7, 11: 4}  # valid pwm pins, mapping to muxes
    def __cinit__(self, int[:] initial_pins):
        """Initialize the manager"""
        self.pins = {i : None for i in range(0, 14)}
        for pin in initial_pins:
            self.activate_pin(pin)

    def activate_pin(self, int pin_number):
        """Activates the specified pin

        Parameters
        ----------
        pin_number: int
            the number of the pin to activate

        Raises
        ------
        ValueError
            if an invalid pin is specified
        """
        if pin_number not in self.pins:
            raise ValueError("did not specify a valid pin")

        if self.pin_is_active(pin_number):
            raise Exception("this pin is already active")

        #get values for the pin
        cdef char* gpio = digital_gpio[pin_number]
        cdef char* mux_gpio = digital_mux_gpio[pin_number]
        cdef char* mux_drive = digital_mux_drive[pin_number]
        cdef char* mux2_gpio = digital_mux2_gpio[pin_number]
        cdef char* mux2_drive = digital_mux2_drive[pin_number]

        if pin_number in self.valid_pwm:  #need to get values for pwm stuff
            pwm_pin = self.valid_pwm[pin_number]
            pwm_mux_pin = digital_mux_gpio[pwm_pin]
            pwm_mux_drive = digital_mux_drive[pwm_pin]
            pwm_mux2_pin = digital_mux2_gpio[pwm_pin]
            pwm_mux2_drive = digital_mux2_drive[pwm_pin]
            #activate the pin
            pin = _pins.DigitalPWMPin(pin_number, gpio, mux_gpio, mux_drive,
                                      mux2_gpio, mux2_drive, pwm_pin, pwm_mux_pin,
                                      pwm_mux_drive, pwm_mux2_pin, pwm_mux2_drive)
        else:
            pin = _pins.DigitalPin(pin_number, gpio, mux_gpio, mux_drive,
                                   mux2_gpio, mux2_drive)
        self.pins[pin_number] = pin

    def deactivate_pin(self, int pin_number):
        """Deactivates the specified pin on the board
        """
        self.pins[pin_number] = None

    cdef bint pin_is_active(self, int pin_number):
        return True if self.pins[pin_number] else False

    def get_pin(self, int pin_number):
        if self.pin_is_active(pin_number):
            try:
                return self.pins[pin_number]
            except KeyError:
                raise ValueError("did not specify a valid pin number")
        else:
            raise Exception("the specified pin is not active")
