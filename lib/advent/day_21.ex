defmodule Advent.Day21 do
  @moduledoc """
  Jumpdroid!
  """

  alias Advent.Intcode

  @doc """
  Part 1
  """
  def walk(raw_program) do
    springscript =
      """
      NOT A T
      OR T J
      NOT B T
      OR T J
      NOT C T
      OR T J
      AND D J
      WALK
      """
      |> String.to_charlist()

    raw_program
    |> Intcode.parse_program()
    |> Intcode.run_with_io(&io/1, %{inputs: springscript, result: nil})
    |> Map.fetch!(:result)
  end

  @doc """
  Part 2

  Runtime is ~830ms on my machine
  """
  def run(raw_program) do
    springscript =
      """
      NOT A T
      OR T J
      NOT B T
      OR T J
      NOT C T
      OR T J
      AND D J
      NOT A T
      OR E T
      OR H T
      AND T J
      RUN
      """
      |> String.to_charlist()

    raw_program
    |> Intcode.parse_program()
    |> Intcode.run_with_io(&io/1, %{inputs: springscript, result: nil})
    |> Map.fetch!(:result)
  end

  defp io({:output, ascii, state}) when ascii <= 0xFF, do: state
  defp io({:output, result, state}) when result > 0xFF, do: %{state | result: result}
  defp io({:input, %{inputs: [char | rest]} = state}), do: {char, %{state | inputs: rest}}
  defp io({:program_exit, _, state}), do: state
end
