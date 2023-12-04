# Toggle between `03.txt` and `03.test.txt` for debugging purposes
name = "03.test.txt"
{status, text} = File.read(name)

if status != :ok do
  raise "Create #{name} before running this script!"
end

# Trim the empty line at the end of the file
text = String.trim(text)

lines = String.split(text, "\n")
width = String.length(Enum.at(lines, 0))
height = Enum.count(lines)

if !Enum.all?(lines, fn line -> String.length(line) == width end) do
  raise "All lines must be the same length #{width}!"
end

symbols = Enum.map(lines, fn line -> line |> String.graphemes() end)

isDigit = fn x, y ->
  Enum.at(Enum.at(symbols, y), x) in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
end

isSigil = fn x, y ->
  symbol = Enum.at(Enum.at(symbols, y), x)
  symbol != "." and symbol not in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
end

locateSymbol = fn x, y ->
  Enum.at(Enum.at(symbols, y), x)
end

calculateNeighbors = fn x, y ->
  [
    {x - 1, y - 1},
    {x, y - 1},
    {x + 1, y - 1},
    {x - 1, y},
    {x + 1, y},
    {x - 1, y + 1},
    {x, y + 1},
    {x + 1, y + 1}
  ]
end

coordinates =
  for x <- 0..(width - 1), y <- 0..(height - 1), isSigil.(x, y), do: {x, y}

extractSerial = fn x, y ->
  # TODO: Search both directions for the whole serial number
  locateSymbol.(x, y) |> String.to_integer()
end

neighbors =
  Enum.map(coordinates, fn {x, y} ->
    serialCollisionCoordinates =
      Enum.filter(calculateNeighbors.(x, y), fn {x, y} -> isDigit.(x, y) end)

    %{
      partSigil: locateSymbol.(x, y),
      partLocation: {x, y},
      serials: serialCollisionCoordinates |> Enum.map(fn {x, y} -> extractSerial.(x, y) end)
    }
  end)

IO.inspect(neighbors)
