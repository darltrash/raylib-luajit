# Raylib for LuaJIT
A really simple [Raylib](https://www.raylib.com) LuaJIT binding! (that will do the job for most cases).

Based on [this gist](https://gist.github.com/alexander-matz/f8ee4eb9fdf676203d70c1e5e329a6ec)

## PROS:
  - It works great in luajit 2+
  - Single file (except for the compiled raylib binaries)
  - Works as an actual lib instead of a runner
  - Everything is saved into a table
  - Mostly everything should work properly.
  
## CONS:
  - You need the luajit and raylib compiled binaries/libraries
  - Experimental
  
# Installation.
  - Download the raylib.lua file and put it into your project
  - Require it like this: "```rl = require 'raylib'```"
  - Install Raylib (the library, not this binding)

## Recommendations/Notes:
  - If you are on Windows, you can also add the "libraylib.dll" file into the project directly.
  - Technically you can run this on puc lua, but it wont be as good as running it with luajit.
  - Not tested on MacOS but it should work (...maybe)
  - This is my first binding ever, but it should work 
  
