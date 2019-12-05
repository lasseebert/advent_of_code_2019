defmodule Advent.Day04 do
  @moduledoc """
  Algorithm:

  Start by increasing numbers to first "non-decreasing digits" number
  Parse numbers into rerverse digits (the reverse digits make increasing the number cheaper)
  Increase by always keeping the non-decreasing constraint
  Check the other constraint for each yielded number

  Runs in ~1 ms on my machine
  """

  @doc "Part 1"
  def count_valid_passwords(from, to) do
    [from, to] =
      [from, to]
      |> Enum.map(&digits/1)
      |> Enum.map(&next_increasing_number/1)
      |> Enum.map(&Enum.reverse/1)

    count_valid_passwords(from, to, 0, false)
  end

  @doc "Part 2"
  def count_extended_valid_passwords(from, to) do
    [from, to] =
      [from, to]
      |> Enum.map(&digits/1)
      |> Enum.map(&next_increasing_number/1)
      |> Enum.map(&Enum.reverse/1)

    count_valid_passwords(from, to, 0, true)
  end

  defp count_valid_passwords(from, to, count, _) when from == to, do: count

  defp count_valid_passwords(from, to, count, extended) do
    count = if valid?(from, extended), do: count + 1, else: count
    next = increase(from)
    count_valid_passwords(next, to, count, extended)
  end

  defp valid?(digits, extended) do
    if extended do
      pairs = Enum.chunk_every([:start | digits ++ [:end]], 4, 1, :discard)

      Enum.any?(pairs, fn
        [a, b, b, c] when a != b and b != c -> true
        _ -> false
      end)
    else
      pairs = Enum.chunk_every(digits, 2, 1, :discard)
      Enum.any?(pairs, fn [a, b] -> a == b end)
    end
  end

  defp digits(number) do
    number
    |> Integer.to_string()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  # Increases a number already adhering to the non-decreasing constraint to the next non-decreasing number
  defp increase([9 | rest]) do
    [first | rest] = increase(rest)
    [first, first | rest]
  end

  defp increase([a | rest]), do: [a + 1 | rest]

  # Make any number non-decreasing. If it is already non-decreasing, it won't change
  defp next_increasing_number(digits) do
    {digits, _} =
      Enum.map_reduce(digits, nil, fn digit, last ->
        case last do
          nil -> {digit, {:unset, digit}}
          {:unset, last_digit} when digit >= last_digit -> {digit, {:unset, digit}}
          {:unset, last_digit} -> {last_digit, {:set, last_digit}}
          {:set, last_digit} -> {last_digit, {:set, last_digit}}
        end
      end)

    digits
  end
end
