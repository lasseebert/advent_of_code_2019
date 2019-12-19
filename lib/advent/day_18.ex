defmodule Advent.Day18 do
  @moduledoc """
  Mazes and keys!
  """

  @doc """
  Part 1
  """
  def shortest_path(input) do
    input
    |> parse()
    |> precalc_distances()
    |> find_keys(%{})
    |> elem(0)
  end

  defp empty_state do
    %{
      walls: MapSet.new(),
      keys: %{},
      doors: %{},
      pos: nil,
      accessible_tiles: MapSet.new(),
      accessible_keys: MapSet.new(),
      edge_tiles: MapSet.new(),
      distance: 0,
      keys_found: "",
      distances: %{}
    }
  end

  defp precalc_distances(state) do
    for from <- [state.pos | Map.keys(state.keys)],
        to <- Map.keys(state.keys) do
      {from, to}
    end
    |> Enum.reduce(state, fn {from, to}, state ->
      %{state | distances: Map.put(state.distances, {from, to}, shortest_path_between(state, from, to))}
    end)
  end

  defp find_keys(%{keys: empty} = state, memo) when empty == %{} do
    {state.distance, memo}
  end

  defp find_keys(state, memo) do
    state = update_accessible_area(state)

    keys_string = state.keys_found |> String.to_charlist() |> Enum.sort()

    case Map.fetch(memo, {state.pos, keys_string}) do
      {:ok, dist} ->
        {state.distance + dist, memo}

      :error ->
        {distances, memo} =
          state.accessible_keys
          |> Enum.map_reduce(memo, fn key_pos, memo ->
            {dist, memo} = find_keys(state, memo, key_pos)
            {dist, memo}
          end)

        dist = Enum.min(distances)
        memo = Map.put(memo, {state.pos, keys_string}, dist - state.distance)
        {dist, memo}
    end
  end

  defp find_keys(state, memo, next_key_pos) do
    key_distance = Map.fetch!(state.distances, {state.pos, next_key_pos})

    key_letter = Map.fetch!(state.keys, next_key_pos)
    door_letter = String.upcase(key_letter)
    # Should be able to lookup door_pos
    door_pos =
      state.doors
      |> Enum.find(fn {_pos, letter} -> letter == door_letter end)
      |> case do
        nil -> nil
        {pos, _letter} -> pos
      end

    %{
      state
      | keys: Map.delete(state.keys, next_key_pos),
        doors: Map.delete(state.doors, door_pos),
        pos: next_key_pos,
        accessible_keys: MapSet.delete(state.accessible_keys, next_key_pos),
        distance: state.distance + key_distance,
        keys_found: state.keys_found <> key_letter
    }
    |> find_keys(memo)
  end

  # A*
  defp shortest_path_between(state, a, b) do
    # Make this a priority-queue
    open = MapSet.new([a])
    distances = %{a => 0}

    shortest_path_to(state, b, open, distances)
  end

  defp shortest_path_to(state, target, open, distances) do
    {x, y} = pos = open |> Enum.min_by(&(Map.fetch!(distances, &1) + manhattan_distance(&1, target)))

    if pos == target do
      Map.fetch!(distances, target)
    else
      open = MapSet.delete(open, pos)

      {open, distances} =
        [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
        |> Enum.map(fn {dir_x, dir_y} -> {x + dir_x, y + dir_y} end)
        |> Enum.reject(&MapSet.member?(state.walls, &1))
        |> Enum.reduce({open, distances}, fn neighbour, {open, distances} ->
          distance = Map.fetch!(distances, pos) + 1

          if not Map.has_key?(distances, neighbour) or distance < Map.fetch!(distances, neighbour) do
            distances = Map.put(distances, neighbour, distance)
            open = MapSet.put(open, neighbour)
            {open, distances}
          else
            {open, distances}
          end
        end)

      shortest_path_to(state, target, open, distances)
    end
  end

  defp manhattan_distance({x1, y1}, {x2, y2}), do: abs(x2 - x1) + abs(y2 - y1)

  defp update_accessible_area(state) do
    state.edge_tiles
    |> Enum.reduce(state, &update_accessible_area(&2, &1))
  end

  defp update_accessible_area(state, {x, y} = pos) do
    {state, by_edge} =
      [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
      |> Enum.reduce({state, false}, fn {dir_x, dir_y}, {state, by_edge} ->
        new_pos = {x + dir_x, y + dir_y}

        cond do
          Map.has_key?(state.doors, new_pos) ->
            {state, true}

          MapSet.member?(state.accessible_tiles, new_pos) ->
            {state, by_edge}

          MapSet.member?(state.walls, new_pos) ->
            {state, by_edge}

          Map.has_key?(state.keys, new_pos) ->
            {%{state | accessible_keys: MapSet.put(state.accessible_keys, new_pos)}, true}

          true ->
            {%{state | accessible_tiles: MapSet.put(state.accessible_tiles, new_pos)}
             |> update_accessible_area(new_pos), by_edge}
        end
      end)

    if by_edge do
      %{state | edge_tiles: MapSet.put(state.edge_tiles, pos)}
    else
      %{state | edge_tiles: MapSet.delete(state.edge_tiles, pos)}
    end
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(empty_state(), fn {line, y}, state -> parse_line(state, line, y) end)
  end

  defp parse_line(state, line, y) do
    line
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.reduce(state, fn {char, x}, state ->
      pos = {x, y}

      case char do
        ?# ->
          %{state | walls: MapSet.put(state.walls, pos)}

        key when ?a <= key and key <= ?z ->
          %{state | keys: Map.put(state.keys, pos, <<key>>)}

        door when ?A <= door and door <= ?Z ->
          %{state | doors: Map.put(state.doors, pos, <<door>>)}

        ?@ ->
          %{
            state
            | pos: {x, y},
              accessible_tiles: MapSet.put(state.accessible_tiles, {x, y}),
              edge_tiles: MapSet.put(state.edge_tiles, {x, y})
          }

        ?. ->
          state
      end
    end)
  end
end
