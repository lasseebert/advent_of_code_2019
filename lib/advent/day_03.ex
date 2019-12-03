defmodule Advent.Day03 do
  @moduledoc """
  --- Day 3: Crossed Wires ---

  The gravity assist was successful, and you're well on your way to the Venus refuelling station. During the rush back on Earth, the fuel management system wasn't completely installed, so that's next on the priority list.

  Opening the front panel reveals a jumble of wires. Specifically, two wires are connected to a central port and extend outward on a grid. You trace the path each wire takes as it leaves the central port, one wire per line of text (your puzzle input).

  The wires twist and turn, but the two wires occasionally cross paths. To fix the circuit, you need to find the intersection point closest to the central port. Because the wires are on a grid, use the Manhattan distance for this measurement. While the wires do technically cross right at the central port where they both start, this point does not count, nor does a wire count as crossing with itself.

  For example, if the first wire's path is R8,U5,L5,D3, then starting from the central port (o), it goes right 8, up 5, left 5, and finally down 3:

  ...........
  ...........
  ...........
  ....+----+.
  ....|....|.
  ....|....|.
  ....|....|.
  .........|.
  .o-------+.
  ...........

  Then, if the second wire's path is U7,R6,D4,L4, it goes up 7, right 6, down 4, and left 4:

  ...........
  .+-----+...
  .|.....|...
  .|..+--X-+.
  .|..|..|.|.
  .|.-X--+.|.
  .|..|....|.
  .|.......|.
  .o-------+.
  ...........

  These wires cross at two locations (marked X), but the lower-left one is closer to the central port: its distance is 3 + 3 = 6.

  Here are a few more examples:

      R75,D30,R83,U83,L12,D49,R71,U7,L72
      U62,R66,U55,R34,D71,R55,D58,R83 = distance 159
      R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
      U98,R91,D20,R16,D67,R40,U7,R15,U6,R7 = distance 135

  What is the Manhattan distance from the central port to the closest intersection?
  """

  @doc "Part 1"
  def closest_intersection(input) do
    input
    |> parse()
    |> Enum.map(&walk_path/1)
    |> find_intersections()
    |> Enum.map(&manhattan_distance_to_zero/1)
    |> Enum.min()
  end

  @doc "Part 2"
  def fewest_steps_to_intersection(input) do
    input
    |> parse()
    |> Enum.map(&walk_path/1)
    |> find_intersections()
    |> Enum.map(&total_dist/1)
    |> Enum.min()
  end

  defp walk_path(path) do
    walk = %{}
    walk_path(walk, 0, {0, 0}, path)
  end

  defp walk_path(walk, _dist, _pos, []), do: walk
  defp walk_path(walk, dist, pos, [{_dir, 0} | rest]), do: walk_path(walk, dist, pos, rest)

  defp walk_path(walk, dist, {x, y}, [{{dir_x, dir_y} = dir, count} | rest]) do
    pos = {x + dir_x, y + dir_y}
    dist = dist + 1
    walk = Map.put_new(walk, pos, dist)
    walk_path(walk, dist, pos, [{dir, count - 1} | rest])
  end

  # Finds intersections and returns a list of [{point, total_dist}]
  defp find_intersections(walks) do
    [set_1, set_2] = walks |> Enum.map(&(&1 |> Map.keys() |> MapSet.new()))

    MapSet.intersection(set_1, set_2)
    |> Enum.map(fn point -> {point, walks |> Enum.map(&Map.fetch!(&1, point)) |> Enum.sum()} end)
  end

  defp manhattan_distance_to_zero({{x, y}, _dist}), do: abs(x) + abs(y)
  defp total_dist({_point, dist}), do: dist

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(fn <<dir, distance::binary>> ->
        dir = parse_dir(dir)
        distance = String.to_integer(distance)
        {dir, distance}
      end)
    end)
  end

  defp parse_dir(?R), do: {1, 0}
  defp parse_dir(?L), do: {-1, 0}
  defp parse_dir(?U), do: {0, 1}
  defp parse_dir(?D), do: {0, -1}
end
