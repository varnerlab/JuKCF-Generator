% ----------------------------------------------------------------------------------- %
% Copyright (c) 2016 Varnerlab
% School of Chemical Engineering Purdue University
% W. Lafayette IN 46907 USA

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
% SolveBalances: Solves model equations from TSTART to TSTOP given parameters in data_dictionary.
% Type: JuKCF-Matlab
% Version: 1.0
%
% Input arguments:
% TSTART  - Time start
% TSTOP  - Time stop
% Ts - Time step
% data_dictionary  - Data dictionary instance (holds model parameters)
%
% Return arguments:
% TSIM - Simulation time vector
% X - Simulation state array (NTIME x NSPECIES)
% ----------------------------------------------------------------------------------- %
function [TSIM,X] = SolveBalances(TSTART,TSTOP,Ts,data_dictionary)

  % Setup the time scale -
	TSIM = TSTART:Ts:TSTOP;

	% Get the ICs -
	initial_condition_array = data_dictionary.initial_condition_array;

	% Call LSODE -
	pBalanceEquations = @(x,t)Balances(x,t,data_dictionary);
	X = ode15s(pBalanceEquations,initial_condition_array,TSIM);

  % Check and correct for negatives -
  idx_negative = find(X<0);
  X(idx_negative) = 0.0;

return
