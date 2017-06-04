defmodule Game.Resource do
  @moduledoc """
  A single resource in the game.

  Note that 'miners' and 'money' are also resources :D.
  Resource-specific logic is managed in the Resource-specific modules;
  They implement the 'Resource' behaviour.
  """

  @callback name() :: String.t
  @callback selling_price_per_piece :: integer | nil
  @callback buying_price_per_piece :: integer | nil
  @callback mining_speed(integer) :: number
end

defmodule Game.Resource.Stone do
  @behaviour Game.Resource

  def name do
    "Stone"
  end

  def selling_price_per_piece, do: 10

  def buying_price_per_piece, do: :error
  def mining_speed(n), do: n
end


defmodule Game.Resource.Copper do
  @behaviour Game.Resource

  def name do
    "Copper"
  end

  def selling_price_per_piece, do: 50

  def buying_price_per_piece, do: :error

  def mining_speed(n), do: n * 0.1
end

defmodule Game.Resource.Tin do
  @behaviour Game.Resource

  def name do
    "Copper"
  end

  def selling_price_per_piece, do: 100

  def buying_price_per_piece, do: :error

  def mining_speed(n), do: n * 0.04
end
