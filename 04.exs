# Toggle between `04.txt` and `04.test.txt` for debugging purposes
name = "04.txt"
{status, text} = File.read(name)

if status != :ok do
  raise "Create #{name} before running this script!"
end

# Split the text into individual lines
lines = String.split(text, "\n", trim: true)

# Parse the lines into data representing the cards
cards =
  Enum.map(lines, fn line ->
    [nameSpan, dataSpan] = String.split(line, ": ", parts: 2)

    if !String.starts_with?(nameSpan, "Card ") do
      raise "Invalid name space: '#{nameSpan}'"
    end

    id = String.slice(nameSpan, 5..-1) |> String.trim() |> String.to_integer()

    [winnersSpan, randomsSpan] = String.split(dataSpan, " | ", parts: 2)

    winners = String.split(winnersSpan, " ", trim: true) |> Enum.map(&String.to_integer/1)
    randoms = String.split(randomsSpan, " ", trim: true) |> Enum.map(&String.to_integer/1)

    {id, winners, randoms}
  end)

scores =
  Enum.map(cards, fn {id, winners, randoms} ->
    score =
      Enum.reduce(randoms, 0, fn random, score ->
        if random in winners do
          if score == 0, do: 1, else: score * 2
        else
          score
        end
      end)

    {id, score}
  end)

scoreSum = Enum.reduce(scores, 0, fn {_, score}, sum -> sum + score end)

IO.inspect(scoreSum)

# Make a map of card IDs to the number of copies and set the default to 1
copies =
  Enum.reduce(cards, %{}, fn {id, _, _}, copies -> Map.update(copies, id, 1, &(&1 + 1)) end)

# Process the cards in order and bump the downstream card copies by the scores
copies =
  Enum.reduce(Enum.with_index(cards), copies, fn {{id, winners, randoms}, index}, copies ->
    count = copies[id]
    # IO.inspect("Processing card #{id} with #{count} copies")

    Enum.reduce(1..count, copies, fn round, copies ->
      score =
        Enum.reduce(randoms, 0, fn random, score ->
          if random in winners, do: score + 1, else: score
        end)

      # IO.inspect("Round #{round}/#{copies[id]} of card #{id} yields #{score}")

      if score == 0,
        do: copies,
        else:
          Enum.reduce(1..score, copies, fn score, copies ->
            {id, _, _} = Enum.at(cards, index + score)
            # IO.inspect("Bumping card #{id} from #{copies[id]} to #{copies[id] + 1}")
            Map.update(copies, id, 1, &(&1 + 1))
          end)
    end)
  end)

cardSum = Enum.reduce(cards, 0, fn {id, _, _}, sum -> sum + copies[id] end)

IO.inspect(cardSum)
