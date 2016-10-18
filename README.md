## Kinetic Cell Free Models Generator in Julia (JuKCF-Generator)

### Introduction ###
JuKCF-Generator is a code generation system for Cell Free Metabolic Models (CFMM) written in the [Julia](http://julialang.org) programming language. JuKCF-Generator transforms a simple comma/space delimited flat-file into fully commented cell free kinetic model code in the [MATLAB](https://www.mathworks.com/products/matlab/), [Octave](https://www.gnu.org/software/octave/) or [Julia](http://julialang.org) programming languages. The JuKCF-Generator framework generates a dynamic model of cell free metabolism using the hybrid modeling framework of Wayman et al:

[Wayman J, Sagar A and J. Varner (2015) Dynamic Modeling of Cell Free Biochemical Networks using Effective Kinetic Models. Processes DOI:10.3390/pr3010138](http://www.mdpi.com/2227-9717/3/1/138)

### Installation and Requirements
You can download this repository as a zip file, or clone or pull it by using the command (from the command-line):

	$ git pull https://github.com/varnerlab/JuKCF-Generator.git

or

	$ git clone https://github.com/varnerlab/JuKCF-Generator.git

To execute a code generation job, Julia must be installed on your machine along with the Julia packages ``ArgParse`` and ``JSON``. 
Julia can be downloaded/installed on any platform. 
The required [Julia](http://julialang.org) packages can be installed by executing the commands:

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
-s | No	| [ODE15s](https://www.mathworks.com/help/matlab/ref/ode15s.html), [LSODE](https://www.gnu.org/software/octave/doc/v4.0.1/Ordinary-Differential-Equations.html) or [ODE](https://github.com/JuliaDiffEq/ODE.jl) | ODE solver used to solve the CFMM
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

The model specification file (by default given the filename `Model.net`) defines the biology of the model that gets generated. A cell free flat file contains two sections, the metabolic reaction section (top) and the allosteric regulation section (bottom). 

__Metabolic records__: Metabolic reaction records contain six fields:

~~~
Name (unique),enzyme {[],1|0},reactants,products,reverse {0|-inf},forward {0|inf};
~~~

The reaction name field *__must be unique__*, and should not contain any commas or spaces. The enzyme field controls whether an enzyme is explcitly generated. In the current version, always use ``[]`` in this field. The reactant and product strings share a similar structure:

~~~
{stochiometric coefficient | 1.0}*{metabolite symbol}+...
~~~

Stoichiometric coefficients can be either integers or float values, and metabolite symbols must not contain commas, spaces or other crazy characters (underscores are ok). Also, metabolite symbols cannot start with a number. The special metabolite symbol `[]` denotes the `SYSTEM`, a infinite source or sink. There must be no spaces between the +'s in the reactant or product strings. By default, all stoichiometric coefficients are assumed to be `1.0`, thus there is no need to specify a coefficient if it is not different from `1.0`. The directionality strings let JuKCF know if we should generate a reverse reaction. It is assumed that all reactions are non-negative; if a reaction is reversible, two irreversible reactions are generated by JuKCF. 


__Allosteric regulation records__: One of the unique aspects of the cell free modeling framework of Wayman et al., is the inclusion of allosteric control terms. These terms are specified by allosteric records in the cell free flat file. Allosteric records, which contain three fields, take the form of simple natural language statements:

~~~
actor type {inhibits|activates} target
~~~

The first field of an allosteric record is an ``actor`` field, which is the symbol of the regulator metabolite. Next comes the ``type`` field which is specified by string literals `inhibits` or `activates`. The `type` field __is__ case sensitive. Lastly, the `target` field is the reaction name that is regulated. 

### Repository directory layout ###
The JuKCF-Generator code is contained in the ``<root>/src`` subdirectory of the repository. Language specific generation logic is contained in the ``<root>/src/strategy`` subdirectory in the ``JuliaStrategy.jl``, ``MatlabStrategy.jl`` and ``OctaveStrategy.jl`` files. Common logic copied directly into the output directory is contained in the ``<root>/distribution`` and ``<root>/include`` subdirectories.  


