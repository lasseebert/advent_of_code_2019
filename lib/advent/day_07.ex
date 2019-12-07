defmodule Advent.Day07 do
  @moduledoc """
  Day 7: Amplification Circuit

  Brute forces all combination of phase settings.
  Starts one process for each amp and connects outputs to inputs
  The last output from the last amp is the thruster input

  Part 1 and 2 are identical except for the phase settings
  """

  alias Advent.Intcode

  @doc """
  Part 1
  Runtime ~50ms (yes, that's 5!*5 = 600 processes starting, running an Intcode program and stopping again in 50ms :))
  """
  def max_thrust(program) do
    sequences([0, 1, 2, 3, 4])
    |> Enum.map(fn phase_settings -> run(program, phase_settings) end)
    |> Enum.max()
  end

  @doc """
  Part 2
  Runtime ~90ms
  """
  def max_thrust_feedback(program) do
    sequences([5, 6, 7, 8, 9])
    |> Enum.map(fn phase_settings -> run(program, phase_settings) end)
    |> Enum.max()
  end

  defp run(program, phase_settings) do
    amps =
      0..4
      |> Enum.zip(phase_settings)
      |> Enum.into(%{}, fn {amp, phase_setting} ->
        pid = Intcode.run(program, amp)
        send(pid, {:input, phase_setting})
        {amp, pid}
      end)

    send(Map.fetch!(amps, 0), {:input, 0})
    connect_outputs_to_inputs(amps)
  end

  defp connect_outputs_to_inputs(amps, last_output \\ nil) do
    receive do
      {:output, amp, value} ->
        next_amp = rem(amp + 1, 5)
        send(Map.fetch!(amps, next_amp), {:input, value})
        connect_outputs_to_inputs(amps, {amp, value})

      {:program_exit, 4, _state} ->
        {4, output} = last_output
        output
    end
  end

  defp sequences([]), do: [[]]

  defp sequences(list) do
    list
    |> Enum.flat_map(fn item ->
      (list -- [item])
      |> sequences()
      |> Enum.map(&[item | &1])
    end)
  end
end
