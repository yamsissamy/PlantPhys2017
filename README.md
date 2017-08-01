# PlantPhys2017
# AMBs.ijm

The purpose of this macro is to semi-automate the extraction of XY coordinates
form a manually segmented cell boundary and information about a second marker,
e.g. TuB6:GFP. 

## Getting Started

- Duplicate your time-lapse series image stacks and rename as follow T## starting
with number 1, i.e. T01, T02 etc. 
- When segmenting a cell boundary save the segment as an ROI with the following
format ##-##-##
The first set of is the time-point, e.g. 05
Second set of numbers are the z-slide from which the segment starts, e.g. 01
Third set of numbers are the z-slide from which the segment ends, e.g. 18. 
So, for the examples given above the user would save that segment ROI as
05-01-18. 
- When all time-points are collected, they should be saved as a ROIset in zip
file (in macro manager, select all and click 'save')

# How to use: 
- Drag the AMBs.ijm file and drop it on FIJI tool bar. 
- Press run and follow directions. 

## Authors

* **Samuel A. Belteton** - *Initial work*

# InputFiji.m

- The purpose of this matlab code is to use the information from AMBs.ijm macro and and analyze peaks for both the segment shape, i.e. lobes and from the AMBs signals. 
- Additionally, it calculates the lobe subregions for each identified lobe. 
- Calculates AMB intensity at 3-way junctions and center region of segment. 
- Calculates PCC as a function of time and location
- Saves '.svg' files for plots of segment and amb with peaks marked and lobes
subdivided. 
- Saves '.svg' file for persistence and calculates PCC for final segment shape
and total persistance. 

# Prerequisites

'.csv' and '.txt' files from AMB.ijm
Matlab 2016a
Follwing functions saved in the same folder: 
AMBLoc.m
InputFiji.m
MTA.m
PersisPlusShape.m
ROIA.m

# How to use: 
- In matlab go to folder containing functions, right click and add to path folder
and subfolders
- Navigate to folder containing '.csv' and '.txt' files
- On the command windows type InputFiji.m
- Press enter

## Authors

* **Samuel A. Belteton** - *Initial work* 
