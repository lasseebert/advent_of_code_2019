defmodule Advent.Day20 do
  @moduledoc """
  Donut mazes!
  """

  defmodule Part1 do
    @moduledoc """
    Finds shortest path in a single-layer maze using BFS
    """

    def shortest_path(input) do
      input
      |> parse()
      |> find_shortest_path()
    end

    defp find_shortest_path({paths, src, dest}) do
      worklist = [src]
      distance = 0
      distances = %{src => 0}

      find_shortest_paths(paths, worklist, distances, distance)
      |> Map.fetch!(dest)
    end

    defp find_shortest_paths(_, [], distances, _), do: distances

    defp find_shortest_paths(paths, worklist, distances, distance) do
      worklist =
        worklist
        |> Enum.flat_map(fn pos ->
          paths
          |> Map.fetch!(pos)
          |> Enum.reject(&Map.has_key?(distances, &1))
        end)

      distance = distance + 1
      distances = worklist |> Enum.reduce(distances, &Map.put(&2, &1, distance))
      find_shortest_paths(paths, worklist, distances, distance)
    end

    defp parse(input) do
      input
      |> tokenize()
      |> parse_labels()
      |> build_map()
    end

    defp build_map({maze, labels}) do
      reverse_labels =
        labels
        |> Enum.reduce(%{}, fn {pos, label}, reverse_labels ->
          Map.update(reverse_labels, label, [pos], &[pos | &1])
        end)

      [src] = Map.fetch!(reverse_labels, "AA")
      [dest] = Map.fetch!(reverse_labels, "ZZ")

      reverse_labels = reverse_labels |> Map.delete("AA") |> Map.delete("ZZ")
      labels = labels |> Map.delete(src) |> Map.delete(dest)

      paths =
        maze
        |> Enum.reduce(%{}, fn {x, y} = pos, paths ->
          dirs =
            [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
            |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
            |> Enum.filter(&MapSet.member?(maze, &1))

          dirs =
            if label = Map.get(labels, pos) do
              [portal_dest] = Map.fetch!(reverse_labels, label) |> Enum.reject(&(&1 == pos))
              [portal_dest | dirs]
            else
              dirs
            end

          Map.put(paths, pos, dirs)
        end)

      {
        paths,
        src,
        dest
      }
    end

    defp parse_labels({maze, letter_map}) do
      labels =
        letter_map
        |> Enum.reduce(%{}, fn {{x, y}, letter_1}, labels ->
          cond do
            letter_2 = Map.get(letter_map, {x, y + 1}) ->
              label = letter_1 <> letter_2
              pos = [{x, y - 1}, {x, y + 2}] |> Enum.find(&MapSet.member?(maze, &1))
              Map.put(labels, pos, label)

            letter_2 = Map.get(letter_map, {x + 1, y}) ->
              label = letter_1 <> letter_2
              pos = [{x - 1, y}, {x + 2, y}] |> Enum.find(&MapSet.member?(maze, &1))
              Map.put(labels, pos, label)

            true ->
              labels
          end
        end)

      {maze, labels}
    end

    defp tokenize(input) do
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce({MapSet.new(), %{}}, fn {line, y}, acc ->
        line
        |> String.to_charlist()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {char, x}, {maze, letters} ->
          case char do
            letter when letter in ?A..?Z -> {maze, Map.put(letters, {x, y}, <<letter>>)}
            ?. -> {MapSet.put(maze, {x, y}), letters}
            _ -> {maze, letters}
          end
        end)
      end)
    end
  end

  defmodule Part2 do
    @moduledoc """
    Finds shortest path in a multi-layer maze using BFS that halts on the correct destination

    Runs in ~900ms
    """

    def shortest_path(input) do
      input
      |> parse()
      |> find_shortest_path()
    end

    defp find_shortest_path({paths, src, dest}) do
      nodes = MapSet.new([src])
      distance = 0
      visited = MapSet.new([src])

      find_shortest_paths(paths, dest, nodes, distance, visited)
    end

    defp find_shortest_paths(paths, dest, nodes, distance, visited) do
      nodes =
        nodes
        |> Enum.flat_map(fn {level, pos} ->
          paths
          |> Map.fetch!(pos)
          |> Enum.map(fn {d_level, pos} -> {level + d_level, pos} end)
          |> Enum.reject(&MapSet.member?(visited, &1))
          |> Enum.reject(&(elem(&1, 0) < 0))
        end)
        |> MapSet.new()

      distance = distance + 1

      if dest in nodes do
        distance
      else
        visited = nodes |> Enum.reduce(visited, &MapSet.put(&2, &1))
        find_shortest_paths(paths, dest, nodes, distance, visited)
      end
    end

    defp parse(input) do
      input
      |> tokenize()
      |> parse_labels()
      |> build_map()
    end

    defp build_map({maze, labels}) do
      reverse_labels = labels |> Enum.into(%{}, fn {pos, label} -> {label, pos} end)

      src = Map.fetch!(reverse_labels, {:outer, "AA"})
      dest = Map.fetch!(reverse_labels, {:outer, "ZZ"})

      reverse_labels = reverse_labels |> Map.delete({:outer, "AA"}) |> Map.delete({:outer, "ZZ"})
      labels = labels |> Map.delete(src) |> Map.delete(dest)

      paths =
        maze
        |> Enum.reduce(%{}, fn {x, y} = pos, paths ->
          dirs =
            [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
            |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
            |> Enum.filter(&MapSet.member?(maze, &1))
            |> Enum.map(&{0, &1})

          dirs =
            case Map.fetch(labels, pos) do
              {:ok, {type, label}} ->
                reverse_type = if type == :outer, do: :inner, else: :outer
                level = if type == :outer, do: -1, else: 1
                portal_dest = Map.fetch!(reverse_labels, {reverse_type, label})
                [{level, portal_dest} | dirs]

              :error ->
                dirs
            end

          Map.put(paths, pos, dirs)
        end)

      {
        paths,
        {0, src},
        {0, dest}
      }
    end

    defp parse_labels({maze, letter_map}) do
      max_x = maze |> Enum.map(&elem(&1, 0)) |> Enum.max()
      max_y = maze |> Enum.map(&elem(&1, 1)) |> Enum.max()

      labels =
        letter_map
        |> Enum.reduce(%{}, fn {{x, y}, letter_1}, labels ->
          cond do
            letter_2 = Map.get(letter_map, {x, y + 1}) ->
              label = letter_1 <> letter_2
              {_, py} = pos = [{x, y - 1}, {x, y + 2}] |> Enum.find(&MapSet.member?(maze, &1))
              type = if py == 0 or py == max_y, do: :outer, else: :inner
              Map.put(labels, pos, {type, label})

            letter_2 = Map.get(letter_map, {x + 1, y}) ->
              label = letter_1 <> letter_2
              {px, _} = pos = [{x - 1, y}, {x + 2, y}] |> Enum.find(&MapSet.member?(maze, &1))
              type = if px == 0 or px == max_x, do: :outer, else: :inner
              Map.put(labels, pos, {type, label})

            true ->
              labels
          end
        end)

      {maze, labels}
    end

    defp tokenize(input) do
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce({MapSet.new(), %{}}, fn {line, y}, acc ->
        line
        |> String.to_charlist()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {char, x}, {maze, letters} ->
          pos = {x - 2, y - 2}

          case char do
            letter when letter in ?A..?Z -> {maze, Map.put(letters, pos, <<letter>>)}
            ?. -> {MapSet.put(maze, pos), letters}
            _ -> {maze, letters}
          end
        end)
      end)
    end
  end
end
