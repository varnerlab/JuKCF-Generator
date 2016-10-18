% ----------------------------------------------------------------------------------- %
% Copyright (c) 2016 Varnerlab
% Robert Frederick School of Chemical and Biomolecular Engineering
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
%
% ----------------------------------------------------------------------------------- %
% Balances: Evaluates model equations given time, state and the data_dictionary.
% Type: JuKCF-Octave
% Version: 1.0
%
% Input arguments:
% t  - current time
% x  - state array
% data_dictionary  - Data dictionary instance (holds model parameters)
%
% Return arguments:
% dxdt - derivative array at current time step
% ----------------------------------------------------------------------------------- %
function dxdt = Balances(x,t,data_dictionary)

  % Get the stoichiometric_matrix -
  stoichiometric_matrix = data_dictionary.stoichiometric_matrix;

  % Call the kinetics function -
  rate_array = Kinetics(t,x,data_dictionary);

  % Call the control function -
  control_array = Control(t,x,rate_array,data_dictionary);

  % Call the dilution function -
  dilution_array = Dilution(t,x,data_dictionary);

  % Modify the rate array -
  rate_array = rate_array.*control_array;

  % Calculate the dxdt for chemical species -
  dxdt = stoichiometric_matrix*rate_array+dilution_array;

return
