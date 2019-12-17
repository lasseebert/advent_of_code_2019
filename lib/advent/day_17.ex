defmodule Advent.Day17 do
  @moduledoc """
  Day 17: Set and Forget
  """

  alias Advent.Intcode

  @doc """
  Part 1
  """
  def alignment_parameters_sum(raw_program) do
    maze =
      raw_program
      |> Intcode.parse_program()
      |> Intcode.run_with_io(&io_align/1, [])
      |> print_raw_maze()
      |> parse_maze()

    maze
    |> Enum.filter(fn {x, y} ->
      [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
      |> Enum.all?(&MapSet.member?(maze, &1))
    end)
    |> Enum.map(fn {x, y} -> x * y end)
    |> Enum.sum()
  end

  @doc """
  Part 2
  """
  def find_robots(raw_program) do
    # Solved by hand
    # Main: A,B,A,C,A,B,C,B,C,A
    # FunA: L,12,R,4,R,4,L,6
    # FunB: L,12,R,4,R,4,R,12
    # FunC: L,10,L,6,R,4

    inputs =
      [
        "A,B,A,C,A,B,C,B,C,A",
        "L,12,R,4,R,4,L,6",
        "L,12,R,4,R,4,R,12",
        "L,10,L,6,R,4",
        "n"
      ]
      |> Enum.map(&(&1 <> "\n"))
      |> Enum.join()
      |> :binary.bin_to_list()

    state = %{
      inputs: inputs,
      result: nil
    }

    raw_program
    |> Intcode.parse_program()
    |> Intcode.put_program_address(0, 2)
    |> Intcode.run_with_io(&io_find/1, state)
    |> Map.fetch!(:result)
  end

  defp io_align({:output, code, acc}), do: [acc | <<code>>]
  defp io_align({:program_exit, _state, acc}), do: :erlang.iolist_to_binary(acc)

  defp io_find({:output, code, state}) when code <= 255 do
    # IO.write(<<code>>)
    state
  end

  defp io_find({:output, result, state}) do
    # IO.puts("Result: #{result}")
    %{state | result: result}
  end

  defp io_find({:input, %{inputs: [input | inputs]} = state}) do
    {input, %{state | inputs: inputs}}
  end

  defp io_find({:program_exit, _, state}), do: state

  defp print_raw_maze(raw_maze) do
    # IO.puts(raw_maze)
    raw_maze
  end

  defp parse_maze(string_maze) do
    string_maze
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, y}, maze ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reject(fn {char, _index} -> char == "." end)
      |> Enum.reduce(maze, fn {_char, x}, maze ->
        MapSet.put(maze, {x, y})
      end)
    end)
  end
end
