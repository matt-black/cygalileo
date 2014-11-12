"""
Setup file for the Cython port of PyGalileo
"""
import os, shutil
from os import path
from distutils.core import setup
from distutils.extension import Extension

from Cython.Distutils import build_ext
from Cython.Build import cythonize

#useful directories
this_dir = path.abspath(path.dirname(__file__))
src_dir_path = path.join(this_dir, 'cygalileo')

#PROJECT METADATA AND SETUP CONSTANTS
NAME='cygalileo'
VERSION='0.1a'
DESCR='A Cython port of the PyGalileo library'
#get long description from DESCRIPTION.rst
with open(path.join(this_dir, 'DESCRIPTION.rst')) as f:
    LONG_DESCR = f.read()
REQUIRES=['cython']

AUTHOR='Matt Black'
EMAIL='matt.black7@gmail.com'
URL = 'http://matt-black.github.io'
LICENSE='GPLv3+'

SRC_DIR='cygalileo'

EXTENSIONS = [
    Extension(SRC_DIR + ".board", [path.join(SRC_DIR, "board.pyx")]),
    Extension(SRC_DIR + ".arduino", [path.join(SRC_DIR, "arduino.pyx")]),
    Extension(SRC_DIR + ".pins", [path.join(SRC_DIR, "pins.pyx")])
]

#generate a pxi file for conditional compilation
#DEBUG : turn on debug messages
#waBug075 : bug in the firmware v0.75, setting this flag to true enables workaround
c_options = {'DEBUG' : False,
             'waBug075' : False}
with open(os.path.join(src_dir_path, 'config.pxi'), 'w') as f:
    for opt in c_options:
        f.write('DEF %s = %d\n'%(opt.upper(), int(c_options[opt])))

#clean previous build
for root, dirs, files in os.walk('.', topdown=False):
    for name in files:
        if (name.startswith(SRC_DIR) and not (name.endswith(".pxd") or name.endswith(".pyx"))):
            os.remove(os.path.join(root, name))
    for name in dirs:
        dirs_to_remove = ['build']
        if name in dirs_to_remove:
            shutil.rmtree(name)

if __name__ == "__main__":
    setup(name=NAME,
          version=VERSION,
          description=DESCR,
          long_description=LONG_DESCR,
          author=AUTHOR,
          author_email=EMAIL,
          url=URL,
          license=LICENSE,

          cmdclass = {"build_ext": build_ext},
          ext_modules=EXTENSIONS)
