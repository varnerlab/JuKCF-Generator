## Kinetic Cell Free Models Generator in Julia (JuKCF-Generator)

### Introduction ###
JuKCF-Generator is a code generation system for Cell Free Metabolic Models (CFMM) written in the Julia programming language. JuKCF-Generator transforms a simple comma/space delimited flat-file into fully commented cell free kinetic model code in the MATLAB, Octave or Julia programming languages. 

### Installation and Requirments
You can download this repository as a zip file, or clone or pull it by using the command (from the command-line):

	$ git pull https://github.com/varnerlab/JuKCF-Generator.git

or

	$ git clone https://github.com/varnerlab/JuKCF-Generator.git

To execute a code generation job, Julia must be installed on your machine along with the Julia packages ``ArgParse`` and ``JSON``. 
Julia can be downloaded/installed on any platform. 
The required Julia packages can be installed by executing the commands:

	julia> Pkg.add("ArgParse")

and
	
	julia> Pkg.add("JSON")

in the Julia REPL.  

### How do I generate model code? ###
To generate a CFMM, issue the command ``make_<output>_model.jl`` from the command line, where ``<output>`` is replaced by your desired model type (MATLAB, Octave or Julia). For example, to generated a CFMM in the MATLAB programming language, issue the command:

	$ julia make_matlab_model.jl -m <input path> -o <output path> 
	
The ``make_<output>_model.jl`` command takes four command line arguments:

Argument | Required | Default | Description 
--- | --- | --- | ---
-m | Yes	| none | Path to model input file
-o | No	| current directory | Path where files are written
-s | No	| ODE15s, LSODE or ODE | ODE solver used to solve the CFMM
-r | No	| F = Fed batch | Reactor configuration (F = Fed batch, B = batch and C = Continous)

### Can we test the installation? ###
To test your installation, an example ``Model.net`` file (the flat-file containing the biology to be generated) is contained within the ``<root>/test`` directory. For example, to generate test code in the Octave programming language, issue the command (from the project ``<root>`` directory):

	$ julia make_octave_model.jl -m ./test/Model.net -o ./test

This will transform ``Model.net`` into Octave code written to the ``<root>/test`` directory. JuKCF-Generator overwrites all files, so if you have hand edited any of the files, please back these up.

### Format for the model input file ###
JuKCF-Generator transforms structured flat files into CFMM code. JuKCF-Generator takes flat files of the form:

~~~
// ------------------------------------------------------------------ //
// Metabolic reactions -
#pragma::metabolic_reaction_handler
//
// Record:
// name (unique),{1|0},reactant_string,product_string,reverse,forward
// ------------------------------------------------------------------ //
reaction_0,[],[],A,0,inf
reaction_1,[],A,B,-inf,inf
reaction_2,[],A,C,0,inf
reaction_3,[],C,B,0,inf
reaction_4,[],B,[],0,inf
reaction_5,[],C,[],0,inf

// ------------------------------------------------------------------ //
// Control statements -
#pragma::control_statement_handler
//
// Record:
// actor {inhibits|activates} target (reaction_name)
// ------------------------------------------------------------------ //
B inhibits reaction_2
A activates reaction_1
~~~


### Repository directory layout ###
The JuKCF-Generator code is contained in the ``<root>/src`` subdirectory of the repository. Language specific generation logic is contained in the ``<root>/src/strategy`` subdirectory in the ``JuliaStrategy.jl``, ``MatlabStrategy.jl`` and ``OctaveStrategy.jl`` files. Common logic copied directly into the output directory is contained in the ``<root>/distribution`` and ``<root>/include`` subdirectories.  


