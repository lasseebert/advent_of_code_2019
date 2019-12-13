defmodule Advent.Intcode do
  @moduledoc """
  Intcode runtime
  """

  alias Advent.Intcode.Runner
  alias Advent.Intcode.RuntimeState

  @opaque program :: map
  @type value :: integer
  @type address :: non_neg_integer
  @type tag :: any

  @doc """
  Runs an Intcode program in a supervised process with a tag
  When an input is needed, {:input, value} is received in the program process
  When the program outputs something {:output, tag, value} is sent to the calling process
  When the program exists, {:program_exit, tag, state} is sent the the caller.
  """
  @spec run(program, tag) :: pid
  def run(program, tag) do
    {:ok, pid} =
      program
      |> RuntimeState.new(self(), tag)
      |> Runner.start_link()

    pid
  end

  @doc """
  Convinience function to run a program and supply it with the given input.
  Returns a list of outputs and the exited state
  """
  @spec run_with_inputs(program, [value], timeout) :: {[value], RuntimeState.t()}
  def run_with_inputs(program, inputs, timeout \\ 1_000) do
    pid = run(program, :run_with_inputs)

    Enum.each(inputs, fn input ->
      send(pid, {:input, input})
    end)

    receive_outputs(timeout, [])
  end

  defp receive_outputs(timeout, acc) do
    receive do
      {:output, :run_with_inputs, value} -> receive_outputs(timeout, [value | acc])
      {:program_exit, :run_with_inputs, state} -> {Enum.reverse(acc), state}
    after
      timeout -> raise "timeout"
    end
  end

  @doc """
  Parses a string representation of a program into a program
  """
  @spec parse_program(String.t()) :: program
  def parse_program(string) do
    string
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {value, index} -> {index, value} end)
  end

  @doc "Sets the address of a program to the given value"
  @spec put_program_address(program, address, value) :: program
  def put_program_address(program, address, value), do: Map.put(program, address, value)

  @doc "Gets the value of a given address in a program"
  @spec get_program_address(program, address) :: value
  def get_program_address(program, address), do: Map.fetch!(program, address)
end
