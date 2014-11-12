"""
PXD file to describe a valid Galileo Board
"""

cdef char* gpio_path = '/sys/class/gpio'  # base path to gpio

"""
ANALOG PINS
"""
cdef const char** analog_pins = ["A0", "A1", "A2", "A3", "A4", "A5"]
cdef const char** analog_gpio = ["44", "45", "46", "47", "48", "49"]
cdef const char** analog_mux_pin = ["37", "36", "23", "22", "21", "20"]
cdef const char** analog_mux_val = ["0", "0", "0", "0", "0", "0"]
cdef const char** analog_mux2_pin = ["00", "00", "00", "00", "29", "29"]
cdef const char** analog_mux2_val = ["00", "00", "00", "00", "1", "1"]
"""
DIGITAL PINS
"""
cdef const int* digital_pins = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
cdef const char** digital_gpio = ["50", "51", "32", "18", "17", "24", "27",
                                  "26", "19", "16", "25", "38", "39"]
cdef const char** digital_mux_gpio = ["40", "41", "31", "30", "00", "00", "00",
                                      "00", "00", "00", "42", "43", "54", "55"]
cdef const char** digital_mux_drive = ["1", "1", "1", "1", "00", "00", "00",
                                       "00", "00", "00", "1", "1", "1", "1"]
cdef const char** digital_mux2_gpio = ["00", "00", "1", "0", "00", "00", "00",
                                       "00", "00", "00", "00", "00", "00", "00"]
cdef const char** digital_mux2_drive = ["00", "00", "1", "0", "00", "00", "00",
                                        "00", "00", "00", "00", "00", "00", "00"]

"""
DIGITAL VALUES

Constant strings for digital high/digital low values
"""
cdef const char* DIG_HIGH = "HIGH"
cdef const char* DIG_LOW = "LOW"
"""
PIN DIRECTIONS

Constant strings for setting pin directions
"""
cdef const char* DIR_OUT = "OUTPUT"
cdef const char* DIR_IN = "INPUT"
