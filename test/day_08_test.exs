defmodule Advent.Day08Test do
  use Advent.Test.Case

  alias Advent.Day08

  describe "part 1" do
    test "example 1" do
      file = "123456789012"
      assert Day08.part_1(file, 3, 2) == 1
    end

    @tag :puzzle_input
    test "puzzle input" do
      file = File.read!("input_files/day_08.sif") |> String.trim()
      assert Day08.part_1(file, 25, 6) == 2684
    end
  end

  describe "part 2" do
    @tag :puzzle_input
    test "puzzle input" do
      file = File.read!("input_files/day_08.sif") |> String.trim()

      assert Day08.decode(file, 25, 6) == """
             X   X XX  XXX  X   XXXXX 
             X   XX  X X  X X   X   X 
              X X X    X  X  X X   X  
               X  X XX XXX    X   X   
               X  X  X X X    X  X    
               X   XXX X  X   X  XXXX 
             """
    end
  end
end
