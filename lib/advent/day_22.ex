defmodule Advent.Day22 do
  @moduledoc """
  Card shuffle
  """

  @doc """
  Part 1
  """
  def shuffle(input, deck_size, card) do
    shuffle_fun = parse(input, deck_size)
    shuffle_fun.(card)
  end

  @doc """
  Part 2
  """
  def shuffle_mult(input, deck_size, end_index, _times) do
    shuffle_fun = parse(input, deck_size)

    1..1_000_000
    |> Enum.reduce({MapSet.new(), end_index}, fn _, {seen, card} ->
      new_card = shuffle_fun.(card)
      # IO.inspect(Enum.count(seen))
      # IO.inspect(new_card)

      if MapSet.member?(seen, new_card) do
        raise "yeah!"
      end

      {MapSet.put(seen, new_card), new_card}
    end)
  end

  defp deal_into_new_stack(card, size), do: size - 1 - card

  defp cut(card, size, at) when at < 0, do: cut(card, size, at + size)
  defp cut(card, size, at), do: rem(card + size - at, size)

  defp deal_with_increment(card, size, inc), do: rem(card * inc, size)

  defp parse(input, deck_size) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line(&1, deck_size))
    |> Enum.reduce(fn fun, acc -> fn card -> card |> acc.() |> fun.() end end)
  end

  defp parse_line("deal into new stack", size), do: &deal_into_new_stack(&1, size)
  defp parse_line("cut " <> arg, size), do: &cut(&1, size, String.to_integer(arg))
  defp parse_line("deal with increment " <> arg, size), do: &deal_with_increment(&1, size, String.to_integer(arg))
end
