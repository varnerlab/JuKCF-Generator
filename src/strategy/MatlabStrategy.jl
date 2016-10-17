# import the OctaveStrategy and override where needed -
function build_function_header_buffer_matlab(comment_dictionary)
  return build_function_header_buffer(comment_dictionary)
end

function build_copyright_header_buffer_matlab(problem_object::ProblemObject)
  return build_copyright_header_buffer(problem_object)
end

function build_data_dictionary_buffer_matlab(problem_object::ProblemObject,solver_option::Symbol,reactor_option::Symbol)
  return build_data_dictionary_buffer(problem_object,solver_option,reactor_option)
end

function build_dilution_buffer_matlab(problem_object::ProblemObject,solver_option::Symbol,reactor_option::Symbol)
  return build_dilution_buffer(problem_object,solver_option,reactor_option)
end

function build_control_buffer_matlab(problem_object::ProblemObject)
  return build_control_buffer(problem_object)
end

function build_inputs_buffer_matlab(problem_object::ProblemObject)
  return build_inputs_buffer(problem_object)
end

function build_kinetics_buffer_matlab(problem_object::ProblemObject,solver_option::Symbol)
  return build_kinetics_buffer(problem_object,solver_option)
end
