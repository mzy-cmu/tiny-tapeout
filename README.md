# Turing Machine
Zhiying Meng 18-224/624 Spring 2023 Final Tapeout Project
## Overview
This chip takes in a Turing Machine style state transition table and displays the computation process.
## Inputs/Outputs
Inputs:
- 4 switches used for input data (state transition table + initial tape value)
- 3 buttons for controlling the computation process

Outputs:
- 11 LEDs for displaying the tape values
- 1 LED for indicating "Halt" or reach end of memory

![](media/IO.png)
## How it Works
The chip initially stores all the inputs into a 4$\times$64 memory. It takes the bit at the tape head and look for the corresponding actions in the state transition table (default state is 1).

For instance, in the above example, the first bit in the tape would be 1, so it will go to state 1 with input 1 which has instruction 1 R q1. During the process, it displays the new tape value, rewrites it with 1, moves the tape head to the right, and goes to state 1.

After it has processed all the values on the tape, it will either go to "Halt" state where the tape stops moving, or it will reach the end of the tape and stops.

The diagram below is the RTL design to achieve this function.
![](media/Datapath.png)
![](media/FSM.png)
## Design Testing / Bringup
When testing the chip, input a valid Turing Machine state transition table and a initial tape value using the switches. Press the "Next" button to indicate the input can be taken, and press the "Done" button to indicate the end of the inputs.

The chip will then start to compute. The tape will move by 1 index after the "Next" button is pressed and the 11 LEDs will display the corresponding tape values. It will continue the process until the 12th LED lights up to indicate it finishes computing.

With the example provided before, the expected outputs from the LEDs are as below:
00000000000
00000000001
00000000011
00000000111
00000001111
00000011110
00000011111
00000111111
00001111111
00011111111
00011111110
00011111110
compute done
## Media
(optionally include any photos or videos of your design in action)
## (anything else)
If there is anything else you would like to document about your project
such as background information, design space exploration, future ideas,
verification details, references, etc etc. please add it here. This
template is meant to be a guideline, not an exact format that you're
required to follow.
