defmodule Advent.Day13 do
  @moduledoc """
  ARCADE GAMES!!!
  """

  alias Advent.Intcode

  @doc "Part 1"
  def count_blocks(raw_program) do
    raw_program
    |> Intcode.parse_program()
    |> Intcode.run_with_io(&io_count/1, [])
    |> Enum.chunk_every(3)
    |> Enum.map(fn [_x, _y, tile_id] -> tile_id end)
    |> Enum.filter(&(&1 == 2))
    |> length()
  end

  defp io_count({:output, value, outputs}), do: [value | outputs]
  defp io_count({:program_exit, _state, outputs}), do: Enum.reverse(outputs)

  @doc """
  I have implemeted a playable version in Advent.Arcade to figure out what the game was
  This function implements an AI to win the game and returns the final score
  """
  def win_game(raw_program) do
    raw_program
    |> Intcode.parse_program()
    |> insert_quarters()
    |> Intcode.run_with_io(&io_win/1, %{score: 0, pad_pos: nil, ball_pos: nil, tile_info: []})
    |> Map.fetch!(:score)
  end

  defp insert_quarters(program), do: Intcode.put_program_address(program, 0, 2)

  defp io_win({:output, x, %{tile_info: []} = state}), do: %{state | tile_info: [x]}
  defp io_win({:output, y, %{tile_info: [x]} = state}), do: %{state | tile_info: [x, y]}
  defp io_win({:output, score, %{tile_info: [-1, 0]} = state}), do: %{state | score: score, tile_info: []}
  defp io_win({:output, 3, %{tile_info: [x, _y]} = state}), do: %{state | pad_pos: x, tile_info: []}
  defp io_win({:output, 4, %{tile_info: [x, _y]} = state}), do: %{state | ball_pos: x, tile_info: []}
  defp io_win({:output, _, %{tile_info: [_x, _y]} = state}), do: %{state | tile_info: []}
  defp io_win({:program_exit, _, state}), do: state

  # The very complicated AI - move the pad towards the ball
  defp io_win({:input, state}) do
    cond do
      state.pad_pos < state.ball_pos -> {1, state}
      state.pad_pos == state.ball_pos -> {0, state}
      state.pad_pos > state.ball_pos -> {-1, state}
    end
  end
end
