defmodule GamePersistence.PersistenceBehaviour do
  @callback persist_player(PlayerGameState.t) :: :ok | :error

  @callback load_player(user_id :: any) :: {:ok, PlayerGameState.t} | :error

  @callback list_user_ids :: [any]
end
