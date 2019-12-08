defmodule Advent.Day08 do
  @moduledoc """
  Space Image Format decoder
  """

  def part_1(data, width, height) do
    layer_size = width * height

    layers =
      data
      |> String.graphemes()
      |> Enum.chunk_every(layer_size)

    layer = layers |> Enum.min_by(fn layer -> layer |> Enum.count(&(&1 == "0")) end)

    ones = layer |> Enum.count(&(&1 == "1"))
    twos = layer |> Enum.count(&(&1 == "2"))

    ones * twos
  end

  @doc "Part 2"
  def decode(data, width, height) do
    layer_size = width * height

    result =
      data
      |> String.graphemes()
      |> Enum.chunk_every(layer_size)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(fn pixels -> Enum.find(pixels, &(&1 != "2")) end)
      |> Enum.map(fn
        "0" -> " "
        "1" -> "X"
      end)
      |> Enum.chunk_every(width)
      |> Enum.map(&Enum.join/1)
      |> Enum.join("\n")

    result <> "\n"
  end
end
