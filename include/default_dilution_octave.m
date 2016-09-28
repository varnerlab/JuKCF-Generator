function dilution_array = Dilution(t,x,data_dictionary)

  # volume is the last species -
  volume = x(end)

  # How many species do we have?
  number_of_species = length(x);

  % Get flow rate array et al from the data_dictionary -
  flowrate_array = data_dictionary.volumetric_flowrate_array;
  feed_composition_array = data_dictionary.material_feed_concentration_array;

  % What is the current dilution rate?
  if (isempty(flowrate_array) == false)
    flow_rate = interp1(flowrate_array(:,1),flowrate_array(:,2),t);
    dilution_rate = (flow_rate)/(volume);
  else
    flow_rate = 0.0;
    dilution_rate = 0.0;
  end

  % initialize the diltion array -
  dilution_array = zeros(number_of_species,1);

  % Compute -
  for species_index = 1:number_of_species - 1
    dilution_array(species_index,1) = dilution_rate*(feed_composition_array(species_index) - x(species_index));
  end

  % Last element is F -
  dilution_array(end,1) = flow_rate;

return
