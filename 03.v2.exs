# Toggle between `03.txt` and `03.test.txt` for debugging purposes
name = "03.txt"
{status, text} = File.read(name)

if status != :ok do
  raise "Create #{name} before running this script!"
end

# Trim the empty line at the end of the file
text = String.trim(text)

lines = String.split(text, "\n")
stride = String.length(Enum.at(lines, 0))

if !Enum.all?(lines, fn line -> String.length(line) == stride end) do
  raise "All lines must be the same length #{stride}!"
end

serials =
  Enum.map(Enum.with_index(lines), fn {line, y} ->
    ranges = Regex.scan(~r/\d+/, line, return: :index) |> List.flatten()

    Enum.map(ranges, fn {start, length} ->
      %{
        y: y,
        startX: start,
        endX: start + length - 1,
        serial: String.slice(line, start, length) |> String.to_integer()
      }
    end)
  end)
  |> List.flatten()

symbols =
  Enum.map(Enum.with_index(lines), fn {line, y} ->
    chars = String.graphemes(line)

    Enum.map(Enum.with_index(chars), fn {char, x} ->
      {char, {x, y}}
    end)
    |> Enum.filter(fn {char, _} ->
      char != "." and char not in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    end)
  end)
  |> List.flatten()

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

results =
  Enum.map(symbols, fn {char, {x, y}} ->
    neighbors = calculateNeighbors.(x, y)

    serials =
      Enum.filter(serials, fn serial ->
        Enum.any?(neighbors, fn {x, y} ->
          serial.startX <= x and serial.endX >= x and serial.y == y
        end)
      end)
      |> Enum.map(fn serial -> serial.serial end)

    {char, {x, y}, serials}
  end)

# Extract the serials from the results
usedSerials = Enum.map(results, fn {_, _, serials} -> serials end) |> List.flatten()

sum = Enum.reduce(usedSerials, 0, fn serial, acc -> acc + serial end)

IO.inspect(sum)
