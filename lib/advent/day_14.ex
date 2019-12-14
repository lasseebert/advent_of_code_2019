defmodule Advent.Day14 do
  @moduledoc """
  Fuel calculator
  """

  @doc """
  Part 1
  Runtime is ~2ms on my machine
  """
  def needed_ore(input) do
    reactions = parse(input)

    state = %{
      reactions: reactions,
      stock: %{},
      need: %{"FUEL" => 1},
      ore_spent: 0
    }

    resolve(state)
  end

  @doc """
  Part 2
  Binary search for the right result

  Runtime is ~31ms on my machine
  """
  def max_fuel(input) do
    reactions = parse(input)
    lower = 1
    upper = 1_000_000_000_000

    binary_search(reactions, lower, upper)
  end

  defp binary_search(_reactions, lower, upper) when lower + 1 == upper, do: lower

  defp binary_search(reactions, lower, upper) do
    middle = div(lower + upper, 2)

    ore_spent =
      %{
        reactions: reactions,
        stock: %{},
        need: %{"FUEL" => middle},
        ore_spent: 0
      }
      |> resolve()

    cond do
      ore_spent == 1_000_000_000_000 -> middle
      ore_spent < 1_000_000_000_000 -> binary_search(reactions, middle, upper)
      ore_spent > 1_000_000_000_000 -> binary_search(reactions, lower, middle)
    end
  end

  defp resolve(%{need: empty} = state) when empty == %{}, do: state.ore_spent

  defp resolve(state) do
    material = state.need |> Map.keys() |> hd()
    {need_amount, need} = state.need |> Map.pop(material)
    state = %{state | need: need}

    in_stock = state.stock |> Map.get(material, 0)
    from_stock = min(need_amount, in_stock)
    need_amount = need_amount - from_stock
    state = %{state | stock: state.stock |> Map.update(material, 0, &(&1 - from_stock))}

    if need_amount > 0 do
      {react_amount, ingredients} = state.reactions |> Map.fetch!(material)
      multiplier = div(need_amount - 1, react_amount) + 1

      stock_amount = react_amount * multiplier - need_amount
      true = stock_amount >= 0
      state = %{state | stock: state.stock |> Map.update(material, stock_amount, &(&1 + stock_amount))}

      ingredients
      |> Enum.reduce(state, fn
        {"ORE", count}, state ->
          %{state | ore_spent: state.ore_spent + count * multiplier}

        {mat, count}, state ->
          total_count = count * multiplier
          need = state.need |> Map.update(mat, total_count, &(&1 + total_count))
          %{state | need: need}
      end)
    else
      state
    end
    |> resolve()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.into(%{}, fn line ->
      [ingredients, result] = String.split(line, " => ")

      ingredients =
        String.split(ingredients, ", ")
        |> Enum.into(%{}, fn ingredient ->
          [amount, material] = String.split(ingredient, " ")
          {material, String.to_integer(amount)}
        end)

      [amount, material] = String.split(result, " ")

      {material, {String.to_integer(amount), ingredients}}
    end)
  end
end
