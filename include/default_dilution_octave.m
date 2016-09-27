function dilution_array = Dilution(t,time_step_index,x,volume,data_dictionary)

  # How many species do we have?
  number_of_species = length(x);

  % Get flow rate array et al from the data_dictionary -
  flowrate_array = data_dictionary.volumetric_flowrate_array;
  feed_composition_array = data_dictionary.material_feed_concentration_array;

  % What is the current dilution rate?
  flow_rate = flowrate_array[time_step_index];
  dilution_rate =(flow_rate)/(volume);

  % initialize the diltion array -
  dilution_array = zeros(number_of_species,1);

  % Compute -
  for species_index = 1:number_of_species
    dilution_array[species_index,1] = dilution_rate*(feed_composition_array[species_index] - x[species_index]);
  end

return
