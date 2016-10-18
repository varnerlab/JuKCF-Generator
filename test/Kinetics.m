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
% Function: Kinetics
% Description: Calculate the flux array at time t
% Generated on: 2016-10-18T10:21:44.892
%
% Input arguments:
% t::Float64 => Current time value (scalar) 
% x::Array{Float64,1} => State array (number_of_species x 1) 
% data_dictionary::Dict{AbstractString,Any} => Dictionary holding model parameters 
%
% Output arguments:
% flux_array::Array{Float64,1} => Flux array (number_of_rates x 1) at time t 
% ----------------------------------------------------------------------------------- %
function flux_array = Kinetics(t,x,data_dictionary)
	flux_array = calculate_flux_array(t,x,data_dictionary);
return

function kinetic_flux_array = calculate_flux_array(t,x,data_dictionary)

	% Get data from the data_dictionary - 
	rate_constant_array = data_dictionary.rate_constant_array;
	saturation_constant_array = data_dictionary.saturation_constant_array;

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

	% Write the kinetics functions - 
	kinetic_flux_array = [];

	% 1 [] --> A
	flux = rate_constant_array(1)*(E_reaction_0);
	kinetic_flux_array = [kinetic_flux_array ; flux];

	% 2 A --> B
	flux = rate_constant_array(2)*(E_reaction_1)*(A)/(saturation_constant_array(1)+A);
	kinetic_flux_array = [kinetic_flux_array ; flux];

	% 3 B --> A
	flux = rate_constant_array(3)*(E_reaction_1)*(B)/(saturation_constant_array(2)+B);
	kinetic_flux_array = [kinetic_flux_array ; flux];

	% 4 A --> C
	flux = rate_constant_array(4)*(E_reaction_2)*(A)/(saturation_constant_array(3)+A);
	kinetic_flux_array = [kinetic_flux_array ; flux];

	% 5 C --> B
	flux = rate_constant_array(5)*(E_reaction_3)*(C)/(saturation_constant_array(4)+C);
	kinetic_flux_array = [kinetic_flux_array ; flux];

	% 6 B --> []
	flux = rate_constant_array(6)*(E_reaction_4)*(B)/(saturation_constant_array(5)+B);
	kinetic_flux_array = [kinetic_flux_array ; flux];

	% 7 C --> []
	flux = rate_constant_array(7)*(E_reaction_5)*(C)/(saturation_constant_array(6)+C);
	kinetic_flux_array = [kinetic_flux_array ; flux];

	% 8 E_reaction_0 --> []
	flux = rate_constant_array(8)*(E_reaction_0);
	kinetic_flux_array = [kinetic_flux_array ; flux];

	% 9 E_reaction_1 --> []
	flux = rate_constant_array(9)*(E_reaction_1);
	kinetic_flux_array = [kinetic_flux_array ; flux];

	% 10 E_reaction_2 --> []
	flux = rate_constant_array(10)*(E_reaction_2);
	kinetic_flux_array = [kinetic_flux_array ; flux];

	% 11 E_reaction_3 --> []
	flux = rate_constant_array(11)*(E_reaction_3);
	kinetic_flux_array = [kinetic_flux_array ; flux];

	% 12 E_reaction_4 --> []
	flux = rate_constant_array(12)*(E_reaction_4);
	kinetic_flux_array = [kinetic_flux_array ; flux];

	% 13 E_reaction_5 --> []
	flux = rate_constant_array(13)*(E_reaction_5);
	kinetic_flux_array = [kinetic_flux_array ; flux];

return;

