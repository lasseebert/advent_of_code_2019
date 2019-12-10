defmodule Advent.Day10 do
  @moduledoc """
  Asteroids!
  """

  @doc """
  Part 1

  From each asteroid, count number of other asteroids in sight by counting unique directions.
  Find direction by takeing the vector and divide by gcd(dx, dy)
  """
  def best_location(input) do
    asteroids = parse(input)

    asteroids
    |> Enum.map(&count_visible_asteroids(&1, asteroids))
    |> Enum.max()
  end

  @doc """
  Part 2

  Finds the station as in part 1.
  Group all asteroids by direction and sort by angle.
  Sort each inner list by distance.
  Flatmap while keeping the right sort so that each second asteroid comes after each first asteroid
  Take number 200 in that list
  """
  def vaporized(input, count) do
    asteroids = parse(input)

    station =
      {sx, sy} =
      asteroids
      |> Enum.map(&{&1, count_visible_asteroids(&1, asteroids)})
      |> Enum.max_by(&elem(&1, 1))
      |> elem(0)

    asteroids = MapSet.delete(asteroids, station)

    {x, y} =
      asteroids
      # Sort by distance. Here manhattan distance is good enough because asteroids are only grouped with other
      # asteroids with the same direction
      |> Enum.sort_by(fn {x, y} -> abs(x - sx) + abs(y - sy) end)
      # Group by direction, so that asteroids standing behind other asteroids must wait a turn
      |> Enum.group_by(&direction(station, &1))
      # Sort groups by angle
      |> Enum.sort_by(fn {dir, _} -> sortable_angle(dir) end)
      # The rest from here is just flatmapping while keeping the intended sort
      |> Enum.map(&elem(&1, 1))
      |> Enum.with_index()
      |> Enum.flat_map(fn {list, list_index} ->
        list
        |> Enum.with_index()
        |> Enum.map(fn {coord, coord_index} -> {coord_index, list_index, coord} end)
      end)
      |> Enum.sort()
      |> Enum.map(&elem(&1, 2))
      # ...and lastly get the 200th element
      |> Enum.at(count - 1)

    x * 100 + y
  end

  # Quadrant 0
  defp sortable_angle({x, y}) when x >= 0 and y < 0, do: {0, -x / y}

  # Quadrant > 0. Translate vector to a lower quadrant
  defp sortable_angle({x, y}) do
    {q, a} = sortable_angle({y, -x})
    {q + 1, a}
  end

  defp count_visible_asteroids(coord, asteroids) do
    asteroids = MapSet.delete(asteroids, coord)

    asteroids
    |> Enum.reduce(MapSet.new(), fn asteroid, directions -> MapSet.put(directions, direction(coord, asteroid)) end)
    |> Enum.count()
  end

  @doc """
  Returns the direction vector between two points.
  The direction vector is the smallest integer vector that has the same direction as the vector between the points.
  """
  def direction({x1, y1}, {x2, y2}) do
    {dx, dy} = {x2 - x1, y2 - y1}
    gcd = gcd(dx, dy)
    {div(dx, gcd), div(dy, gcd)}
  end

  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {row, y}, asteroids ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {char, _x} -> char == "#" end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.reduce(asteroids, fn x, asteroids -> MapSet.put(asteroids, {x, y}) end)
    end)
  end
end
