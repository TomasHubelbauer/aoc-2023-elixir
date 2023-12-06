# Toggle between `05.txt` and `05.test.txt` for debugging purposes
name = "05.txt"
{status, text} = File.read(name)

if status != :ok do
  raise "Create #{name} before running this script!"
end

# Split the text into individual lines
lines = String.split(text, "\n", trim: true)

{seeds, maps, _} =
  Enum.reduce(
    lines,
    {[],
     %{
       seedToSoil: [],
       soilToFertilizer: [],
       fertilizerToWater: [],
       waterToLight: [],
       lightToTemperature: [],
       temperatureToHumidity: [],
       humidityToLocation: []
     }, :seeds},
    fn line, {seeds, maps, state} ->
      seeds =
        if String.starts_with?(line, "seeds:") do
          [_, seedsSpan] = String.split(line, ":", trim: true)
          String.split(seedsSpan, " ", trim: true) |> Enum.map(&String.to_integer/1)
        else
          seeds
        end

      stateChange =
        case line do
          "seed-to-soil map:" -> :seedToSoil
          "soil-to-fertilizer map:" -> :soilToFertilizer
          "fertilizer-to-water map:" -> :fertilizerToWater
          "water-to-light map:" -> :waterToLight
          "light-to-temperature map:" -> :lightToTemperature
          "temperature-to-humidity map:" -> :temperatureToHumidity
          "humidity-to-location map:" -> :humidityToLocation
          _ -> nil
        end

      entry =
        if state != :seeds and stateChange == nil do
          [destination, source, length] =
            String.split(line, " ", trim: true) |> Enum.map(&String.to_integer/1)

          {destination, source, length}
        else
          nil
        end

      maps =
        if entry do
          case state do
            :seedToSoil ->
              %{maps | seedToSoil: maps.seedToSoil ++ [entry]}

            :soilToFertilizer ->
              %{maps | soilToFertilizer: maps.soilToFertilizer ++ [entry]}

            :fertilizerToWater ->
              %{maps | fertilizerToWater: maps.fertilizerToWater ++ [entry]}

            :waterToLight ->
              %{maps | waterToLight: maps.waterToLight ++ [entry]}

            :lightToTemperature ->
              %{maps | lightToTemperature: maps.lightToTemperature ++ [entry]}

            :temperatureToHumidity ->
              %{maps | temperatureToHumidity: maps.temperatureToHumidity ++ [entry]}

            :humidityToLocation ->
              %{maps | humidityToLocation: maps.humidityToLocation ++ [entry]}

            _ ->
              maps
          end
        else
          maps
        end

      state = stateChange || state

      # IO.inspect({line, seeds, maps, state})
      {seeds, maps, state}
    end
  )

%{
  seedToSoil: seedToSoil,
  soilToFertilizer: soilToFertilizer,
  fertilizerToWater: fertilizerToWater,
  waterToLight: waterToLight,
  lightToTemperature: lightToTemperature,
  temperatureToHumidity: temperatureToHumidity,
  humidityToLocation: humidityToLocation
} = maps

# IO.inspect(seeds)
# IO.inspect(seedToSoil)
# IO.inspect(soilToFertilizer)
# IO.inspect(fertilizerToWater)
# IO.inspect(waterToLight)
# IO.inspect(lightToTemperature)
# IO.inspect(temperatureToHumidity)
# IO.inspect(humidityToLocation)

lookupStep = fn map, number ->
  candidates =
    Enum.map(map, fn {destination, source, length} ->
      difference = number - source

      if difference >= 0 and difference < length do
        destination + difference
      else
        nil
      end
    end)

  Enum.find(candidates, fn candidate -> candidate != nil end) || number
end

lookupPath = fn seed ->
  Enum.reduce(
    [
      seedToSoil,
      soilToFertilizer,
      fertilizerToWater,
      waterToLight,
      lightToTemperature,
      temperatureToHumidity,
      humidityToLocation
    ],
    seed,
    fn map, number ->
      lookupStep.(map, number)
    end
  )
end

paths = Enum.map(seeds, fn seed -> lookupPath.(seed) end)

min = Enum.min(paths)

IO.inspect(min)
