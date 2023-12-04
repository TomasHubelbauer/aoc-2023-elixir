# Toggle between `02.txt` and `02.test.txt` for debugging purposes
# Note that in `02.test.txt`, games 1, 2 and 5 are valid giving ID sum of 8
{status, text} = File.read("02.txt")

parseNumber = fn span ->
  # Check that the span is a number
  try do
    String.to_integer(span)
  rescue
    _ -> raise "Invalid number span: '#{span}'"
  end
end

parseName = fn span ->
  [gameSpan, idSpan] = span |> String.split(" ") |> Enum.map(fn s -> String.trim(s) end)

  if gameSpan != "Game" do
    raise "Invalid name span: '#{span}'"
  end

  parseNumber.(idSpan)
end

parseColor = fn span ->
  # Check that the span is a color
  case span do
    "red" -> :red
    "blue" -> :blue
    "green" -> :green
    _ -> raise "Invalid color span: '#{span}'"
  end
end

parseDraw = fn span ->
  # Split the span into the number span and the color span
  [numberSpan, colorSpan] = span |> String.split(" ") |> Enum.map(fn s -> String.trim(s) end)

  # Construct a struct with the number and color
  %{number: parseNumber.(numberSpan), color: parseColor.(colorSpan)}
end

parseTurn = fn span ->
  # Split the span into a list of draw spans
  spans = span |> String.split(",") |> Enum.map(fn s -> String.trim(s) end)

  # Parse each draw span into a draw
  Enum.map(spans, fn span -> parseDraw.(span) end)
end

parseGame = fn line ->
  # Split the "Game #:" span and the "# color, # color; # color" span
  [nameSpan, dataSpan] = line |> String.split(":") |> Enum.map(fn s -> String.trim(s) end)

  # Split the dataSpan into a list of "# color, # color, # color" spans
  turnSpans = dataSpan |> String.split(";") |> Enum.map(fn s -> String.trim(s) end)

  # Return an object with an ID of the game and the turn data
  %{id: parseName.(nameSpan), turns: Enum.map(turnSpans, fn s -> parseTurn.(s) end)}
end

checkDraw = fn draw, limits ->
  draw.number <= limits[draw.color]
end

checkTurn = fn turn, limits ->
  Enum.all?(turn, fn draw -> checkDraw.(draw, limits) end)
end

checkGame = fn game, limits ->
  Enum.all?(game.turns, fn turn -> checkTurn.(turn, limits) end)
end

determineLimits = fn game ->
  Enum.reduce(game.turns, %{red: 0, green: 0, blue: 0}, fn turn, limits ->
    Enum.reduce(turn, limits, fn draw, limits ->
      case draw.color do
        :red -> %{limits | red: max(limits.red, draw.number)}
        :green -> %{limits | green: max(limits.green, draw.number)}
        :blue -> %{limits | blue: max(limits.blue, draw.number)}
      end
    end)
  end)
end

case status do
  :ok ->
    lines = String.split(text, "\n")
    nonEmptyLines = Enum.filter(lines, fn line -> String.length(line) > 0 end)
    games = Enum.map(nonEmptyLines, fn line -> parseGame.(line) end)

    limits = %{red: 12, green: 13, blue: 14}
    validGames = Enum.filter(games, fn game -> checkGame.(game, limits) end)
    idSum = Enum.reduce(validGames, 0, fn game, acc -> acc + game.id end)
    IO.puts(idSum)

    powers =
      Enum.map(games, fn game ->
        limits = determineLimits.(game)
        limits.red * limits.green * limits.blue
      end)

    powerSum = Enum.reduce(powers, 0, fn power, acc -> acc + power end)
    IO.puts(powerSum)

  :error ->
    IO.puts("Create 02.txt before running this script!")
end
