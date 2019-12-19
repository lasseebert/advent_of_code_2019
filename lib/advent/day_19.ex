defmodule Advent.Day19 do
  @moduledoc """
  Tractor beams!!!
  """

  alias Advent.Intcode

  @doc """
  Part 1
  """
  def count_50x50(raw_program) do
    program = raw_program |> Intcode.parse_program()

    for(x <- 0..49, y <- 0..49, do: read(program, {x, y}))
    |> Enum.count(& &1)
  end

  @doc """
  Part 2

  * Find first row of three #s, because the middle of them can be used as a line to always stay in the beam
  * Binary search for a place that fits the square
  * Jiggle the square towards the ship to find the closest position that fits
  """
  def minimum_distance(raw_program) do
    program = raw_program |> Intcode.parse_program()

    mult = find_first_three_row(program)
    estimate = binary_search(program, mult, 1, nil)
    {x, y} = jiggle(program, estimate)

    10_000 * x + y
  end

  defp find_first_three_row(program) do
    diagonal_stream()
    |> Enum.find(fn {x, y} ->
      Enum.all?(-1..1, fn d -> read(program, {x + d, y}) end)
    end)
  end

  defp binary_search(_program, {x, y}, lower, upper) when lower + 1 == upper, do: {x * lower, y * lower}

  defp binary_search(program, {x, y} = mult, lower, upper) do
    candidate =
      case upper do
        nil -> lower * 2
        upper -> div(lower + upper, 2)
      end

    {cx, cy} = {x * candidate, y * candidate}

    if square_fits?(program, {cx + x, cy + y}, 101) do
      binary_search(program, mult, lower, candidate)
    else
      binary_search(program, mult, candidate, upper)
    end
  end

  defp jiggle(program, {x, y}) do
    diagonal_stream()
    |> Enum.take(100)
    |> Stream.map(fn {dx, dy} ->
      point = {x - dx, y - dy}
      {point, square_fits?(program, point, 100)}
    end)
    |> Enum.find(&elem(&1, 1))
    |> case do
      {point, true} -> jiggle(program, point)
      nil -> {x, y}
    end
  end

  defp square_fits?(program, {x, y}, size) do
    [{0, 0}, {size - 1, 0}, {size - 1, size - 1}, {0, size - 1}]
    |> Enum.all?(fn {dx, dy} -> read(program, {x + dx, y + dy}) end)
  end

  # A stream of points in diagonals: {0, 1}, {1, 0}, {0, 2}, {1, 1}, {2, 0}, {0, 3}, ...
  # Useful for searching in a direction on two axis
  defp diagonal_stream do
    Stream.iterate(1, &(&1 + 1))
    |> Stream.flat_map(fn dist -> Stream.map(0..dist, &{&1, dist - &1}) end)
  end

  defp read(program, {x, y}) do
    {[output], _state} = Intcode.run_with_inputs(program, [x, y])
    output == 1
  end
end
