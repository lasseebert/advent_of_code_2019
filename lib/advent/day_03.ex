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

  ###
  # This algorithm keeps dividing the grid to find intersections.
  #
  # Day03 has been rewritten several times and went from a runtime of ~350ms to ~3ms
  ###

  defmodule Grid do
    @moduledoc """
    A grid has a dimension and wire segments from two different wires.
    """

    defstruct [
      :segments,
      :min_x,
      :max_x,
      :min_y,
      :max_y
    ]

    def new do
      %__MODULE__{
        segments: %{first: [], second: []}
      }
    end

    def add_segment(grid, tag, segment) do
      {x, y} = segment.from_pos
      {to_x, to_y} = segment.to_pos

      segments = Map.update!(grid.segments, tag, &[segment | &1])

      if is_nil(grid.min_x) do
        %{
          grid
          | segments: segments,
            min_x: x,
            max_x: to_x,
            min_y: y,
            max_y: to_y
        }
      else
        %{
          grid
          | segments: segments,
            min_x: min(grid.min_x, x),
            max_x: max(grid.max_x, to_x),
            min_y: min(grid.min_y, y),
            max_y: max(grid.max_y, to_y)
        }
      end
    end

    # Grid is size one
    def find_intersections(%{min_x: x, max_x: x, min_y: y, max_y: y} = grid) do
      if grid.segments.first == [] or grid.segments.second == [] do
        []
      else
        first_segment = grid.segments.first |> Enum.min_by(& &1.dist)
        second_segment = grid.segments.second |> Enum.min_by(& &1.dist)
        [{{x, y}, first_segment.dist + second_segment.dist}]
      end
    end

    # Split grid vertically
    def find_intersections(%{min_x: min_x, max_x: max_x, min_y: min_y, max_y: max_y} = grid)
        when max_x - min_x > max_y - min_y do
      split_at = min_x + div(max_x - min_x + 1, 2)

      grid.segments
      |> Enum.flat_map(fn {tag, segments} -> Enum.map(segments, &{tag, &1}) end)
      |> Enum.reduce(%{left: new(), right: new()}, fn {tag, segment}, grids ->
        {x, _y} = segment.from_pos
        {to_x, _to_y} = segment.to_pos

        cond do
          to_x < split_at ->
            Map.update!(grids, :left, &add_segment(&1, tag, segment))

          x >= split_at ->
            Map.update!(grids, :right, &add_segment(&1, tag, segment))

          true ->
            {segment_left, segment_right} = split_segment_x(segment, split_at)

            grids
            |> Map.update!(:left, &add_segment(&1, tag, segment_left))
            |> Map.update!(:right, &add_segment(&1, tag, segment_right))
        end
      end)
      |> Map.values()
      |> Enum.reject(&(&1.segments.first == [] or &1.segments.second == []))
      |> Enum.flat_map(&find_intersections/1)
    end

    # Split grid horizontally
    def find_intersections(%{min_x: min_x, max_x: max_x, min_y: min_y, max_y: max_y} = grid)
        when max_x - min_x <= max_y - min_y do
      split_at = min_y + div(max_y - min_y + 1, 2)

      grid.segments
      |> Enum.flat_map(fn {tag, segments} -> Enum.map(segments, &{tag, &1}) end)
      |> Enum.reduce(%{up: new(), down: new()}, fn {tag, segment}, grids ->
        {_x, y} = segment.from_pos
        {_to_x, to_y} = segment.to_pos

        cond do
          to_y < split_at ->
            Map.update!(grids, :down, &add_segment(&1, tag, segment))

          y >= split_at ->
            Map.update!(grids, :up, &add_segment(&1, tag, segment))

          true ->
            {segment_down, segment_up} = split_segment_y(segment, split_at)

            grids
            |> Map.update!(:down, &add_segment(&1, tag, segment_down))
            |> Map.update!(:up, &add_segment(&1, tag, segment_up))
        end
      end)
      |> Map.values()
      |> Enum.reject(&(&1.segments.first == [] or &1.segments.second == []))
      |> Enum.flat_map(&find_intersections/1)
    end

    defp split_segment_x(segment, split_at) do
      {x, y} = segment.from_pos

      {
        %{
          from_pos: segment.from_pos,
          to_pos: {split_at - 1, y},
          dir: segment.dir,
          dist: segment.dist,
          dist_step: segment.dist_step
        },
        %{
          from_pos: {split_at, y},
          to_pos: segment.to_pos,
          dir: segment.dir,
          dist: segment.dist + segment.dist_step * (split_at - x),
          dist_step: segment.dist_step
        }
      }
    end

    defp split_segment_y(segment, split_at) do
      {x, y} = segment.from_pos

      {
        %{
          from_pos: segment.from_pos,
          to_pos: {x, split_at - 1},
          dir: segment.dir,
          dist: segment.dist,
          dist_step: segment.dist_step
        },
        %{
          from_pos: {x, split_at},
          to_pos: segment.to_pos,
          dir: segment.dir,
          dist: segment.dist + segment.dist_step * (split_at - y),
          dist_step: segment.dist_step
        }
      }
    end
  end

  @doc "Part 1"
  def closest_intersection(input) do
    input
    |> parse()
    |> build_grid()
    |> Grid.find_intersections()
    |> Enum.map(&manhattan_distance_to_zero/1)
    |> Enum.min()
  end

  @doc "Part 2"
  def fewest_steps_to_intersection(input) do
    input
    |> parse()
    |> build_grid()
    |> Grid.find_intersections()
    |> Enum.map(&total_dist/1)
    |> Enum.min()
  end

  defp build_grid(wires) do
    grid = Grid.new()

    wires
    |> Enum.zip([:first, :second])
    |> Enum.reduce(grid, fn {wire, tag}, grid ->
      find_wire_segments([], 0, {0, 0}, wire)
      |> Enum.reduce(grid, fn segment, grid ->
        Grid.add_segment(grid, tag, segment)
      end)
    end)
  end

  defp find_wire_segments(segments, _dist, _pos, []), do: segments

  defp find_wire_segments(segments, dist, {x, y}, [{{dir_x, dir_y}, count} | rest]) do
    # This builds a segment with a starting position, direction, length and starting distance from central port.
    from_pos = {x + dir_x, y + dir_y}
    to_pos = {x + count * dir_x, y + count * dir_y}

    from_dist = dist + 1
    to_dist = dist + count

    # Save all segments as going either right or up. This will ease the intersection finding later.
    # But for this to work, we also need to save the distance-step, i.e., the step we take in distance, when we
    # "walk the line".
    # This is 1 for lines already going up or right and -1 for lines that started as left or down.
    [{segment_from, segment_dist}, {segment_to, _}] = [{from_pos, from_dist}, {to_pos, to_dist}] |> Enum.sort()
    dist_step = dir_x + dir_y
    dir = {abs(dir_x), abs(dir_y)}

    segment = %{
      from_pos: segment_from,
      to_pos: segment_to,
      dir: dir,
      dist: segment_dist,
      dist_step: dist_step
    }

    segments = [segment | segments]
    find_wire_segments(segments, to_dist, to_pos, rest)
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
