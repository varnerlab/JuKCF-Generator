function parse_vff_control_statements(path_to_model_file::AbstractString)

  control_sentence_vector = VFFControlSentence[]
  tmp_array::Array{AbstractString} = AbstractString[]
  desired_handler_symbol::Symbol = :control_statement_handler
  current_handler_symbol::Symbol = :metabolic_reaction_handler

  try

    # Open the model file, and read each line into a vector -
    open(path_to_model_file,"r") do model_file
      for line in eachline(model_file)

          if (contains(line,"//") == false && search(line,"\n")[1] != 1)
            push!(tmp_array,chomp(line))
          end
      end
    end

    for sentence in tmp_array

      # check for #pragma -
      if (contains(sentence,"#pragma") == true)

        # split the sentence -
        split_array = split(sentence,"::")

        # grab handler -
        handler_string = split_array[2]
        if (handler_string == "metabolic_reaction_handler")
          current_handler_symbol = :metabolic_reaction_handler
        elseif (handler_string == "control_statement_handler")
          current_handler_symbol = :control_statement_handler
        end
      end

      # Depending upon the handler_symbol, we will process diff types of records -
      if (current_handler_symbol == desired_handler_symbol && contains(sentence,"#pragma") == false)

        control_statement_object = vff_control_statement_factory(sentence,current_handler_symbol)
        push!(control_sentence_vector,control_statement_object)
      end
    end

  catch err
    showerror(STDOUT, err, backtrace());println()
  end

  return control_sentence_vector

end


function parse_vff_metabolic_statements(path_to_model_file::AbstractString)

  # We are going to load the sentences in the file into a vector
  # if not a valid model file, then throw an error -
  sentence_vector = VFFSentence[]
  expanded_sentence_vector::Array{VFFSentence} = VFFSentence[]
  tmp_array::Array{AbstractString} = AbstractString[]
  desired_handler_symbol::Symbol = :metabolic_reaction_handler
  current_handler_symbol::Symbol = :metabolic_reaction_handler

  try

    # Open the model file, and read each line into a vector -
    open(path_to_model_file,"r") do model_file
      for line in eachline(model_file)

          if (contains(line,"//") == false && search(line,"\n")[1] != 1)
            push!(tmp_array,chomp(line))
          end
      end
    end

    for sentence in tmp_array

      # check for #pragma -
      if (contains(sentence,"#pragma") == true)

        # split the sentence -
        split_array = split(sentence,"::")

        # grab handler -
        handler_string = split_array[2]
        if (handler_string == "metabolic_reaction_handler")
          current_handler_symbol = :metabolic_reaction_handler
        elseif (handler_string == "control_statement_handler")
          current_handler_symbol = :control_statement_handler
        end
      end


      # Depending upon the handler_symbol, we will process diff types of records -
      if (current_handler_symbol == desired_handler_symbol && contains(sentence,"#pragma") == false)

        local_vff_sentence_array = vff_metabolic_sentence_factory(sentence,current_handler_symbol)
        @show local_vff_sentence_array

        for local_vff_sentence in collect(local_vff_sentence_array)
          push!(expanded_sentence_vector,local_vff_sentence)
        end
      end
    end

  catch err
    showerror(STDOUT, err, backtrace());println()
  end

  return expanded_sentence_vector
end

function parse_vff_file(path_to_model_file::AbstractString)

  # We are going to load the sentences in the file into a vector
  # if not a valid model file, then throw an error -
  sentence_vector = VFFSentence[]
  expanded_sentence_vector::Array{VFFSentence} = VFFSentence[]
  tmp_array::Array{AbstractString} = AbstractString[]
  handler_symbol::Symbol = :metabolic_reaction_handler

  try

    # Open the model file, and read each line into a vector -
    open(path_to_model_file,"r") do model_file
      for line in eachline(model_file)

          if (contains(line,"//") == false && search(line,"\n")[1] != 1)
            push!(tmp_array,chomp(line))
          end
      end
    end

    for sentence in tmp_array

      # check for #pragma -
      if (contains(sentence,"#pragma") == true)

        # split the sentence -
        split_array = split(sentence,"::")

        # grab handler -
        handler_string = split_array[2]
        if (handler_string == "metabolic_reaction_handler")
          handler_symbol = :metabolic_reaction_handler
        elseif (handler_string == "control_statement_handler")
          handler_symbol = :control_statement_handler
        end
      end


      # Depending upon the handler_symbol, we will process diff types of records -
      if (handler_symbol == :metabolic_reaction_handler && contains(sentence,"#pragma") == false)

        local_vff_sentence_array = vff_metabolic_sentence_factory(sentence,handler_symbol)
        @show local_vff_sentence_array

        for local_vff_sentence in collect(local_vff_sentence_array)
          push!(expanded_sentence_vector,local_vff_sentence)
        end
      elseif (handler_symbol == :control_statement_handler && contains(sentence,"#pragma") == false)
        # no noting for now -
        # ...
      end
    end

  catch err
    showerror(STDOUT, err, backtrace());println()
  end

  if (handler_symbol == :metabolic_reaction_handler)
    return expanded_sentence_vector
  end

end

# ========================================================================================= #
# Helper functions -
# ========================================================================================= #
function vff_control_statement_factory(sentence::String,handler_symbol::Symbol)

  # initialize control statement -
  control_statement_object = VFFControlSentence()

  # grab data from sentence -
  control_statement_object.original_sentence = sentence

  # split the sentence -
  split_array = split(sentence," ")

  # original_sentence::AbstractString
  # control_actor::AbstractString
  # control_type::Symbol
  # control_target::AbstractString
  control_statement_object.control_actor = split_array[1]

  # analyze the raw type -
  raw_control_type = split_array[2]
  if (raw_control_type == "activates")
    control_statement_object.control_type = :activate
  elseif (raw_control_type == "inhibits")
    control_statement_object.control_type = :inhibit
  end

  # set the control target -
  control_statement_object.control_target = split_array[3]

  # return -
  return control_statement_object
end


function vff_metabolic_sentence_factory(sentence::String,handler_symbol::Symbol)

  sentence_vector = VFFSentence[]

  # Ok, so now we have the array for sentences -
  vff_sentence = VFFSentence()
  vff_sentence.original_sentence = sentence

  # split the sentence -
  split_array = split(sentence,",")

  # sentence_name::AbstractString
  # sentence_reactant_clause::AbstractString
  # sentence_product_clause::AbstractString
  # sentence_reverse_bound::Float64
  # sentence_forward_bound::Float64
  # sentence_delimiter::Char
  vff_sentence.sentence_name = split_array[1]

  # grab the enzme type flag -
  enzyme_type_flag = split_array[2]
  if (enzyme_type_flag == "[]" || enzyme_type_flag == "1")
    vff_sentence.sentence_type_flag = 1
  else
    vff_sentence.sentence_type_flag = 0
  end

  vff_sentence.sentence_reactant_clause = split_array[3]
  vff_sentence.sentence_product_clause = split_array[4]
  vff_sentence.sentence_reverse_bound = parse(Float64,split_array[5])
  vff_sentence.sentence_forward_bound = parse(Float64,split_array[6])
  vff_sentence.sentence_handler = handler_symbol
  vff_sentence.sentence_delimiter = ','

  # add sentence to sentence_vector -
  push!(sentence_vector,vff_sentence)

  # Check - is this reversible?
  if (vff_sentence.sentence_reverse_bound == -Inf)

    # ok, so we have a reversible reaction -
    # first change lower bound to 0 -
    vff_sentence.sentence_reverse_bound = 0.0

    # create a new copy of sentence -
    vff_sentence_copy = copy(vff_sentence)
    vff_sentence_copy.sentence_name = (vff_sentence_copy.sentence_name)*"_reverse"
    vff_sentence_copy.sentence_reactant_clause = vff_sentence.sentence_product_clause
    vff_sentence_copy.sentence_product_clause = vff_sentence.sentence_reactant_clause
    vff_sentence_copy.sentence_handler = vff_sentence.sentence_handler
    vff_sentence_copy.sentence_type_flag = vff_sentence.sentence_type_flag

    # add sentence and sentence copy to the expanded_sentence_vector -
    push!(sentence_vector,vff_sentence_copy)
  end

  return sentence_vector
end
