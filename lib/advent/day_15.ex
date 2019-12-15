defmodule Advent.Day15 do
  @moduledoc """
  Oxygen system repair
  """

  alias Advent.Intcode

  @doc """
  Part 1

  Layout the map based on intcode outputs.
  Then find shortest path to all cells and pick the oxygen cell
  """
  def shortest_dist(input) do
    intcode = input |> Intcode.parse_program() |> Intcode.run(:oxygen)

    state =
      %{
        pos: {0, 0},
        visited: %{{0, 0} => 0},
        intcode: intcode,
        oxygen_pos: nil
      }
      |> build_map()

    state.visited
    |> distances_from({0, 0})
    |> Map.fetch!(state.oxygen_pos)
  end

  @doc """
  Part 2

  Layout the map based on intcode outputs.
  Then find shortest path from oxygen to all other cells
  Then find maximum of these
  """
  def time_to_oxygen(input) do
    intcode = input |> Intcode.parse_program() |> Intcode.run(:oxygen)

    state =
      %{
        pos: {0, 0},
        visited: %{{0, 0} => 0},
        intcode: intcode,
        oxygen_pos: nil
      }
      |> build_map()

    state.visited
    |> distances_from(state.oxygen_pos)
    |> Map.values()
    |> Enum.max()
  end

  defp build_map(state) do
    Enum.reduce(1..4, state, &walk_dir(&2, &1))
  end

  defp walk_dir(state, dir) do
    new_pos = new_pos(dir, state.pos)

    if Map.has_key?(state.visited, new_pos) do
      state
    else
      case intcode_io(state.intcode, dir) do
        :wall ->
          %{state | visited: Map.put(state.visited, new_pos, :wall)}

        :free ->
          %{state | visited: Map.put(state.visited, new_pos, :free), pos: new_pos}
          |> build_map()
          |> walk_back(dir)

        :oxygen ->
          %{state | visited: Map.put(state.visited, new_pos, :free), pos: new_pos, oxygen_pos: new_pos}
          |> build_map()
          |> walk_back(dir)
      end
    end
  end

  defp walk_back(state, original_dir) do
    dir =
      case original_dir do
        1 -> 2
        2 -> 1
        3 -> 4
        4 -> 3
      end

    case intcode_io(state.intcode, dir) do
      free when free in [:free, :oxygen] ->
        %{state | pos: new_pos(dir, state.pos)}
    end
  end

  defp intcode_io(intcode, dir) do
    send(intcode, {:input, dir})

    receive do
      {:output, :oxygen, code} -> {:ok, code}
      {:program_exit, :oxygen, _state} -> :program_exit
    end
    |> case do
      {:ok, 0} -> :wall
      {:ok, 1} -> :free
      {:ok, 2} -> :oxygen
    end
  end

  defp new_pos(1, {x, y}), do: {x, y + 1}
  defp new_pos(2, {x, y}), do: {x, y - 1}
  defp new_pos(3, {x, y}), do: {x - 1, y}
  defp new_pos(4, {x, y}), do: {x + 1, y}

  defp distances_from(map, pos) do
    distances = %{pos => 0}
    work_list = [pos]
    distance = 1

    distances_from(map, distances, work_list, distance)
  end

  defp distances_from(_map, distances, [], _distance), do: distances

  defp distances_from(map, distances, work_list, distance) do
    {distances, new_work_list} =
      for pos <- work_list,
          dir <- 1..4 do
        {pos, dir}
      end
      |> Enum.reduce({distances, []}, fn {pos, dir}, {distances, new_work_list} ->
        new_pos = new_pos(dir, pos)

        if Map.has_key?(distances, new_pos) or Map.fetch!(map, new_pos) == :wall do
          {distances, new_work_list}
        else
          {Map.put(distances, new_pos, distance), [new_pos | new_work_list]}
        end
      end)

    distances_from(map, distances, new_work_list, distance + 1)
  end
end
