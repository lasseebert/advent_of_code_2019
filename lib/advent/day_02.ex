defmodule Advent.Day02 do
  @moduledoc """
  I have by hand analyzed the program and found that the output is a linear function of the two inputs

    0: add nou ver   3 # Add two numbers referenced by noun and verb, save to v3
    4: add   1   2   3 # Overwrite v3 with noun + verb
    8: add   3   4   3 # Add 1 to v3
   12: add   5   0   3 # Overwrite v3 with 1. Everything below this point is a linear equation that is saved to output
   16: mul  10   1  19 # noun * 4
   20: add  19   9  23 # + 3
   24: add  23   6  27 # + 2
   28: add   9  27  31 # + 3
   32: add  31  10  35 # + 4
   36: mul  13  35  39 # * 5
   40: add  39  10  43 # + 4
   44: add  43   9  47 # + 3
   48: add  47  13  51 # + 5
   52: add  51  13  55 # + 5
   56: mul  55   6  59 # * 2
   60: add  59   5  63 # + 1
   64: mul  10  63  67 # * 4
   68: add  67   9  71 # + 3
   72: add  71  13  75 # + 5
   76: add   6  75  79 # + 2
   80: add  10  79  83 # + 4
   84: mul   9  83  87 # * 3
   88: add  87   5  91 # + 1
   92: mul  91   9  95 # * 3
   96: add   6  95  99 # + 2
  100: add  99   5 103 # + 1
  104: mul 103  10 107 # * 4
  108: add 107   6 111 # + 2
  112: mul   9 111 115 # * 3
  116: mul   9 115 119 # * 3
  120: mul  13 119 123 # * 5
  124: add 123   9 127 # + 3
  128: add   5 127 131 # + 1
  132: add 131   2 135 # + verb
  136: add 135   6   0 # + 2
  140: exit
  """

  alias Advent.Intcode

  def part_1(input, noun, verb) do
    input
    |> Intcode.parse_program()
    |> run_program(noun, verb)
  end

  @doc """
  Since the result is a linear function of the two inputs, we can write:

  f(n, v) = n*a + v*b + c

  f(0, 0) == f00 == c
  f(1, 0) == f10 == a + c
  f(0, 1) == f01 == b + c

  a = f10 - f00
  b = f01 - f00
  c = f00

  n = (target - v * b - c) / a
  """
  def part_2(input, target) do
    program = Intcode.parse_program(input)

    f00 = run_program(program, 0, 0)
    f10 = run_program(program, 1, 0)
    f01 = run_program(program, 0, 1)

    a = f10 - f00
    b = f01 - f00
    c = f00

    {noun, verb} =
      0..99
      |> Stream.map(fn verb ->
        d = target - verb * b - c
        noun = div(d, a)

        if rem(d, a) == 0 and noun in 0..99 do
          {noun, verb}
        else
          :error
        end
      end)
      |> Enum.find(&(&1 != :error))

    100 * noun + verb
  end

  defp run_program(program, noun, verb) do
    program
    |> Intcode.put_program_address(1, noun)
    |> Intcode.put_program_address(2, verb)
    |> Intcode.run_with_inputs([])
    |> elem(1)
    |> Map.fetch!(:program)
    |> Intcode.get_program_address(0)
  end
end
