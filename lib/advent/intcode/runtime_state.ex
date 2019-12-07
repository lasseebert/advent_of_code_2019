defmodule Advent.Intcode.RuntimeState do
  @moduledoc """
  The runtime state of an Intcode program
  """

  alias Advent.Intcode

  @type t :: %__MODULE__{
          program: Intcode.program(),
          pointer: Intcode.address(),
          exited: boolean,
          caller: pid,
          tag: Intcode.tag()
        }

  defstruct [
    :program,
    :pointer,
    :exited,
    :caller,
    :tag
  ]

  @doc """
  Builds a new runtime state from a program and the input
  """
  @spec new(Intcode.program(), pid, Intcode.tag()) :: t
  def new(program, caller, tag) do
    %__MODULE__{
      program: program,
      pointer: 0,
      exited: false,
      caller: caller,
      tag: tag
    }
  end
end
