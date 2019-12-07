defmodule Advent.Intcode do
  @moduledoc """
  Intcode runtime
  """

  alias Advent.Intcode.RuntimeState

  @opaque program :: map
  @type input :: value
  @type output :: value
  @type value :: integer
  @type address :: non_neg_integer

  @doc """
  Runs an Intcode program and returns the value of the output register.
  """
  @spec run(program, input) :: output
  def run(program, input) do
    RuntimeState.new(program, input)
    |> run()
    |> Map.fetch!(:output)
  end

  @doc """
  Runs an Intcode RuntimeState and returns the state when it has exited
  """
  @spec run(RuntimeState.t()) :: RuntimeState.t()
  def run(%{exited: true} = state), do: state

  def run(state) do
    {operation, state} = take_operation(state)

    state
    |> run_operation(operation)
    |> run()
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

  defp run_operation(state, {:add, [a, b, {:ref, addr}]}) do
    [a, b] = [a, b] |> Enum.map(&read_var(state, &1))
    write(state, addr, a + b)
  end

  defp run_operation(state, {:mult, [a, b, {:ref, addr}]}) do
    [a, b] = [a, b] |> Enum.map(&read_var(state, &1))
    write(state, addr, a * b)
  end

  defp run_operation(state, {:input, [{:ref, addr}]}) do
    write(state, addr, state.input)
  end

  defp run_operation(state, {:output, [var]}) do
    value = read_var(state, var)
    output(state, value)
  end

  defp run_operation(state, {:jump_if_true, vars}) do
    [test, addr] = Enum.map(vars, &read_var(state, &1))

    if test != 0 do
      jump(state, addr)
    else
      state
    end
  end

  defp run_operation(state, {:jump_if_false, vars}) do
    [test, addr] = Enum.map(vars, &read_var(state, &1))

    if test == 0 do
      jump(state, addr)
    else
      state
    end
  end

  defp run_operation(state, {:less_than, [a, b, {:ref, addr}]}) do
    [a, b] = [a, b] |> Enum.map(&read_var(state, &1))
    result = if a < b, do: 1, else: 0
    write(state, addr, result)
  end

  defp run_operation(state, {:equals, [a, b, {:ref, addr}]}) do
    [a, b] = [a, b] |> Enum.map(&read_var(state, &1))
    result = if a == b, do: 1, else: 0
    write(state, addr, result)
  end

  defp run_operation(state, {:exit, []}) do
    %{state | exited: true}
  end

  # Parses the next operation and sets the pointer to the next operation
  defp take_operation(state) do
    opcode = read(state, state.pointer)
    {instruction, num_params} = opcode |> rem(100) |> instruction()
    params = build_params(state, state.pointer + 1, opcode, num_params)
    state = %{state | pointer: state.pointer + num_params + 1}
    {{instruction, params}, state}
  end

  defp instruction(1), do: {:add, 3}
  defp instruction(2), do: {:mult, 3}
  defp instruction(3), do: {:input, 1}
  defp instruction(4), do: {:output, 1}
  defp instruction(5), do: {:jump_if_true, 2}
  defp instruction(6), do: {:jump_if_false, 2}
  defp instruction(7), do: {:less_than, 3}
  defp instruction(8), do: {:equals, 3}
  defp instruction(99), do: {:exit, 0}

  defp build_params(state, start_address, opcode, num_params) do
    Stream.unfold({0, 100}, fn
      {index, place} ->
        type =
          case opcode |> div(place) |> rem(10) do
            0 -> :ref
            1 -> :imm
          end

        value = read(state, start_address + index)
        {{type, value}, {index + 1, place * 10}}
    end)
    |> Enum.take(num_params)
  end

  defp read(state, address) do
    Map.fetch!(state.program, address)
  end

  defp write(state, address, value) do
    %{state | program: %{state.program | address => value}}
  end

  defp read_var(state, {:ref, addr}), do: read(state, addr)
  defp read_var(_state, {:imm, value}), do: value

  defp output(%{output: 0} = state, value) do
    %{state | output: value}
  end

  defp jump(state, addr) do
    %{state | pointer: addr}
  end
end
