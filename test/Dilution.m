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
% Generated on: 2016-10-17T16:01:54.716
%
% Input arguments:
% t::Float64 => Current time value (scalar) 
% x::Array{Float64,1} => State array (number_of_species x 1) 
% data_dictionary::Dict{AbstractString,Any} => Dictionary holding model parameters 
%
% Output arguments:
% flux_array::Array{Float64,1} => Flux array (number_of_rates x 1) at time t 
% ----------------------------------------------------------------------------------- %
function dilution_array = Dilution(t,x,data_dictionary)

  # volume is the last species -
  volume = x(end)

  # How many species do we have?
  number_of_species = length(x);

  % Get flow rate array et al from the data_dictionary -
  flowrate_array = data_dictionary.volumetric_flowrate_array;
  feed_composition_array = data_dictionary.material_feed_concentration_array;

  % What is the current dilution rate?
  if (isempty(flowrate_array) == false)
    flow_rate = interp1(flowrate_array(:,1),flowrate_array(:,2),t);
    dilution_rate = (flow_rate)/(volume);
  else
    flow_rate = 0.0;
    dilution_rate = 0.0;
  end

  % initialize the diltion array -
  dilution_array = zeros(number_of_species,1);

  % Compute -
  for species_index = 1:number_of_species - 1
    dilution_array(species_index,1) = dilution_rate*(feed_composition_array(species_index) - x(species_index));
  end

  % Last element is F -
  dilution_array(end,1) = flow_rate;

return
