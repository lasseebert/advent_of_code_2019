defmodule Advent.Intcode.Runner do
  @moduledoc """
  Runs an Intcode program in a process
  """

  use GenServer

  def child_spec(state) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [state]},
      type: :worker,
      restart: :transient
    }
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  @impl GenServer
  def init(state) do
    {:ok, state, {:continue, :run}}
  end

  @impl GenServer
  def handle_continue(:run, state) do
    run(state)
    {:stop, :normal, state}
  end

  def run(%{exited: true} = state), do: state

  def run(state) do
    {operation, state} = take_operation(state)

    state
    |> run_operation(operation)
    |> run()
  end

  defp run_operation(state, {:add, [a, b, addr]}) do
    [a, b] = [a, b] |> Enum.map(&read_var(state, &1))
    write(state, addr, a + b)
  end

  defp run_operation(state, {:mult, [a, b, addr]}) do
    [a, b] = [a, b] |> Enum.map(&read_var(state, &1))
    write(state, addr, a * b)
  end

  defp run_operation(state, {:input, [addr]}) do
    value =
      receive do
        {:input, value} -> value
      after
        1_000 -> raise "timeout waiting for input"
      end

    write(state, addr, value)
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

  defp run_operation(state, {:less_than, [a, b, addr]}) do
    [a, b] = [a, b] |> Enum.map(&read_var(state, &1))
    result = if a < b, do: 1, else: 0
    write(state, addr, result)
  end

  defp run_operation(state, {:equals, [a, b, addr]}) do
    [a, b] = [a, b] |> Enum.map(&read_var(state, &1))
    result = if a == b, do: 1, else: 0
    write(state, addr, result)
  end

  defp run_operation(state, {:relative_base, [a]}) do
    a = read_var(state, a)
    %{state | relative_base: state.relative_base + a}
  end

  defp run_operation(state, {:exit, []}) do
    state = %{state | exited: true}
    send(state.caller, {:program_exit, state.tag, state})
    state
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
  defp instruction(9), do: {:relative_base, 1}
  defp instruction(99), do: {:exit, 0}

  defp build_params(state, start_address, opcode, num_params) do
    Stream.unfold({0, 100}, fn
      {index, place} ->
        type =
          case opcode |> div(place) |> rem(10) do
            0 -> :ref
            1 -> :imm
            2 -> :rel
          end

        value = read(state, start_address + index)
        {{type, value}, {index + 1, place * 10}}
    end)
    |> Enum.take(num_params)
  end

  defp read(state, address) do
    Map.get(state.program, address, 0)
  end

  defp write(state, {:ref, addr}, value), do: write(state, addr, value)
  defp write(state, {:rel, addr}, value), do: write(state, addr + state.relative_base, value)

  defp write(state, address, value) when is_integer(address) do
    %{state | program: Map.put(state.program, address, value)}
  end

  defp read_var(state, {:ref, addr}), do: read(state, addr)
  defp read_var(_state, {:imm, value}), do: value
  defp read_var(state, {:rel, addr}), do: read(state, addr + state.relative_base)

  defp output(state, value) do
    send(state.caller, {:output, state.tag, value})
    state
  end

  defp jump(state, addr) do
    %{state | pointer: addr}
  end
end
