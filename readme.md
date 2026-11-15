# Bouncy Target

A Godot 2D arcade game where you draw walls with your mouse to steer a bouncing ball into the target before time runs out.

## About

A ball bounces around the arena at a steady clip. You can't touch it, but you can draw solid walls with the mouse to bend its path toward the target. Hit the target to clear the level, but each level the ball gets faster and the clock gets shorter.

## How to play

- **Hold left mouse button** and drag to draw a wall.
- Guide the ball into the **target** to advance to the next level.
- Beat the **timer**, or the level restarts.
- Press **R** to restart at any time.

## Features

- Freehand wall drawing with real collision (capsule colliders along your stroke)
- Ball speeds up by 100 every time it hits the target
- Timer starts at 30s and drops 2s per level, bottoming out at 5s
- Walls clear and the ball resets between levels
- Walls can't be placed on top of the ball, so you can't trap it
- Anti-stuck logic that kicks the ball loose if it stalls
- Bounce sound effects

## Built with

- [Godot Engine 4](https://godotengine.org/) (GDScript)

## Running the project

Open: r3z4dotnet.itch.io/bouncy-target

1. Install Godot 4.x.
2. Clone this repo and open it via the Godot Project Manager (`Import` and select `project.godot`).
3. Press **F5** to play.
