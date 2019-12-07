defmodule Advent.Intcode.RuntimeState do
  @moduledoc """
  The runtime state of an Intcode program
  """

  alias Advent.Intcode

  @type t :: %__MODULE__{
          program: Intcode.program(),
          pointer: Intcode.address(),
          input: Intcode.input(),
          output: Intcode.output(),
          exited: boolean
        }

  defstruct [
    :program,
    :pointer,
    :input,
    :output,
    :exited
  ]

  @doc """
  Builds a new runtime state from a program and the input
  """
  @spec new(Intcode.program(), Intcode.input()) :: t
  def new(program, input) do
    %__MODULE__{
      program: program,
      pointer: 0,
      input: input,
      output: 0,
      exited: false
    }
  end
end
