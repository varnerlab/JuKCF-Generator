function species_dilution_array = Dilution(t,x,data_dictionary)

  % volume is the last species -
  volume = x(end);

  % How many species do we have?
  number_of_species = length(x);

  % Get flow rate array et al from the data_dictionary -
  flowrate_array = data_dictionary.volumetric_flowrate_array;
  feed_composition_array = data_dictionary.material_feed_concentration_array;
  number_of_reactor_feed_streams = data_dictionary.number_of_reactor_feed_streams;

  % Initialize the interpolated flow rate array -
  interpolated_flow_rate_array = zeros(number_of_reactor_feed_streams,1);

  % What is the current dilution rate?
  if (isempty(flowrate_array) == false && number_of_reactor_feed_streams>0)

    dilution_rate_array = zeros(number_of_reactor_feed_streams,1);
    for feed_stream_index = 1:number_of_reactor_feed_streams

      % interpolate, then calc the dilution rate -
      flow_rate = interp1(flowrate_array(:,1),flowrate_array(:,feed_stream_index+1),t);
      interpolated_flow_rate_array(feed_stream_index,1) = flow_rate;
      dilution_rate_array(feed_stream_index,1) = (flow_rate)/(volume);
    end
  else
    flow_rate = 0.0;
    dilution_rate = 0.0;
  end

  % initialize the diltion array -
  species_dilution_array = zeros(number_of_species,1);

  % Check for an empty feed composition array, if empty skip this block -
  if (isempty(feed_composition_array) == false)

    % Compute -
    for species_index = 1:number_of_species - 1
      tmp_array = [];
      for feed_stream_index = 1:number_of_reactor_feed_streams
        tmp_value = dilution_rate_array(feed_stream_index,1)*(feed_composition_array(species_index) - x(species_index));
        tmp_array = [tmp_array ; tmp_value];
      end

      species_dilution_array(species_index,1) = sum(tmp_array);
    end


    % Last element is F -
    species_dilution_array(end,1) = sum(interpolated_flow_rate_array);
  end
return
