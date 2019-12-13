defmodule Advent.Arcade do
  @moduledoc """
  An interstellar arcade machine capable of running Intcode games

  This must be run with an escript to be able to read keypresses.
  """

  alias Advent.Intcode
  alias IO.ANSI

  def main(_args), do: run(:bloxx)

  @doc "Run the Bloxx™ game"
  def run(:bloxx) do
    File.read!("input_files/day_13.int")
    |> Intcode.parse_program()
    # Insert quarters
    |> Intcode.put_program_address(0, 2)
    |> run()
  end

  @doc "Run the intcode program on the arcade machine"
  def run(program) do
    intcode = Intcode.run(program, :arcade, timeout: 20_000)

    spawn_joystick(intcode)

    IO.write(ANSI.clear())
    draw_screen()
  end

  defp spawn_joystick(intcode) do
    spawn(fn ->
      Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])
      read_key(intcode)
    end)
  end

  defp read_key(intcode) do
    receive do
      {_port, {:data, data}} ->
        data
        |> translate_key()
        |> handle_key(intcode)
    after
      500 -> handle_key(nil, intcode)
    end

    read_key(intcode)
  end

  defp translate_key("\e[C"), do: :right
  defp translate_key("\e[D"), do: :left
  defp translate_key(_other), do: :other

  defp handle_key(:left, intcode), do: send(intcode, {:input, -1})
  defp handle_key(:right, intcode), do: send(intcode, {:input, 1})
  defp handle_key(_, intcode), do: send(intcode, {:input, 0})

  defp draw_screen do
    case receive_tile() do
      :program_exit ->
        :ok

      {-1, 0, score} ->
        print_score(score)
        draw_screen()

      {x, y, tile_id} ->
        print_tile(x, y, tile_id)
        draw_screen()
    end
  end

  defp print_tile(x, y, tile_id) do
    # IO.inspect({x, y, render_tile(tile_id)})
    [
      ANSI.cursor(y + 1, x),
      render_tile(tile_id)
    ]
    |> IO.write()
  end

  defp print_score(score) do
    score = score |> Integer.to_string() |> String.pad_leading(10, " ")

    [
      ANSI.cursor(23, 28),
      score
    ]
    |> IO.write()
  end

  defp render_tile(0), do: " "
  defp render_tile(1), do: "X"
  defp render_tile(2), do: [ANSI.yellow(), "#", ANSI.reset()]
  defp render_tile(3), do: "-"
  defp render_tile(4), do: [ANSI.light_blue(), "@", ANSI.reset()]

  defp receive_tile do
    with {:ok, a} <- receive_output(),
         {:ok, b} <- receive_output(),
         {:ok, c} <- receive_output() do
      {a, b, c}
    else
      :program_exit -> :program_exit
    end
  end

  defp receive_output do
    receive do
      {:output, :arcade, value} -> {:ok, value}
      {:program_exit, :arcade, _state} -> :program_exit
    end
  end
end
