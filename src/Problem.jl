function generate_problem_object(statement_vector::Array{VFFSentence})

  # Initilize an empty problem object -
  problem_object::ProblemObject = ProblemObject()

  # construct the array of species -
  species_array::Array{SpeciesObject} = build_species_list(statement_vector)

  # construct the array of reactions -
  reaction_array::Array{ReactionObject} = build_reaction_list(statement_vector)

  # Add enzymes to species array -
  append_enzymes_to_species_list!(species_array,statement_vector)

  # Add enzyme degradation rates to list of reaction_array -
  append_enzyme_degradation_to_reaction_list!(reaction_array,statement_vector)

  # partition the reactions -
  partition!(reaction_array)

  # set data on problem_object -
  problem_object.list_of_species = species_array
  problem_object.list_of_reactions = reaction_array

  # return#the problem_object -
  return problem_object
end

function append_enzyme_degradation_to_reaction_list!(list_of_reactions::Array{ReactionObject},list_of_statements::Array{VFFSentence})

  # Create local list of reactions -
  set_of_original_sentences::Set{AbstractString} = Set{AbstractString}()

  for sentence_object in list_of_statements

    # get reaction name -
    original_sentence = sentence_object.original_sentence
    reaction_name = sentence_object.sentence_name
    enyzme_generation_flag = sentence_object.sentence_type_flag

    # Do we have this in our set?
    if (in(original_sentence,set_of_original_sentences) == false && enyzme_generation_flag == 1)

      # create a degradation reaction -
      degradation_reaction::ReactionObject = ReactionObject()
      degradation_reaction.enyzme_generation_flag = 0

      # is_reaction_reversible::Bool
      # reaction_name::AbstractString
      # list_of_reactants::Array{SpeciesObject}
      # list_of_products::Array{SpeciesObject}

      degradation_reaction.is_reaction_reversible = false
      degradation_reaction.reaction_name = "$(reaction_name)"

      # create an enzyme (reactant ..)
      enzyme_object::SpeciesObject = SpeciesObject()
      enzyme_object.species_type = :enzyme
      enzyme_object.species_compartment = :unbalanced
      enzyme_object.stoichiometric_coefficient = 1.0
      enzyme_object.species_symbol = "E_$(reaction_name)"

      # create reactant list -
      list_of_reactants::Array{SpeciesObject} = SpeciesObject[]
      push!(list_of_reactants,enzyme_object)

      # create product list -
      list_of_products::Array{SpeciesObject} = SpeciesObject[]
      system_object::SpeciesObject = SpeciesObject()
      system_object.species_type = :system
      system_object.species_compartment = :unbalanced
      system_object.species_symbol = "[]"
      system_object.stoichiometric_coefficient = 1.0
      push!(list_of_products,system_object)

      # add -
      degradation_reaction.list_of_reactants = list_of_reactants
      degradation_reaction.list_of_products = list_of_products

      # Add to list of reactions -
      push!(list_of_reactions,degradation_reaction)

      # add reaction to set -
      push!(set_of_original_sentences,original_sentence)
    end
  end
end

function append_enzymes_to_species_list!(list_of_species::Array{SpeciesObject},list_of_statements::Array{VFFSentence})

  # Create local list of reactions -
  set_of_original_sentences::Set{AbstractString} = Set{AbstractString}()

  for sentence_object in list_of_statements

    # get reaction name -
    original_sentence = sentence_object.original_sentence
    reaction_name = sentence_object.sentence_name
    enyzme_generation_flag = sentence_object.sentence_type_flag

    # Do we have this in our set?
    if (in(original_sentence,set_of_original_sentences) == false && enyzme_generation_flag == 1)

      # create an enzyme -
      enzyme_object::SpeciesObject = SpeciesObject()
      enzyme_object.species_type = :enzyme
      enzyme_object.species_compartment = :unbalanced
      enzyme_object.species_symbol = "E_$(reaction_name)"

      # add to species list -
      push!(list_of_species,enzyme_object)

      # Add sentence to set -
      push!(set_of_original_sentences,original_sentence)
    end
  end
end

function build_reaction_list(statement_vector::Array{VFFSentence})

  # Initialize an empty array -
  reaction_array::Array{ReactionObject} = ReactionObject[]

  # Iterate through senetences, build reaction list -
  for vff_sentence in statement_vector

    # build an empty reaction object -
    reaction_object::ReactionObject = ReactionObject()

    # grab the reactant and product strings -
    reactant_string = vff_sentence.sentence_reactant_clause
    product_string = vff_sentence.sentence_product_clause
    enyzme_generation_flag = vff_sentence.sentence_type_flag

    # recatants -
    list_of_reactants::Array{SpeciesObject} = SpeciesObject[]
    build_species_list!(reactant_string,list_of_reactants)

    # products -
    list_of_products::Array{SpeciesObject} = SpeciesObject[]
    build_species_list!(product_string,list_of_products)

    # populate -
    reaction_object.is_reaction_reversible = false
    reaction_object.enyzme_generation_flag = enyzme_generation_flag
    reaction_object.list_of_reactants = list_of_reactants
    reaction_object.list_of_products = list_of_products
    reaction_object.reaction_name = vff_sentence.sentence_name

    # store -
    push!(reaction_array,reaction_object)
  end

  # return -
  return reaction_array
end

function is_species_balanced(species_symbol::AbstractString)

  # default: yes -
  symbol_length = length(species_symbol)
  if (symbol_length<3)
    return true
  end

  # ok = the symbol is long enough .. check for a trailing _u
  suffix = species_symbol[(symbol_length-2):end]

  # Compartment?
  if (contains(suffix,"_u") == true)
    return false
  else
    return true
  end
end

function build_species_list!(reaction_clause::AbstractString,list_of_species::Array{SpeciesObject})

  if (contains(reaction_clause,"+") == true)

    # split around the +, and recursivley call me ..
    tmp_split_array = split(reaction_clause,"+")
    for fragment in tmp_split_array
      build_species_list!(fragment,list_of_species)
    end

  else

    species_object::SpeciesObject = SpeciesObject()

    # ok, no +, but maybe still a stoichiometric_coefficient -
    if (contains(reaction_clause,"*") == true)

      symbol = strip(split(reaction_clause,"*")[end])
      coefficient = split(reaction_clause,"*")[1]

      if (symbol != "[]")

        # Build the species object -
        species_object.species_index = 0.0
        species_object.species_type = :metabolite
        species_object.species_symbol = symbol
        species_object.stoichiometric_coefficient = parse(Float64,coefficient)

        if (is_species_balanced(symbol) == true)
          species_object.species_compartment = :balanced
        else
          species_object.species_compartment = :unbalanced
        end

        # add to list -
        push!(list_of_species,species_object)
      end
    else

      symbol = strip(reaction_clause)
      coefficient = 1.0

      if (symbol != "[]")

        # Build the species object -
        species_object.species_index = 0.0
        species_object.species_type = :metabolite
        species_object.species_symbol = symbol
        species_object.stoichiometric_coefficient = coefficient

        # Compartment?
        if (is_species_balanced(symbol) == true)
          species_object.species_compartment = :balanced
        else
          species_object.species_compartment = :unbalanced
        end

        # add to list -
        push!(list_of_species,species_object)
      end
    end
  end
end

function build_species_list(statement_vector::Array{VFFSentence})

  species_set::Set{AbstractString} = Set{AbstractString}()
  for vff_sentence in statement_vector

    @show vff_sentence

    # grab the handler -
    handler_symbol = vff_sentence.sentence_handler
    if (handler_symbol == :metabolic_reaction_handler)

      # grab the reactant and prodict strings -
      reactant_string = vff_sentence.sentence_reactant_clause
      product_string = vff_sentence.sentence_product_clause

      # build the sets -
      reactant_set = build_species_set_from_clause(reactant_string)
      product_set = build_species_set_from_clause(product_string)

      # add these to the species_set -
      for item in reactant_set
        push!(species_set,item)
      end

      for item in product_set
        push!(species_set,item)
      end

    end
  end

  # ok, I have a set of symbols = it should be unique, sort and then create an array of SpeciesObjets -
  tmp_species_array = AbstractString[]
  for species_symbol in species_set
    push!(tmp_species_array,species_symbol)
  end

  # sort this in place (alphbetical ..)
  sort!(tmp_species_array)

  # Finally ... build the list of SpeciesObjects -
  list_of_species = SpeciesObject[]
  for (index,species_symbol) in enumerate(tmp_species_array)

    # species_symbol::AbstractString
    # species_index::Int
    # stoichiometric_coefficient::Float64
    # species_compartment::Symbol

    species_object = SpeciesObject()
    species_object.species_symbol = species_symbol
    species_object.species_index = index
    species_object.stoichiometric_coefficient = 0.0
    species_object.species_type = :metabolite
    species_object.species_compartment = :unbalanced

    # push -
    push!(list_of_species,species_object)
  end

  # Super finally ... we need to sort this list of species objects, alphbetical and by compartment.
  # Balanced | Unbalanced -
  partition!(list_of_species)

  # return my sorted list of species objects -
  return list_of_species
end

function build_species_set_from_clause(reaction_clause::AbstractString)

  species_symbol_set::Set{AbstractString} = Set{AbstractString}()

  # does this reaction clause have a +?
  if (contains(reaction_clause,"+") == true)

    # split around the + -
    tmp_split_array = split(reaction_clause,"+")
    for fragment in tmp_split_array

      if (contains(fragment,"*") == true)
        value = strip(split(fragment,"*")[end])
        if (value != "[]")
          push!(species_symbol_set,value)
        end
      else
        if (strip(fragment) != "[]")
          push!(species_symbol_set,strip(fragment))
        end
      end
    end
  else

    # ok, no +, but maybe still a stoichiometric_coefficient -
    if (contains(reaction_clause,"*") == true)

      value = strip(split(reaction_clause,"*")[end])
      if (value != "[]")
        push!(species_symbol_set,value)
      end
    else

      # no + -or- *, so just a bare species -
      if (strip(reaction_clause) != "[]")
        push!(species_symbol_set,strip(reaction_clause))
      end
    end
  end

  return species_symbol_set
end
