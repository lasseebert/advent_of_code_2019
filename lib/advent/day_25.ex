defmodule Advent.Day25 do
  @moduledoc """
  ASCII adventure game!
  """

  alias Advent.Intcode

  @doc """
  Part 1

  First pick up all items
  Then try all combinations of items

  Not optimized at all, runs in ~550 ms
  """
  def find_password(raw_program) do
    commands = pick_up_all_items() ++ build_combinations()

    last_output_line =
      raw_program
      |> Intcode.parse_program()
      |> Intcode.run_with_io(&io/1, %{inputs: commands, outputs: []})
      |> Map.fetch!(:outputs)
      |> Enum.reverse()
      |> :binary.list_to_bin()
      |> String.split("\n", trim: true)
      |> Enum.reverse()
      |> hd()

    [password] = Regex.run(~r/\d+/, last_output_line)
    password
  end

  defp io({:output, char, state}) when char <= 0xFF do
    # Enable this line to run in interactive ASCII mode
    # IO.write(<<char>>)
    %{state | outputs: [char | state.outputs]}
  end

  # For manual input if inputs is empty
  defp io({:input, %{inputs: []} = state}) do
    [first | rest] = IO.read(:line) |> String.to_charlist()
    {first, %{state | inputs: rest}}
  end

  defp io({:input, %{inputs: [first | rest]} = state}) do
    {first, %{state | inputs: rest}}
  end

  defp io({:program_exit, _, state}), do: state

  defp pick_up_all_items do
    """
    west
    west
    take loom
    east
    east
    north
    north
    take mutex
    east
    take tambourine
    west
    south
    west
    take antenna
    south
    take hologram
    south
    take mug
    north
    west
    take astronaut ice cream
    east
    north
    north
    north
    north
    take space heater
    north
    east
    """
    |> String.to_charlist()
  end

  defp build_combinations do
    items = [
      "loom",
      "mutex",
      "tambourine",
      "antenna",
      "hologram",
      "mug",
      "astronaut ice cream",
      "space heater"
    ]

    try_items(items)
    |> Enum.join("")
    |> String.to_charlist()
  end

  defp try_items([first | rest]) do
    ["drop #{first}\n"] ++
      try_items(rest) ++
      ["take #{first}\n"] ++ try_items(rest)
  end

  defp try_items([]), do: ["east\n"]
end
