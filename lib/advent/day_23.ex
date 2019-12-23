defmodule Advent.Day23 do
  @moduledoc """
  Async intcode
  """

  alias Advent.Intcode

  @doc """
  Part 1+2

  This is in a state of "Working and messy"
  Will refactor and possibly optimize later
  """
  def run(raw_program, with_nat) do
    program = raw_program |> Intcode.parse_program()

    computers =
      0..49
      |> Enum.into(%{}, fn index ->
        computer = Intcode.run(program, index)
        {index, computer}
      end)

    messages = 0..49 |> Enum.into(%{}, &{&1, [&1]})

    state = %{
      computers: computers,
      messages: messages,
      nat: if(with_nat, do: :empty, else: false),
      last_nat_send: nil,
      idle_candidates: MapSet.new(),
      idle: MapSet.new()
    }

    io(state)
  end

  defp io(state) do
    receive do
      {:input, caller} ->
        case Map.fetch!(state.messages, caller) do
          [] ->
            send_to_computer(state, caller, -1)
            state = state |> set_idle(caller)

            if all_idle?(state) do
              {x, y} = state.nat

              if state.nat == state.last_nat_send do
                y
              else
                %{state | messages: %{state.messages | 0 => [x, y]}, last_nat_send: {x, y}}
                |> io()
              end
            else
              io(state)
            end

          [first | rest] ->
            send_to_computer(state, caller, first)

            %{state | messages: %{state.messages | caller => rest}}
            |> set_active(caller)
            |> io()
        end

      {:output, caller, 255} ->
        {x, y} = receive_xy(caller)

        if state.nat do
          %{state | nat: {x, y}}
          |> set_active(caller)
          |> io()
        else
          y
        end

      {:output, caller, target} ->
        state =
          state
          |> receive_and_queue(caller, target)
          |> set_active(caller)

        io(state)
    after
      5_000 -> raise "ERROR: Timeout waiting for messages"
    end
  end

  defp set_idle(state, index) do
    if MapSet.member?(state.idle_candidates, index) do
      %{state | idle: MapSet.put(state.idle, index)}
    else
      %{state | idle_candidates: MapSet.put(state.idle_candidates, index)}
    end
  end

  defp set_active(state, index) do
    %{state | idle: MapSet.delete(state.idle, index), idle_candidates: MapSet.delete(state.idle_candidates, index)}
  end

  defp all_idle?(state) do
    state.nat != false and Enum.count(state.idle) == Enum.count(state.computers) and
      state.messages |> Map.values() |> List.flatten() == []
  end

  defp send_to_computer(state, index, value) do
    computer = Map.fetch!(state.computers, index)
    send(computer, {:input, value})
  end

  defp receive_and_queue(state, caller, target) do
    {x, y} = receive_xy(caller)
    messages = state.messages |> Map.update!(target, &(&1 ++ [x, y]))
    %{state | messages: messages}
  end

  defp receive_xy(caller) do
    0..1
    |> Enum.map(fn _ -> receive_output(caller) end)
    |> List.to_tuple()
  end

  defp receive_output(caller) do
    receive do
      {:output, ^caller, value} -> value
    after
      5_000 -> raise "ERROR: Timeout waiting for output from Intcode"
    end
  end
end
