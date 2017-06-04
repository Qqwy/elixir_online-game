defmodule GamePersistence.Persistence do
  def persist_player(player_struct) do
    persistence_impl().persist_player(player_struct)
  end

  def load_player(player_key) do
    persistence_impl().load_player(player_key)
  end

  def list_user_ids() do
    persistence_impl().list_user_ids()
  end

  def persistence_impl do
    Application.get_env(OnlineGame, :game_persistence_implementation, GamePersistence.Implementations.FileSystem)
  end
end
