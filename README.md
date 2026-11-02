# Candy Crush for Nintendo DS (ARM assembly)

A Candy Crush-style match-3 game for the **Nintendo DS**, written mostly in **ARM assembly** with a C layer for the main loop and graphics setup. It runs in the DeSmuME emulator.

Final project for *Computadors* (Computer Engineering, 2nd year, Universitat Rovira i Virgili, 2024–25), developed by a team of four on top of a base framework provided by the course.

## What it does

- Builds each level's board from its map, avoiding initial matches, and checks that at least one move is possible (and can suggest it).
- Detects horizontal and vertical sequences, removes them and drops new candies, including single and double jelly tiles.
- Recombines the board when no moves are left, animating every candy to its new position.
- Animates candies with hardware sprites, driven by **timer interrupt service routines** (RSI_timer0–3).
- Handles levels, moves and points, with graphics backgrounds loaded through the DS video engine.

## My contribution

| Task | File | Description |
|------|------|-------------|
| 1A | `source/candy1_init.s` | Board initialisation from the level map |
| 1B | `source/candy1_init.s` | Board recombination when no moves are left |
| 2IA | `source/candy1_init.s` | Animated recombination: tracks each candy's sprite to its new position |
| 2A | `source/candy2_graf.c` | Graphics initialisation |
| 2E | `source/RSI_timer0.s` | Timer 0 interrupt routine that moves the sprites (frequency divider and per-frame updates) |
| — | `source/candy2_main.c` | Main program used to test and integrate the routines |

Each source file lists who programmed each task in its header.

## Project structure

```
source/     ARM assembly routines (game logic, interrupts) and C main/graphics code
include/    Shared constants, data structures and prototypes
graphics/   Tiles, backgrounds and sprites converted with grit
Makefile    devkitARM build
```

## Build and run

Requirements: [devkitPro](https://devkitpro.org/) with devkitARM and libnds, and the [DeSmuME](https://desmume.org/) emulator.

```bash
export DEVKITPRO=/opt/devkitpro
export DEVKITARM=$DEVKITPRO/devkitARM
export DESMUME=/path/to/desmume
make            # builds CandyCrush_compus.nds
```

Load the resulting `.nds` file in DeSmuME or on a flash cartridge.

## License

GPL-3.0. See [LICENSE](LICENSE).
