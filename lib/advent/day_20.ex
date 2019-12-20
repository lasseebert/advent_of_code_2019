defmodule Advent.Day20 do
  @moduledoc """
  Donut mazes!
  """

  @doc """
  Part 1
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
      |> Enum.reduce(%{}, fn {pos, label}, reverse_labels -> Map.update(reverse_labels, label, [pos], &[pos | &1]) end)

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
