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
% Function: Control
% Description: Calculate the allosteric control array at time t
% Generated on: 2016-10-18T05:05:18.768
%
% Input arguments:
% t::Float64 => Current time value (scalar) 
% x::Array{Float64,1} => State array (number_of_species x 1) 
% data_dictionary::Dict{AbstractString,Any} => Dictionary holding model parameters 
%
% Output arguments:
% control_array::Array{Float64,1} => Transcriptional control array (number_of_genes x 1) at time t 
% ----------------------------------------------------------------------------------- %
function control_array = Control(t,x,rate_array,data_dictionary)

	% Initialize the control array - 
	control_array = ones(length(rate_array),1);

	% Alias the species array (helps with debuging) - 
	A = x(1);
	B = x(2);
	C = x(3);
	E_reaction_0 = x(4);
	E_reaction_1 = x(5);
	E_reaction_2 = x(6);
	E_reaction_3 = x(7);
	E_reaction_4 = x(8);
	E_reaction_5 = x(9);

	% Alias control parameters - 
	control_parameter_array = data_dictionary.control_parameter_array;
	N_A_reaction_1 = control_parameter_array(1);
	K_A_reaction_1 = control_parameter_array(2);
	gain_A_reaction_1 = control_parameter_array(3);
	N_B_reaction_2 = control_parameter_array(4);
	K_B_reaction_2 = control_parameter_array(5);

	% list of control statements -
	% A activates reaction_1
	% B inhibits reaction_2

	transfer_function_buffer = [];
	tmp_value = gain_A_reaction_1*(A^(N_A_reaction_1)/(K_A_reaction_1^(N_A_reaction_1)+A^(N_A_reaction_1)));
	transfer_function_buffer = [transfer_function_buffer tmp_value];
	control_array(2) = max(transfer_function_buffer);

	transfer_function_buffer = [];
	tmp_value = B^(N_B_reaction_2)/(K_B_reaction_2^(N_B_reaction_2)+B^(N_B_reaction_2));
	transfer_function_buffer = [transfer_function_buffer 1-tmp_value];
	control_array(4) = min(transfer_function_buffer);

return
