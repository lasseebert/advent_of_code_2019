defmodule Advent.Day25Test do
  use ExUnit.Case, async: true

  alias Advent.Day25

  describe "part 1" do
    # Infinity timeout in case it is run in interactive mode
    @tag timeout: :infinity
    @tag :puzzle_input
    test "puzzle input" do
      raw_program = File.read!("input_files/day_25.int")
      assert Day25.find_password(raw_program) == "25166400"
    end
  end
end
