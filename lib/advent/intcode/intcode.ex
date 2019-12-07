defmodule Advent.Intcode do
  @moduledoc """
  Intcode runtime
  """

  alias Advent.Intcode
  alias Advent.Intcode.RuntimeState

  @opaque program :: map
  @type value :: integer
  @type address :: non_neg_integer

  @doc """
  Runs an Intcode program in a supervised process
  When an input is needed, {:input, pid} is sent to the calling process that must respond with {:input, value}
  When the program outputs something {:output, value} is sent to the calling process
  When the program exists, {:program_exit, state} is sent the the caller.
  """
  @spec run(program) :: :ok
  def run(program) do
    program
    |> RuntimeState.new(self())
    |> Intcode.Supervisor.run()
  end

  @doc """
  Convinience function to run a program and supply it with the given input.
  Returns a list of outputs and the exited state
  """
  @spec run_with_inputs(program, [value], timeout) :: {[value], RuntimeState.t()}
  def run_with_inputs(program, inputs, timeout \\ 1_000) do
    run(program)

    Enum.each(inputs, fn input ->
      receive do
        {:input, pid} -> send(pid, {:input, input})
      after
        timeout -> raise "timeout"
      end
    end)

    receive_outputs(timeout, [])
  end

  defp receive_outputs(timeout, acc) do
    receive do
      {:output, value} -> receive_outputs(timeout, [value | acc])
      {:program_exit, state} -> {Enum.reverse(acc), state}
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
