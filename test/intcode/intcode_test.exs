defmodule Advent.IntcodeTest do
  use Advent.Test.Case

  alias Advent.Intcode

  test "day 05 example 1" do
    program = "3,9,8,9,10,9,4,9,99,-1,8" |> Intcode.parse_program()

    assert {[0], _state} = Intcode.run_with_inputs(program, [5])
    assert {[1], _state} = Intcode.run_with_inputs(program, [8])
  end
end
