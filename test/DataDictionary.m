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
% Generated on: 2016-09-27T14:11:19.542
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

