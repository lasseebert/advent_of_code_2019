defmodule Advent.Day05 do
  @moduledoc """
  No optimization done for this one. It already runs in less than 1 ms.
  """

  alias Advent.Intcode

  @doc """
  Part 1+2
  """
  def run_diagnostics(raw_program, input) do
    raw_program
    |> Intcode.parse_program()
    |> Intcode.run_with_inputs([input])
    |> elem(0)
    |> Enum.uniq()
    |> case do
      [output] -> output
      [0, output] -> output
    end
  end
end
