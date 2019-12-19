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
  @spec run(program, tag, timeout: timeout) :: pid
  def run(program, tag, options \\ []) do
    program
    |> RuntimeState.new()
    |> Runner.run_async(tag, options)
  end

  @doc """
  Convinience function to run a program and supply it with the given input.
  Returns a list of outputs and the exited state
  """
  @spec run_with_inputs(program, [value]) :: {[value], RuntimeState.t()}
  def run_with_inputs(program, inputs) do
    program
    |> RuntimeState.new()
    |> Runner.run_sync(inputs)
  end

  @doc """
  Run in the same process as the caller and have full control of IO with the provided IO function and custom state
  Returns the resulting caller state
  """
  @spec run_with_io(program, function, any) :: any
  def run_with_io(program, io, caller_state) do
    %{RuntimeState.new(program) | io: io, caller_state: caller_state}
    |> Runner.run()
    |> Map.fetch!(:caller_state)
  end

  @doc """
  Sends input to a running Intcode program
  """
  def send_input(pid, message), do: send(pid, {:input, message})

  @doc """
  Receives output from a running Intcode program.
  """
  @spec receive_output(atom, timeout) :: {:ok, integer} | :timeout | :program_exit
  def receive_output(tag, timeout \\ 5_000) do
    receive do
      {:output, ^tag, output} -> {:ok, output}
      {:program_exit, ^tag, _state} -> :program_exit
    after
      timeout -> :timeout
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
