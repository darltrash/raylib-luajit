# Raylib for LuaJIT
A really simple [Raylib](https://www.raylib.com) LuaJIT binding! (that will do the job for most cases).

Based on [this gist](https://gist.github.com/alexander-matz/f8ee4eb9fdf676203d70c1e5e329a6ec)

## PROS:
  - It works great in LuaJIT 2+
  - Single file (except for the compiled raylib binaries)
  - Works as an actual lib instead of a runner
  - Everything is saved into a table
  - Mostly everything should work properly.
  
## CONS:
  - You need the LuaJIT and Raylib compiled binaries/libraries
  - Is my first binding ever (PLEASE LEAVE ME RECOMMENDATIONS)
  - Experimental
  
# Installation.
  - Download the raylib.lua file and put it into your project
  - Require it like this: "```rl = require 'raylib'```"
  - Install Raylib (the library, not this binding)
  - Run the code with LuaJIT and it should be working.

## Recommendations/Notes:
  - If you are on Windows, you can also add the "libraylib.dll" file into the project directly.
  - Technically you can run this on puc lua, but it wont be as good as running it with luajit.
  - Not tested on MacOS but it should work (...maybe)
  
# Example:
To run the example;
  - Clone the repo
  - Install LuaJIT 2+ and Raylib 3 (if not installed)
  - Run "main.lua" with LuaJIT 2+
  - Admire the precious white window with the text inside
