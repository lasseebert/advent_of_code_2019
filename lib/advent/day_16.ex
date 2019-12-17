defmodule Advent.Day16 do
  @moduledoc """
  Flawed Frequency Transmission
  """

  @doc """
  Part 1
  Calculates the first 8 digits of the 100th Flawed Frequency Transmission phase

  This takes ~23 seconds!!!
  """
  def fft(input, phases) do
    input
    |> parse()
    |> calc_phases(phases)
    |> Enum.take(8)
    |> Enum.join()
  end

  @doc """
  Part 2

  We take advantage of the specific input (which I think is no coensidence) that has the offset near the end of the
  long 10000x number, which means that no negative multipliers will be added. Each item in the new phase will be the
  same item in the old phase plus the next item in the new phase.

  Also, we can start by skipping ahead to the offset.

  Runs in ~3500ms
  """
  def fft_mult_offset(input, _phases) do
    original = input |> parse()
    original_length = length(original)
    big_length = original_length * 10_000

    offset = original |> Enum.take(7) |> Enum.join() |> String.to_integer()
    multiplier = div(big_length - offset, original_length) + 1
    offset = multiplier * original_length - (big_length - offset)

    big =
      original
      |> List.duplicate(multiplier)
      |> List.flatten()
      |> Enum.drop(offset)
      |> Enum.reverse()

    1..100
    |> Enum.reduce(big, fn _, big ->
      {big, _} =
        Enum.map_reduce(big, 0, fn elem, last ->
          digit = rem(elem + last, 10)
          {digit, digit}
        end)

      big
    end)
    |> Enum.reverse()
    |> Enum.take(8)
    |> Enum.join()
  end

  defp calc_phases(numbers, 0), do: numbers

  defp calc_phases(numbers, phases) do
    numbers
    |> Enum.with_index()
    |> Enum.map(fn {_, index} ->
      multiplier_stream(index + 1)
      |> Stream.zip(numbers)
      |> Enum.reduce(0, fn {a, b}, acc -> acc + a * b end)
      |> abs()
      |> rem(10)
    end)
    |> calc_phases(phases - 1)
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp multiplier_stream(count) do
    Stream.unfold({[0, 1, 0, -1], count, count}, fn
      {[a, b, c, d], 1, count} -> {a, {[b, c, d, a], count, count}}
      {[a | _] = multipliers, left, count} -> {a, {multipliers, left - 1, count}}
    end)
    |> Stream.drop(1)
  end
end
