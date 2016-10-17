function parse_vff_file(path_to_model_file::AbstractString)

  # We are going to load the sentences in the file into a vector
  # if not a valid model file, then throw an error -
  sentence_vector = VFFSentence[]
  expanded_sentence_vector::Array{VFFSentence} = VFFSentence[]
  tmp_array::Array{AbstractString} = AbstractString[]

  try

    # Open the model file, and read each line into a vector -
    open(path_to_model_file,"r") do model_file
      for line in eachline(model_file)

          if (contains(line,"//") == false && search(line,"\n")[1] != 1)
            push!(tmp_array,chomp(line))
          end
      end
    end

    handler_symbol::Symbol = :metabolic_reaction_handler
    for sentence in tmp_array

      # check for #pragma -
      if (contains(sentence,"#pragma") == true)

        # split the sentence -
        split_array = split(sentence,"::")

        @show split_array

        # grab handler -
        handler_string = split_array[2]
        if (handler_string == "metabolic_reaction_handler")
          handler_symbol = :metabolic_reaction_handler
        elseif (handler_string == "control_statement_handler")
          handler_symbol = :control_statement_handler
        end

      else

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

      end
    end

    # Convert all reversible reactions into 0,inf pairs -
    for sentence in sentence_vector

      if (sentence.sentence_reverse_bound == -Inf)

        # ok, so we have a reversible reaction -
        # first change lower bound to 0 -
        sentence.sentence_reverse_bound = 0.0


        # create a new copy of sentence -
        sentence_copy = copy(sentence)
        sentence_copy.sentence_name = (sentence_copy.sentence_name)*"_reverse"
        sentence_copy.sentence_reactant_clause = sentence.sentence_product_clause
        sentence_copy.sentence_product_clause = sentence.sentence_reactant_clause
        sentence_copy.sentence_handler = sentence.sentence_handler
        sentence_copy.sentence_type_flag = sentence.sentence_type_flag

        # add sentence and sentence copy to the expanded_sentence_vector -
        push!(expanded_sentence_vector,sentence)
        push!(expanded_sentence_vector,sentence_copy)
      else
        push!(expanded_sentence_vector,sentence)
      end
    end

  catch err
    showerror(STDOUT, err, backtrace());println()
  end

  # return - (I know we don't need the return, but I *** hate *** the normal Julia convention)
  return expanded_sentence_vector
end
