# The Corundum Graphics Engine
##### Powered by Ruby.

By Jake Zaia -- Stuyvesant Computer Graphics Pd 10
## What is it?
A graphics engine written entirely in Ruby with a compyler written in Python. It facilitates the creation of 3-dimensional (and 2-dimensional) shapes and emulates real-world lighting.

## New features
This version contains 2 new major features:
* OBJ File support: Any OBJ file may be used to create a mesh in this project
* Multiple lights: Multiple point-light sources may now be used. In addition each object has its own reflective constants.

## How do I use it?
1) First, clone the repo: `$ git clone https://github.com/jzaia18/corundum-graphics-engine.git`

2) For example code execution, type `make`

3) Create any file with the extension `.mdl`. A full list of commands may be found in the MDL.spec file located in the root of the repository.

4) Execute your own code with `ruby Main.rb <filename>.mdl`

## Dependencies?
The Corundum engine runs primarily on Ruby but does require some a few other packages
* Ruby
* Python 2
* Image Magick
