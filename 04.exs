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

sum = Enum.reduce(scores, 0, fn {_, score}, sum -> sum + score end)

IO.inspect(sum)
