function build_function_header_buffer(comment_dictionary)

  # initialize -
  buffer = ""

  # get some data from the comment_dictionary -
  function_name = comment_dictionary["function_name"]
  function_description = comment_dictionary["function_description"]
  input_arg_array = comment_dictionary["input_args"]
  output_arg_array = comment_dictionary["output_args"]

  buffer *= "% ----------------------------------------------------------------------------------- %\n"
  buffer *= "% Function: $(function_name)\n"
  buffer *= "% Description: $(function_description)\n"
  buffer *= "% Generated on: $(now())\n"
  buffer *= "%\n"
  buffer *= "% Input arguments:\n"

  for argument_dictionary in input_arg_array

    arg_symbol = argument_dictionary["symbol"]
    arg_description = argument_dictionary["description"]

    # write the buffer -
    buffer *= "% $(arg_symbol) => $(arg_description) \n"
  end

  buffer *= "%\n"
  buffer *= "% Output arguments:\n"
  for argument_dictionary in output_arg_array

    arg_symbol = argument_dictionary["symbol"]
    arg_description = argument_dictionary["description"]

    # write the buffer -
    buffer *= "% $(arg_symbol) => $(arg_description) \n"
  end
  buffer *= "% ----------------------------------------------------------------------------------- %\n"

  # return the buffer -
  return buffer
end


function build_copyright_header_buffer(problem_object::ProblemObject)

  # What is the current year?
  current_year = string(Dates.year(now()))

  buffer = ""
  buffer*= "% ----------------------------------------------------------------------------------- %\n"
  buffer*= "% Copyright (c) $(current_year) Varnerlab\n"
  buffer*= "% Robert Frederick Smith School of Chemical and Biomolecular Engineering\n"
  buffer*= "% Cornell University, Ithaca NY 14850\n"
  buffer*= "%\n"
  buffer*= "% Permission is hereby granted, free of charge, to any person obtaining a copy\n"
  buffer*= "% of this software and associated documentation files (the \"Software\"), to deal\n"
  buffer*= "% in the Software without restriction, including without limitation the rights\n"
  buffer*= "% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n"
  buffer*= "% copies of the Software, and to permit persons to whom the Software is\n"
  buffer*= "% furnished to do so, subject to the following conditions:\n"
  buffer*= "%\n"
  buffer*= "% The above copyright notice and this permission notice shall be included in\n"
  buffer*= "% all copies or substantial portions of the Software.\n"
  buffer*= "%\n"
  buffer*= "% THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n"
  buffer*= "% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n"
  buffer*= "% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n"
  buffer*= "% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n"
  buffer*= "% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n"
  buffer*= "% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n"
  buffer*= "% THE SOFTWARE.\n"
  buffer*= "% ----------------------------------------------------------------------------------- %\n"

  # return -
  return buffer
end

function build_data_dictionary_buffer(problem_object::ProblemObject,solver_option::Symbol,reactor_option::Symbol)

  filename = "DataDictionary.m"

  # build the header -
  header_buffer = build_copyright_header_buffer(problem_object)

  # get the comment buffer -
  comment_header_dictionary = problem_object.configuration_dictionary["function_comment_dictionary"]["data_dictionary_function"]
  function_comment_buffer = build_function_header_buffer(comment_header_dictionary)

  # Get the default -
  default_parameter_dictionary = problem_object.configuration_dictionary["default_parameter_dictionary"]
  enzyme_initial_condition = parse(Float64,default_parameter_dictionary["default_protein_initial_condition"])
  default_saturation_constant = default_parameter_dictionary["default_saturation_constant"]
  default_protein_half_life = parse(Float64,default_parameter_dictionary["default_protein_half_life"])
  default_rate_constant = parse(Float64,default_parameter_dictionary["default_enzyme_kcat"])
  default_upper_bound = default_rate_constant*enzyme_initial_condition

  @show default_upper_bound,default_rate_constant,enzyme_initial_condition

  #

  # initialize the buffer -
  buffer = ""
  buffer *= header_buffer
  buffer *= "#\n"
  buffer *= function_comment_buffer
  buffer *= "function data_dictionary = DataDictionary(time_start,time_stop,time_step)\n"
  buffer *= "\n"
  buffer *= "\t% Load the stoichiometric network from disk - \n"
  buffer *= "\tstoichiometric_matrix = load(\"./Network.dat\");\n"
  buffer *= "\n"

  # initialize the buffer -
  buffer = ""
  buffer *= header_buffer
  buffer *= "#\n"
  buffer *= function_comment_buffer
  buffer *= "function data_dictionary = DataDictionary(time_start,time_stop,time_step)\n"
  buffer *= "\n"
  buffer *= "\t% Load the stoichiometric network from disk - \n"
  buffer *= "\tstoichiometric_matrix = load(\"./Network.dat\");\n"
  buffer *= "\n"

  if (reactor_option == :F)
    buffer *= "\t% Augment the stoichiometric matrix w/volume row (row of zeros) - \n"
    buffer *= "\t[number_of_rows,number_of_cols] = size(stoichiometric_matrix);\n"
    buffer *= "\tstoichiometric_matrix = [stoichiometric_matrix ; zeros(1,number_of_cols)];\n"
    buffer *= "\n"
  end

  # write the ic for the unbalanced variables -
  buffer *= "\t% Initialize the intial condition array for species - \n"
  buffer *= "\tinitial_condition_array = [\n"
  list_of_species::Array{SpeciesObject} = problem_object.list_of_species
  counter = 1
  for (index,species_object) in enumerate(list_of_species)

    compartment_symbol::Symbol = species_object.species_compartment
    species_type::Symbol = species_object.species_type

    if (species_type == :metabolite)
      species_symbol = species_object.species_symbol
      buffer *= "\t\t0.0\t;\t% $(counter) $(index) $(species_symbol)\t(units: mM)\n"
      counter = counter + 1
    end

    if (species_type == :enzyme)
      species_symbol = species_object.species_symbol
      buffer *= "\t\t$(enzyme_initial_condition)\t;\t% $(counter) $(index) $(species_symbol)\t(units: mM)\n"
      counter = counter + 1
    end
  end

  # Check for reactor type -
  if (reactor_option == :F)
    buffer *= "\t\t1.0\t;\t% $(counter) Volume\t(units: L)\n"
  end

  buffer *= "\t];\n"
  buffer *= "\n"

  list_of_reactions::Array{ReactionObject} = problem_object.list_of_reactions
  buffer *= "\t% Setup rate constant array - \n"
  buffer *= "\trate_constant_array = [\n"
  for (index,reaction_object) in enumerate(list_of_reactions)

    reaction_string = reaction_object.reaction_name

    # Build comment string -
    comment_string = build_reaction_comment_string(reaction_object)

    # Set the default to 1.0 = but if enzyme degrdation reaction, then go to 0.01
    if (is_enzyme_degradation_reaction(reaction_object) == true)

      # Calculate the degrdation rate constant -
      default_rate_constant = -1*(1/default_protein_half_life)*log(1/2)

      # Build buffer -
      buffer *= "\t\t$(default_rate_constant)\t;\t% $(index)\t(units: 1/min)\t$(reaction_string)::$(comment_string)\n"
    else

      # Build the buffer -
      buffer *= "\t\t$(default_rate_constant)\t;\t% $(index)\t(units: 1/min)\t$(reaction_string)::$(comment_string)\n"
    end
  end
  buffer *= "\t];\n"
  buffer *= "\n"

  # Setup the saturation_constant_array -
  buffer *= "\t% Setup saturation constant array - \n"
  buffer *= "\tsaturation_constant_array = [\n"
  counter = 1
  for (reaction_index,reaction_object) in enumerate(list_of_reactions)

    # What type of reaction is this?
    reaction_type = reaction_object.reaction_type
    if (reaction_type == :kinetic)

      # Write the line -
      list_of_reactants = reaction_object.list_of_reactants
      for (species_index,species_object) in enumerate(list_of_reactants)

        # Get the symbol -
        species_type = species_object.species_type
        species_symbol = species_object.species_symbol
        stcoeff = species_object.stoichiometric_coefficient

        # If we have a *non-zero* coefficient -
        if (stcoeff != 0.0 && species_type != :enzyme)

          # buffer -
          buffer *= "\t\t$(default_saturation_constant)\t;\t% $(counter) K_R$(reaction_index)_$(species_symbol)\t(units: mM)\n"

          # update -
          counter = counter + 1
        end
      end
    end
  end

  buffer *= "\t];\n"
  buffer *= "\n"
  if (reactor_option == :F)
    buffer *= "\t% Setup the volumetric_flowrate_array - \n"
    buffer *= "\tvolumetric_flowrate_array = [];\n"
    buffer *= "\n"
    buffer *= "\t% Setup the feed concentrations - \n"
    buffer *= "\tmaterial_feed_concentration_array = [\n"
    for (index,species_object) in enumerate(list_of_species)

      # what is the species symbol?
      species_symbol = species_object.species_symbol

      buffer *= "\t\t0.0\t;\t% $(index)\t $(species_symbol)\t(units: mM)\n"
    end
    buffer *= "\t];\n"
  end

  buffer *= "\n"
  buffer *= "\t% =============================== DO NOT EDIT BELOW THIS LINE ============================== %\n"
  buffer *= "\tdata_dictionary = [];\n"
  buffer *= "\tdata_dictionary.initial_condition_array = initial_condition_array;\n"
  buffer *= "\tdata_dictionary.total_number_of_states = length(initial_condition_array);\n"
  buffer *= "\tdata_dictionary.stoichiometric_matrix = stoichiometric_matrix;\n"

  if (reactor_option == :F)
    buffer *= "\tdata_dictionary.volumetric_flowrate_array = volumetric_flowrate_array;\n"
    buffer *= "\tdata_dictionary.material_feed_concentration_array = material_feed_concentration_array;\n"
  end

  buffer *= "\tdata_dictionary.rate_constant_array = rate_constant_array;\n"
  buffer *= "\tdata_dictionary.saturation_constant_array = saturation_constant_array;\n"
  buffer *= "\t% =============================== DO NOT EDIT ABOVE THIS LINE ============================== %\n"
  buffer *= "return\n"

  # build the component -
  program_component::ProgramComponent = ProgramComponent()
  program_component.filename = filename
  program_component.buffer = buffer

  # return -
  return (program_component)
end

function build_dilution_buffer(problem_object::ProblemObject,solver_option::Symbol,reactor_option::Symbol)

  filename = "Dilution.m"

  # build the header -
  header_buffer = build_copyright_header_buffer(problem_object)

  # get the comment buffer -
  comment_header_dictionary = problem_object.configuration_dictionary["function_comment_dictionary"]["dilution_function"]
  function_comment_buffer = build_function_header_buffer(comment_header_dictionary)

  # initialize the buffer -
  buffer = ""
  buffer *= header_buffer
  buffer *= "#\n"
  buffer *= function_comment_buffer

  # Include the dilution function -
  dilution_function_buffer = @include_function_matlab "default_dilution_octave"
  buffer *= dilution_function_buffer

  # build the component -
  program_component::ProgramComponent = ProgramComponent()
  program_component.filename = filename
  program_component.buffer = buffer

  # return -
  return (program_component)
end

function build_control_buffer(problem_object::ProblemObject)

  filename = "Control.m"

  # build the header -
  header_buffer = build_copyright_header_buffer(problem_object)

  # get the comment buffer -
  comment_header_dictionary = problem_object.configuration_dictionary["function_comment_dictionary"]["control_function"]
  function_comment_buffer = build_function_header_buffer(comment_header_dictionary)

  # initialize the buffer -
  buffer = ""
  buffer *= header_buffer
  buffer *= "#\n"
  buffer *= function_comment_buffer
  buffer *= "function control_array = Control(t,x,rate_array,data_dictionary)\n"
  buffer *= "\n"
  buffer *= "\t% Initialize the control array - \n"
  buffer *= "\tcontrol_array = ones(length(rate_array),1);\n"
  buffer *= "\n"
  buffer *= "return\n"

  # build the component -
  program_component::ProgramComponent = ProgramComponent()
  program_component.filename = filename
  program_component.buffer = buffer

  # return -
  return (program_component)
end

function build_inputs_buffer(problem_object::ProblemObject)

  filename = "Inputs.m"

  # build the header -
  header_buffer = build_copyright_header_buffer(problem_object)

  # get the comment buffer -
  comment_header_dictionary = problem_object.configuration_dictionary["function_comment_dictionary"]["input_function"]
  function_comment_buffer = build_function_header_buffer(comment_header_dictionary)

  # initialize the buffer -
  buffer = ""
  buffer *= header_buffer
  buffer *= "#\n"
  buffer *= function_comment_buffer
  buffer *= "function input_array = Inputs(t,x,data_dictionary)\n"
  buffer *= "\tinput_array = calculate_input_array(t,x,data_dictionary);\n"
  buffer *= "return\n"
  buffer *= "\n"
  buffer *= "function input_array = calculate_input_array(t,x,data_dictionary)\n"
  buffer *= "\n"
  buffer *= "\t% Default input array - \n"
  buffer *= "\tinput_array = zeros(length(x),1);\n"
  buffer *= "return\n"

  # build the component -
  program_component::ProgramComponent = ProgramComponent()
  program_component.filename = filename
  program_component.buffer = buffer

  # return -
  return (program_component)
end

function build_kinetics_buffer(problem_object::ProblemObject,solver_option::Symbol)

  filename = "Kinetics.m"

  # build the header -
  header_buffer = build_copyright_header_buffer(problem_object)

  # get the comment buffer -
  comment_header_dictionary = problem_object.configuration_dictionary["function_comment_dictionary"]["kinetics_function"]
  function_comment_buffer = build_function_header_buffer(comment_header_dictionary)

  # initialize the buffer -
  buffer = ""
  buffer *= header_buffer
  buffer *= "#\n"
  buffer *= function_comment_buffer
  buffer *= "function flux_array = Kinetics(t,x,data_dictionary)\n"
  buffer *= "\tflux_array = calculate_flux_array(t,x,data_dictionary);\n"
  buffer *= "return\n"

  # Build the kinetic flux function -
  buffer *= "\n"
  buffer *= "function kinetic_flux_array = calculate_flux_array(t,x,data_dictionary)\n"
  buffer *= "\n"
  buffer *= "\t% Get data from the data_dictionary - \n"
  buffer *= "\trate_constant_array = data_dictionary.rate_constant_array;\n"
  buffer *= "\tsaturation_constant_array = data_dictionary.saturation_constant_array;\n"
  buffer *= "\n"
  buffer *= "\t% Alias the species array (helps with debuging) - \n"

  # Alias the species -
  list_of_enzymes::Array{AbstractString} = AbstractString[]
  list_of_species::Array{SpeciesObject} = problem_object.list_of_species
  for (index,species_object::SpeciesObject) in enumerate(list_of_species)

    # Get the species symbol -
    species_symbol = species_object.species_symbol

    # Write the line -
    buffer *= "\t$(species_symbol) = x($(index));\n"
  end
  buffer *= "\n"

  buffer *= "\t% Write the kinetics functions - \n"
  buffer *= "\tkinetic_flux_array = [];\n"
  buffer *= "\n"

  # extract the list of metabolic reactions -
  saturation_constant_counter = 1
  list_of_reactions::Array{ReactionObject} = problem_object.list_of_reactions
  list_of_metabolic_reactions::Array{ReactionObject} = extract_metabolic_reactions(list_of_reactions)

  @show list_of_reactions

  counter = 1
  for (index,reaction_object::ReactionObject) in enumerate(list_of_metabolic_reactions)

    # formulate the comment -
    comment_string = build_reaction_comment_string(reaction_object)
    reaction_type::Symbol = reaction_object.reaction_type
    reaction_name::AbstractString = reaction_object.reaction_name
    enyzme_generation_flag = reaction_object.enyzme_generation_flag

    @show reaction_name,enyzme_generation_flag

    # ok, write the start -
    buffer *= "\t% $(index) $(comment_string)\n"

    if (enyzme_generation_flag == 0)
      buffer *= "\tflux = rate_constant_array($(index))"
    else

      # Cutoff _revrese -
      if (contains(reaction_name,"_reverse") == true)
        local_enzyme_name = reaction_name[1:end-8]
        buffer *= "\tflux = rate_constant_array($(index))*(E_$(local_enzyme_name))"
      else
        local_enzyme_name = reaction_name
        buffer *= "\tflux = rate_constant_array($(index))*(E_$(local_enzyme_name))"
      end
    end

    # ok, get the list of reactants -
    local_list_of_reactants::Array{SpeciesObject} = reaction_object.list_of_reactants
    for (index,species_object) in enumerate(local_list_of_reactants)

      species_symbol = species_object.species_symbol
      species_type = species_object.species_type
      buffer *= "*($(species_symbol))/(saturation_constant_array($(saturation_constant_counter))+$(species_symbol))"

      # update -
      saturation_constant_counter = saturation_constant_counter + 1
    end

    # push -
    buffer *= ";\n"
    buffer *= "\tkinetic_flux_array = [kinetic_flux_array ; flux];\n"
    buffer *= "\n"

    counter = counter + 1
  end

  # extract the extract_enzyme_degradation_reactions -
  list_of_enzyme_degradation_reactions::Array{ReactionObject} = extract_enzyme_degradation_reactions(list_of_reactions)
  for (index,reaction_object::ReactionObject) in enumerate(list_of_enzyme_degradation_reactions)

    reaction_type::Symbol = reaction_object.reaction_type
    reaction_name::AbstractString = reaction_object.reaction_name

    # update the index -
    local_index = index + counter - 1

    # formulate the comment -
    comment_string = build_reaction_comment_string(reaction_object)

    # ok, write the start -
    buffer *= "\t% $(local_index) $(comment_string)\n"

    # ok, write the start -
    buffer *= "\tflux = rate_constant_array($(local_index))"

    # ok, get the list of reactants -
    local_list_of_reactants::Array{SpeciesObject} = reaction_object.list_of_reactants
    for (index,species_object) in enumerate(local_list_of_reactants)

      species_symbol = species_object.species_symbol
      species_type = species_object.species_type
      buffer *= "*($(species_symbol))"
    end

    # push -
    buffer *= ";\n"
    buffer *= "\tkinetic_flux_array = [kinetic_flux_array ; flux];\n"
    buffer *= "\n"
  end

  # return -
  buffer *= "return;\n"
  buffer *= "\n"

  # build the component -
  program_component::ProgramComponent = ProgramComponent()
  program_component.filename = filename
  program_component.buffer = buffer

  # return -
  return (program_component)
end

# ====== HELPER FUNCTIONS ================================================================================== #
function extract_enzyme_degradation_reactions(list_of_reactions::Array{ReactionObject})

  list_of_enzyme_degradation_reactions::Array{ReactionObject} = ReactionObject[]
  for (index,reaction_object::ReactionObject) in enumerate(list_of_reactions)

    # What is the reaction_type?
    reaction_type::Symbol = reaction_object.reaction_type

    # is this a metabolic_reaction?
    is_degradation_reaction::Bool = false
    if (reaction_type == :kinetic)

      # ok, we have a kinetic reaction - does it involve metabolites?
      list_of_reactants::Array{SpeciesObject} = reaction_object.list_of_reactants
      for species_object in list_of_reactants

        species_type::Symbol = species_object.species_type
        if (species_type == :enzyme)
          is_degradation_reaction = true
        end
      end

      if (is_degradation_reaction == true)
        push!(list_of_enzyme_degradation_reactions,reaction_object)
      end
    end
  end

  return list_of_enzyme_degradation_reactions
end

function extract_metabolic_reactions(list_of_reactions::Array{ReactionObject})

  list_of_metabolic_reactions::Array{ReactionObject} = ReactionObject[]
  for (index,reaction_object::ReactionObject) in enumerate(list_of_reactions)

    # What is the reaction_type?
    reaction_type::Symbol = reaction_object.reaction_type

    @show reaction_object

    # is this a metabolic_reaction?
    is_metabolic_reaction::Bool = false
    if (reaction_type == :kinetic)

      # ok, we have a kinetic reaction - does it involve metabolites?
      list_of_reactants::Array{SpeciesObject} = reaction_object.list_of_reactants
      if (isempty(list_of_reactants) == true)
        is_metabolic_reaction = true
      else

        for species_object in list_of_reactants

          species_type::Symbol = species_object.species_type
          if (species_type == :metabolite)
            is_metabolic_reaction = true
          end
        end
      end # end empty check if -

      if (is_metabolic_reaction == true)
        push!(list_of_metabolic_reactions,reaction_object)
      end
    end
  end

  return list_of_metabolic_reactions
end

function is_enzyme_degradation_reaction(reaction_object::ReactionObject)

  # Get the list of reactants -
  list_of_reactants::Array{SpeciesObject,1} = reaction_object.list_of_reactants
  if (length(list_of_reactants) == 1 && list_of_reactants[1].species_type == :enzyme)
    return true
  end

  return false
end
