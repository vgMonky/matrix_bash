# Matrix Bash Simulation

This project is a cellular automaton simulation implemented in Bash. It was developed on NixOS and has not been tested on other operating systems.
You can interact with the simulation by changing the "Rule" variable. 

## Prerequisites

- Bash environment (NixOS recommended)
- `watch` command (for visualization)

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/matrix_bash.git
   cd matrix_bash
   ```

2. Ensure all script files are executable:
   ```
   chmod +x *.bash
   ```

## Usage

1. Open two terminal windows and navigate to the project directory in both.

2. In Terminal A (for visualization), run:
   ```
   watch -c -n 0.1 cat render.txt
   ```

3. In Terminal B (to start the simulation), run:
   ```
   ./manage_simulation.bash start -s 0.1 -d . -r linear_propagation.bash
   ```

4. Control the simulation:
   - Use arrow keys to change the global direction of propagation(only affects some rules).
   - Use number keys (1-6) to change the rule of the simulation:
     1: Linear Propagation
     2: Simple Propagation
     3: Wave Propagation
     4: Geometric Propagation
     5: Life Propagation (Conway's Game of Life)
     6: Mycelium Propagation
   - Press '0' to wipe out everything and restart.
   - Press 'q' to quit the simulation.

## Rules Description

- Linear Propagation: Cells move in a straight line based on the global direction.
- Simple Propagation: [Brief description]
- Wave Propagation: Creates wave-like patterns based on the global direction.
- Geometric Propagation: Forms geometric shapes and patterns without randomness.
- Life Propagation: Implements Conway's Game of Life rules.
- Mycelium Propagation: Simulates the growth patterns of fungal networks.

## Notes

- This simulation was developed and tested on NixOS. Compatibility with other operating systems is not guaranteed.
- Adjusting the simulation speed might be necessary depending on your system's performance.

