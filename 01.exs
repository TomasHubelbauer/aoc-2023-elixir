# Day 1
# Note that I have ham-fisted async tasks into this solution because I was eager
# to try them out. This could would probably be just as fine without them.

# Toggle between `01.txt` and `01.test.txt` for debugging purposes
# Note that the right answer for `01.test.txt` is 93 + 11 + 64 + 99 + 52 = 319
{status, text} = File.read("01.txt")

figure_out_line = fn line ->
  case line do
    "" ->
      0

    _ ->
      digits = Regex.replace(~r/[^0-9]/, line, "") |> String.graphemes()
      first_digit = digits |> List.first() |> String.to_integer()
      last_digit = digits |> List.last() |> String.to_integer()
      first_digit * 10 + last_digit
  end
end

case status do
  :ok ->
    lines = String.split(text, "\n")

    tasks =
      Enum.map(lines, fn line ->
        Task.async(fn -> figure_out_line.(line) end)
      end)

    sum =
      Enum.reduce(tasks, 0, fn task, acc ->
        acc + Task.await(task)
      end)

    IO.puts(sum)

  :error ->
    IO.puts("Create 00.txt before running this script!")
end
