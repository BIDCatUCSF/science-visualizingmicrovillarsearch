# science-visualizingmicrovillarsearch
Code for Science publication

This Repository stores the unique analysis code for the Science Publication; "Visualizing Dynamic Microvillar Search and Stabilization during Ligand Detection by T cells." Authors: En Cai, Kyle Marchuk, Peter Beemiller, Casey Beppler, Matthew G Rubashkin, Valerie M Weaver, Audrey Gérard, Tsung-Li Liu, Bi-Chang Chen, Eric Betzig, Frederic Bartumeus, and Matthew F Krummel. 2017

There are two main components to the files within:
1) The Lattice Light Sheet Microscopy analysis pipeline (CropTiffGUI, FractalDimensionThroughTime, ProtrusionAnalysis) primarily written by Kyle Marchuk, PhD
2) The Synaptic Contact Mapping analysis pipeline (Contour, Ndnderizer, segemntationautomation) primarily written by Pete Beemiller, PhD

CropTIFFFUI is a standalone GUI used to crop a series of .tif files in 3D.
ProtrusionAnalysis is a standlone GUI for the main protrusion coverage analysis.
FractalDimensionThrough time is a simple script to calculate the fractal dimension of each slice of a binary .tif stack.

Ndnderizer is an Imaris XT used for loading .tif intil Imaris.
Contour is for segmentation of the cell region.
segmentationautomation of for finding the Qdot "holes" in the cell region.

Contact BIDC@UCSF.edu (address to Kyle) for questions regarding the code.
