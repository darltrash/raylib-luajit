local rl = require 'raylib'

local screenWidth = 800;
local screenHeight = 450;

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window");
rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do

    rl.BeginDrawing()

        rl.ClearBackground(rl.RAYWHITE)
        rl.DrawText("Congrats! You created your first window!", 190, 200, 20, rl.LIGHTGRAY)

    rl.EndDrawing()

end

rl.CloseWindow()
