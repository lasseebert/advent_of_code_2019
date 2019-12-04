defmodule Advent.Day04 do
  @moduledoc """
  --- Day 4: Secure Container ---

  You arrive at the Venus fuel depot only to discover it's protected by a password. The Elves had written the password on a sticky note, but someone threw it out.

  However, they do remember a few key facts about the password:

      It is a six-digit number.
      The value is within the range given in your puzzle input.
      Two adjacent digits are the same (like 22 in 122345).
      Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679).

  Other than the range rule, the following are true:

      111111 meets these criteria (double 11, never decreases).
      223450 does not meet these criteria (decreasing pair of digits 50).
      123789 does not meet these criteria (no double).

  How many different passwords within the range given in your puzzle input meet these criteria?

  --- Part Two ---

  An Elf just remembered one more important detail: the two adjacent matching digits are not part of a larger group of matching digits.

  Given this additional criterion, but still ignoring the range rule, the following are now true:

      112233 meets these criteria because the digits never decrease and all repeated digits are exactly two digits long.
      123444 no longer meets the criteria (the repeated 44 is part of a larger group of 444).
      111122 meets the criteria (even though 1 is repeated more than twice, it still contains a double 22).

  How many different passwords within the range given in your puzzle input meet all of the criteria?
  """

  @doc """
  Part 1

  Algorithm:

  Start by increasing numbers to first "non-decreasing digits" number
  Parse numbers into rerverse digits (the reverse digits make increasing the number cheaper)
  Increase by always keeping the non-decreasing constraint
  Check the other constraint for each yielded number

  Runs in ~1.0 ms on my machine

  """
  def count_valid_passwords(from, to) do
    [from, to] =
      [from, to]
      |> Enum.map(&digits/1)
      |> Enum.map(&next_increasing_number/1)
      |> Enum.map(&Enum.reverse/1)

    count_valid_passwords(from, to, 0, false)
  end

  @doc """
  Part 2

  Same as part 1, but sends a flag that it should use the "extended" second constraint
  Runs in ~1.5 ms on my machine
  """
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
