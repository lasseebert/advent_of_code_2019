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
    |> Stream.unfold(fn map -> {biodiversity_rating(map), evolve(map)} end)
    |> Enum.reduce_while(MapSet.new(), fn value, seen ->
      if MapSet.member?(seen, value) do
        {:halt, value}
      else
        {:cont, MapSet.put(seen, value)}
      end
    end)
  end

  defp evolve(map) do
    for(x <- 0..4, y <- 0..4, do: {x, y})
    |> Enum.reduce(MapSet.new(), fn {x, y}, new_map ->
      neighbour_count =
        [{0, -1}, {0, 1}, {-1, 0}, {1, 0}] |> Enum.count(fn {dx, dy} -> MapSet.member?(map, {x + dx, y + dy}) end)

      if MapSet.member?(map, {x, y}) do
        if neighbour_count == 1 do
          MapSet.put(new_map, {x, y})
        else
          new_map
        end
      else
        if neighbour_count in [1, 2] do
          MapSet.put(new_map, {x, y})
        else
          new_map
        end
      end
    end)
  end

  defp biodiversity_rating(map) do
    map
    |> Enum.map(fn {x, y} -> Bitwise.bsl(1, y * 5 + x) end)
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
          ?# -> MapSet.put(map, {x, y})
          ?. -> map
        end
      end)
    end)
  end
end
