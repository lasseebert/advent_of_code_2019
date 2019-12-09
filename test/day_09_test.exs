defmodule Advent.Day09Test do
  use Advent.Test.Case

  alias Advent.Intcode

  setup do
    start_supervised!(Intcode.Supervisor)
    :ok
  end

  describe "part 1" do
    test "example 1" do
      program = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99" |> Intcode.parse_program()
      {outputs, _state} = Intcode.run_with_inputs(program, [])
      assert outputs == [109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99]
    end

    test "example 2" do
      program = "1102,34915192,34915192,7,4,7,99,0" |> Intcode.parse_program()
      assert {[1_219_070_632_396_864], _state} = Intcode.run_with_inputs(program, [])
    end

    test "example 3" do
      program = "104,1125899906842624,99" |> Intcode.parse_program()
      assert {[1_125_899_906_842_624], _state} = Intcode.run_with_inputs(program, [])
    end

    @tag :puzzle_input
    test "puzzle input" do
      program = File.read!("input_files/day_09.int") |> Intcode.parse_program()
      assert {[2_406_950_601], _state} = Intcode.run_with_inputs(program, [1])
    end
  end

  describe "part 2" do
    @tag :puzzle_input
    test "puzzle input" do
      program = File.read!("input_files/day_09.int") |> Intcode.parse_program()
      assert {[83_239], _state} = Intcode.run_with_inputs(program, [2])
    end
  end
end
