# Angry-Bird-Game
This repository contains an implementation of the Angry Birds game designed for an FPGA using Verilog. The project combines digital design concepts with game logic to deliver a hardware-based gaming experience. Below, you will find details about the project, how to run it, and the technical challenges involved.

<ins>Features</ins> 

* **Game Mechanics:**
   - Realistic trajectory simulation of the bird using physics-based equations.
   - Interaction with obstacles and targets.
   - Score tracking, life tracking, and level progression.
    
* **Display:**
    - VGA output to render the game on a monitor.
  
* **Controls:**
    - User input via Keyboard or switches for launching the bird and resetting the game.

<ins>Architecture</ins>

The project uses the following modules:

* **Game Logic Module:**
    - Handles bird trajectory, collision detection, and scoring.

* **VGA Controller:**
   - Generates signals for VGA output.
   - Responsible for rendering the game objects (bird, obstacles, and targets).
     
* **Input Controller:**
   - Reads input from the Keyboard or switches to launch the bird or reset the game.

<ins>File Structure</ins>
```
Angry-Bird-Game/
|-- src/                  # Verilog source files
|   |-- vga_controller.v  # VGA signal generator
|   |-- game_logic.v      # Game logic module
|   |-- input_controller.v # User input handler
|-- simulation/           # Testbenches and simulation scripts
|-- docs/                 # Documentation and design diagrams
|-- constraints/          # FPGA constraints (e.g., .xdc or .qsf files)
|-- README.md             # Project documentation

```
  
 ![image](https://github.com/user-attachments/assets/062c49de-35bd-4bbc-994e-816c1344142e)
![image](https://github.com/user-attachments/assets/4181c778-159d-467c-9e53-769fb90abccd)
![image](https://github.com/user-attachments/assets/292523c4-aa08-4c24-b963-8245ae5fec05)
![image](https://github.com/user-attachments/assets/16bdd79a-ef12-424c-8678-4e104827dbaa)

![image](https://github.com/user-attachments/assets/9c3ccf7b-fe19-4bd5-838c-7132ccc1aa67)
