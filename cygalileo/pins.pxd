"""
PXD file for Galileo pins
"""

# PIN2GPIO
cdef char **pin2gpio = ["50", "51", "32", "18", "28", "17", "24", "27", "26",
                      "19", "16", "25", "38", "39"]

cdef inline char* get_gpio(int pin):
    return pin2gpio[pin]

#MUXGPIO
cdef char **muxgpio = ["40", "41", "31", "30", "00", "00", "00", "00", "00",
                       "00", "42", "43", "54", "55"]

cdef inline char* get_muxgpio(int pin):
    return muxgpio[pin]

#MUXDRIVE
cdef char **muxdrive = ["1", "1", "1", "1", "0", "0", "0", "0", "0",
                       "0", "1", "1", "1"]

cdef inline char* get_muxdrive(int pin):
    return muxdrive[pin]

#MUX2GPIO
cdef char **mux2gpio = ["00", "00", "1", "0", "00", "00", "00", "00", "00",
                       "00", "00", "00", "00"]

cdef inline char* get_mux2gpio(int pin):
    return mux2gpio[pin]

#MUX2DRIVE
cdef char **mux2drive = ["00", "00", "0", "0", "00", "00", "00", "00", "00",
                        "00", "00", "00", "00"]

cdef inline char* get_mux2drive(int pin):
    return mux2drive[pin]
