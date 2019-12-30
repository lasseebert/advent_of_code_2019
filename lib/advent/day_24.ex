defmodule Advent.Day24 do
  @moduledoc """
  Game of bugs
  """

  require Bitwise

  @doc """
  Part 1
  """
  def first_duplicate(input) do
    input
    |> parse()
    |> Stream.unfold(fn map -> {biodiversity_rating(map), simple_evolve(map)} end)
    |> Enum.reduce_while(MapSet.new(), fn value, seen ->
      if MapSet.member?(seen, value) do
        {:halt, value}
      else
        {:cont, MapSet.put(seen, value)}
      end
    end)
  end

  @doc """
  Part 2
  """
  def recursive_evolve(input, steps) do
    input
    |> parse()
    |> Stream.iterate(&do_recursive_evolve/1)
    |> Enum.at(steps)
    |> Enum.count()
  end

  defp do_recursive_evolve(map) do
    {min_z, max_z} = map |> Enum.map(&elem(&1, 2)) |> Enum.min_max()

    for(x <- 0..4, y <- 0..4, z <- (min_z - 1)..(max_z + 1), {x, y} != {2, 2}, do: {x, y, z})
    |> Enum.reduce(MapSet.new(), fn point, new_map ->
      cond do
        MapSet.member?(map, point) and count_neighbours(map, point) == 1 -> MapSet.put(new_map, point)
        not MapSet.member?(map, point) and count_neighbours(map, point) in [1, 2] -> MapSet.put(new_map, point)
        true -> new_map
      end
    end)
  end

  defp count_neighbours(map, {x, y, z}) do
    [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
    |> Enum.map(fn {dx, dy} -> {{x, y}, {x + dx, y + dy, z}} end)
    |> Enum.flat_map(fn
      {_, {x, y, z}} when 0 <= x and x <= 4 and 0 <= y and y <= 4 and {x, y} != {2, 2} -> [{x, y, z}]
      {_, {-1, _y, z}} -> [{1, 2, z - 1}]
      {_, {_x, -1, z}} -> [{2, 1, z - 1}]
      {_, {5, _y, z}} -> [{3, 2, z - 1}]
      {_, {_x, 5, z}} -> [{2, 3, z - 1}]
      {{1, 2}, {2, 2, z}} -> 0..4 |> Enum.map(&{0, &1, z + 1})
      {{2, 1}, {2, 2, z}} -> 0..4 |> Enum.map(&{&1, 0, z + 1})
      {{3, 2}, {2, 2, z}} -> 0..4 |> Enum.map(&{4, &1, z + 1})
      {{2, 3}, {2, 2, z}} -> 0..4 |> Enum.map(&{&1, 4, z + 1})
    end)
    |> Enum.count(&MapSet.member?(map, &1))
  end

  defp simple_evolve(map) do
    for(x <- 0..4, y <- 0..4, do: {x, y})
    |> Enum.reduce(MapSet.new(), fn {x, y}, new_map ->
      neighbour_count =
        [{0, -1}, {0, 1}, {-1, 0}, {1, 0}] |> Enum.count(fn {dx, dy} -> MapSet.member?(map, {x + dx, y + dy, 0}) end)

      if MapSet.member?(map, {x, y, 0}) do
        if neighbour_count == 1 do
          MapSet.put(new_map, {x, y, 0})
        else
          new_map
        end
      else
        if neighbour_count in [1, 2] do
          MapSet.put(new_map, {x, y, 0})
        else
          new_map
        end
      end
    end)
  end

  defp biodiversity_rating(map) do
    map
    |> Enum.map(fn {x, y, 0} -> Bitwise.bsl(1, y * 5 + x) end)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, y}, map ->
      line
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {char, x}, map ->
        case char do
          ?# -> MapSet.put(map, {x, y, 0})
          ?. -> map
        end
      end)
    end)
  end
end
