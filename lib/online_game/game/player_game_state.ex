defmodule Game.PlayerGameState do
  @moduledoc """
  Manages the game state of a single Player's account.

  This is a Plain Old Data finite-state machine,
  and therefore easily testable/extendable.
  """

  defstruct [
    :user_id,
    resources: Game.Resources.new(),
    money: 10_000_000,
    miners: 1,
    last_player_tick_datetime: Timex.now()
    ]

  def new(user_id) do
    %__MODULE__{user_id: user_id}
  end

  def sell_resource(state, resource_key) do
    case Game.Resources.sell_all_of_resource(state.resources, resource_key) do
      {:ok, result_resources, result_money} ->
        result_state =
          state
          |> Map.put(:resources, result_resources)
          |> Map.put(:money, state.money + result_money)
        {:ok, result_state}
      _ ->
        :error
    end
  end

  def buy_miner(state) do
    n_miners = state.miners
    with {:ok, price} <- next_miner_price(n_miners),
         {:ok, state} <- subtract_balance(state, price) do
      new_state = put_in(state.miners, n_miners + 1)
      {:ok, new_state}
    end
  end


  def next_miner_price(1), do: {:ok, 2}
  def next_miner_price(2), do: {:ok, 8}
  def next_miner_price(3), do: {:ok, 18}
  def next_miner_price(n) when n < @max_miner_level, do: {:ok, n * n * 2}
  def next_miner_price(_), do: :error

  defp subtract_balance(state = %__MODULE__{money: money}, amount) when money - amount < 0, do: :error
  defp subtract_balance(state = %__MODULE__{money: money}, amount), do: {:ok, put_in(state.money, money - amount)}

  def tick(state = %__MODULE__{money: money, miners: miners, resources: resources, last_player_tick_datetime: tick_datetime}) do
    tick_datetime = Timex.add(tick_datetime, Timex.Duration.from_seconds(1))
    updated_resources = Game.Resources.mine_resources(resources, miners)
    %__MODULE__{state | last_player_tick_datetime: tick_datetime, resources: updated_resources}
  end
end
