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

### Repository directory layout ###
The JuKCF-Generator code is contained in the ``<root>/src`` subdirectory of the repository. Language specific generation logic is contained in the ``<root>/src/strategy`` subdirectory in the ``JuliaStrategy.jl``, ``MatlabStrategy.jl`` and ``OctaveStrategy.jl`` files. Common logic copied directly into the output directory is contained in the ``<root>/distribution`` and ``<root>/include`` subdirectories.  


