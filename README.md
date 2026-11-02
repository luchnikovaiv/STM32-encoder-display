# STM32-encoder-display
A hexadecimal counter (0–F) implemented in ARM Assembly for the STM32F103 microcontroller. The project uses a rotary encoder as input and a common-cathode 7-segment display as output. Developed in STM32CubeIDE.

## Features

- ARM Assembly (Thumb-2)
- STM32F103 microcontroller
- Rotary encoder input
- 7-segment display output
- Hexadecimal counting from 0 to F
- Direct GPIO register access

## Hardware

- STM32 Nucleo-64 (STM32F103)
- Incremental rotary encoder
- Common-cathode 7-segment display

## Pin Configuration

| STM32 Pin | Function |
|---|---|
| PA0 | Encoder A |
| PA1 | Encoder B |
| PA4–PA10 | 7-segment display segments |

## Development Environment

- STM32CubeIDE
- ARM Assembly
- STM32F10x CMSIS device definitions

## How It Works

The rotary encoder controls the counter value. Depending on the rotation direction, the displayed hexadecimal value increases or decreases within the range 0–F.

The display is controlled directly through GPIO registers.

