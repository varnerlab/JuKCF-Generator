% ----------------------------------------------------------------------------------- %
% Copyright (c) 2016 Varnerlab
% Robert Frederick Smith School of Chemical and Biomolecular Engineering
% Cornell University, Ithaca NY 14850
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
% ----------------------------------------------------------------------------------- %
#
% ----------------------------------------------------------------------------------- %
% Function: DataDictionary
% Description: Holds simulation and model parameters as key => value pairs in a Julia Dict()
% Generated on: 2016-10-17T16:49:09.043
%
% Input arguments:
% time_start::Float64 => Simulation start time value (scalar)
% time_stop::Float64 => Simulation stop time value (scalar)
% time_step::Float64 => Simulation time step (scalar)
%
% Output arguments:
% data_dictionary::Dict{AbstractString,Any} => Dictionary holding model and simulation parameters as key => value pairs
% ----------------------------------------------------------------------------------- %
function data_dictionary = DataDictionary(time_start,time_stop,time_step)

	% Load the stoichiometric network from disk -
	stoichiometric_matrix = load("./Network.dat");

	% Augment the stoichiometric matrix w/volume row (row of zeros) -
	[number_of_rows,number_of_cols] = size(stoichiometric_matrix);
	stoichiometric_matrix = [stoichiometric_matrix ; zeros(1,number_of_cols)];

	% Initialize the intial condition array for species -
	initial_condition_array = [
		10.0	;	% 1 1 A	(units: mM)
		0.0	;	% 2 2 B	(units: mM)
		0.0	;	% 3 3 C	(units: mM)
		0.0004	;	% 4 4 E_reaction_0	(units: mM)
		0.0004	;	% 5 5 E_reaction_1	(units: mM)
		0.0004	;	% 6 6 E_reaction_2	(units: mM)
		0.0004	;	% 7 7 E_reaction_3	(units: mM)
		0.0004	;	% 8 8 E_reaction_4	(units: mM)
		0.0004	;	% 9 9 E_reaction_5	(units: mM)
		1.0	;	% 10 Volume	(units: L)
	];

	% Setup rate constant array -
	rate_constant_array = [
		0.0	;	% 1	(units: 1/min)	reaction_0::[] --> A
		25000.0	;	% 2	(units: 1/min)	reaction_1::A --> B
		25000.0	;	% 3	(units: 1/min)	reaction_1_reverse::B --> A
		25000.0	;	% 4	(units: 1/min)	reaction_2::A --> C
		25000.0	;	% 5	(units: 1/min)	reaction_3::C --> B
		25000.0	;	% 6	(units: 1/min)	reaction_4::B --> []
		25000.0	;	% 7	(units: 1/min)	reaction_5::C --> []
		0.0023104906018664843	;	% 8	(units: 1/min)	E_degrade_reaction_0::E_reaction_0 --> []
		0.0023104906018664843	;	% 9	(units: 1/min)	E_degrade_reaction_1::E_reaction_1 --> []
		0.0023104906018664843	;	% 10	(units: 1/min)	E_degrade_reaction_2::E_reaction_2 --> []
		0.0023104906018664843	;	% 11	(units: 1/min)	E_degrade_reaction_3::E_reaction_3 --> []
		0.0023104906018664843	;	% 12	(units: 1/min)	E_degrade_reaction_4::E_reaction_4 --> []
		0.0023104906018664843	;	% 13	(units: 1/min)	E_degrade_reaction_5::E_reaction_5 --> []
	];

	% Setup saturation constant array -
	saturation_constant_array = [
		0.05	;	% 1 K_R2_A	(units: mM)
		0.05	;	% 2 K_R3_B	(units: mM)
		0.05	;	% 3 K_R4_A	(units: mM)
		0.05	;	% 4 K_R5_C	(units: mM)
		0.05	;	% 5 K_R6_B	(units: mM)
		0.05	;	% 6 K_R7_C	(units: mM)
	];

	% Setup list of control parameters -
	control_parameter_array = [
		1.0	;	%	 1	N_A_reaction_1
		1.0	;	%	 2	K_A_reaction_1
		1.0	;	%	 3	gain_A_reaction_1
		1.0	;	%	 4	N_B_reaction_2
		1.0	;	%	 5	K_B_reaction_2
	];

	% Setup the volumetric_flowrate_array -
	volumetric_flowrate_array = [];

	% Setup the feed concentrations -
	material_feed_concentration_array = [
		0.0	;	% 1	 A	(units: mM)
		0.0	;	% 2	 B	(units: mM)
		0.0	;	% 3	 C	(units: mM)
		0.0	;	% 4	 E_reaction_0	(units: mM)
		0.0	;	% 5	 E_reaction_1	(units: mM)
		0.0	;	% 6	 E_reaction_2	(units: mM)
		0.0	;	% 7	 E_reaction_3	(units: mM)
		0.0	;	% 8	 E_reaction_4	(units: mM)
		0.0	;	% 9	 E_reaction_5	(units: mM)
	];

	% =============================== DO NOT EDIT BELOW THIS LINE ============================== %
	data_dictionary = [];
	data_dictionary.initial_condition_array = initial_condition_array;
	data_dictionary.total_number_of_states = length(initial_condition_array);
	data_dictionary.stoichiometric_matrix = stoichiometric_matrix;
	data_dictionary.volumetric_flowrate_array = volumetric_flowrate_array;
	data_dictionary.material_feed_concentration_array = material_feed_concentration_array;
	data_dictionary.rate_constant_array = rate_constant_array;
	data_dictionary.saturation_constant_array = saturation_constant_array;
	data_dictionary.control_parameter_array = control_parameter_array;
	% =============================== DO NOT EDIT ABOVE THIS LINE ============================== %
return
