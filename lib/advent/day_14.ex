defmodule Advent.Day14 do
  @moduledoc """
  Fuel calculator
  """

  @doc """
  Part 1
  Runtime is ~1ms on my machine
  """
  def needed_ore(input) do
    reactions = parse(input)
    needed_ore(reactions, 1)
  end

  @doc """
  Part 2
  Binary search for the right result

  Runtime is ~18ms on my machine
  """
  def max_fuel(input) do
    reactions = parse(input)
    ore_spent_single = needed_ore(reactions, 1)

    # This estimate is a lower bound, since there are some stock left on each run
    # We could also use 1 as lower bound, but this optimizes it.
    estimate = div(1_000_000_000_000, ore_spent_single)

    binary_search(reactions, estimate, nil)
  end

  defp binary_search(_reactions, lower, upper) when lower + 1 == upper, do: lower

  defp binary_search(reactions, lower, upper) do
    candiate =
      case upper do
        nil -> lower * 2
        upper -> div(lower + upper, 2)
      end

    ore_spent = needed_ore(reactions, candiate)

    cond do
      ore_spent == 1_000_000_000_000 -> candiate
      ore_spent < 1_000_000_000_000 -> binary_search(reactions, candiate, upper)
      ore_spent > 1_000_000_000_000 -> binary_search(reactions, lower, candiate)
    end
  end

  defp needed_ore(reactions, fuel) do
    %{
      reactions: reactions,
      stock: %{},
      need: %{"FUEL" => fuel},
      ore_spent: 0
    }
    |> resolve()
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
