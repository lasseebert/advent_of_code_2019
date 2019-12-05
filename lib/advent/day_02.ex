defmodule Advent.Day02 do
  @moduledoc """
  Not optimized. Part 2 is brute forced and runs in ~75 ms
  """

  def part_1(input, noun, verb) do
    input
    |> parse()
    |> run_program(noun, verb)
  end

  def part_2(input, target) do
    program = parse(input)

    {noun, verb} =
      for noun <- 0..99,
          verb <- 0..99 do
        {noun, verb}
      end
      |> Enum.find(fn {noun, verb} -> run_program(program, noun, verb) == target end)

    100 * noun + verb
  end

  defp run_program(program, noun, verb) do
    %{program | 1 => noun, 2 => verb}
    |> run(0)
    |> Map.fetch!(0)
  end

  defp run(program, pointer) do
    case opcode(program, pointer) do
      :add ->
        program
        |> write_ref(pointer + 3, read_ref(program, pointer + 1) + read_ref(program, pointer + 2))
        |> run(pointer + 4)

      :mult ->
        program
        |> write_ref(pointer + 3, read_ref(program, pointer + 1) * read_ref(program, pointer + 2))
        |> run(pointer + 4)

      :exit ->
        program
    end
  end

  defp opcode(program, pointer) do
    case Map.fetch!(program, pointer) do
      1 -> :add
      2 -> :mult
      99 -> :exit
    end
  end

  defp read_ref(program, pointer) do
    address = Map.fetch!(program, pointer)
    Map.fetch!(program, address)
  end

  defp write_ref(program, pointer, value) do
    address = Map.fetch!(program, pointer)
    %{program | address => value}
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {value, index} -> {index, value} end)
  end
end
