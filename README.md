# Modeling Human-in-the-Loop Behavior and Interactions with HVAC Systems
This code was used to generate the results in the following manuscript

> Kane, M.B., *"Modeling Human-in-the-Loop Behavior and Interactions with HVAC Systems"* in proceedings of American Control Conference 2018 (ACC2018). Milwaukee, WI June 2018

## Usage
Run `HuiL_HVAC_cases.m` to reproduce the figures from the manuscript.

## Architecture

### MATLAB Files
* `HuiL_HVAC_cases.m` - Script to generate the plot shown in the paper, and plots of all the states during each of the tuning and test cases.
* `HuiL_HVAC_mdl_all_sim.m` - Function that runs the Simulink model through the test procedure, where the model and test can be modified using the function's input arguments in name-value pairs. Outputs a `resuts` structure.
* `HuiL_HVAC_plot_all.m` - Function that plots the all the states of the model throughout the simulation `results`.
* `HuiL_HVAC_plot_paper.m` - Function that creates the plot as shown in the manuscript. Use with the `results` from Case 1.

### Simulink Models
* `HuiL_HVAC_all.slx` - The main Simulink model of the HuiL HVAC system. Calls `SCT_mdl.slx`.
* `SCT_mdl.slx` - The Simulink model of the SCT model.

### Documents
* `2018ACC_Kane_Hybrid_Framework.pdf` Pre-print of manuscript.

## Dependencies
Tested with `MATLAB R2017a` with Simulink.
