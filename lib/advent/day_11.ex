defmodule Advent.Day11 do
  @moduledoc """
  Emergency Hull Painting Robot

  No optimizations and no cleanup yet.
  """

  alias Advent.Intcode

  @doc "Part1"
  def paint(raw_program) do
    brain = raw_program |> Intcode.parse_program() |> Intcode.run(:paint)
    grid = %{}
    dir = {1, 0}
    pos = {0, 0}

    state = %{
      brain: brain,
      grid: grid,
      dir: dir,
      pos: pos
    }

    state
    |> run()
    |> Map.fetch!(:grid)
    |> Enum.count()
  end

  @doc "Part2"
  def paint_again(raw_program) do
    brain = raw_program |> Intcode.parse_program() |> Intcode.run(:paint)
    grid = %{{0, 0} => 1}
    dir = {1, 0}
    pos = {0, 0}

    state = %{
      brain: brain,
      grid: grid,
      dir: dir,
      pos: pos
    }

    state
    |> run()
    |> visualize()
  end

  defp run(state) do
    send(state.brain, {:input, Map.get(state.grid, state.pos, 0)})

    receive do
      {:program_exit, :paint, _state} ->
        state

      {:output, :paint, paint_color} ->
        state = paint(state, paint_color)

        receive do
          {:output, :paint, dir} ->
            state
            |> turn(dir)
            |> forward()
            |> run()
        end
    end
  end

  defp paint(state, color), do: %{state | grid: Map.put(state.grid, state.pos, color)}

  defp turn(%{dir: {x, y}} = state, 0), do: %{state | dir: {-y, x}}
  defp turn(%{dir: {x, y}} = state, 1), do: %{state | dir: {y, -x}}

  defp forward(%{dir: {dx, dy}, pos: {x, y}} = state), do: %{state | pos: {x + dx, y + dy}}

  defp visualize(%{grid: grid}) do
    min_x = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.min()
    max_x = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    min_y = grid |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.min()
    max_y = grid |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()

    # For some reason take this in the wrong order
    text =
      max_x..min_x
      |> Enum.map(fn y ->
        max_y..min_y
        |> Enum.map(fn x -> panel_text(Map.get(grid, {y, x}, 0)) end)
        |> Enum.join()
      end)
      |> Enum.join("\n")

    text <> "\n"
  end

  defp panel_text(0), do: " "
  defp panel_text(1), do: "#"
end
