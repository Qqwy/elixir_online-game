defmodule GamePersistence.Implementations.FileSystem do
  @behaviour GamePersistence.PersistenceBehaviour

  def persist_player(player_struct) do
    player_struct
    |> :erlang.term_to_binary
    |> (&File.write!(filepath(player_struct.user_id), &1)).()

    :ok
  end

  def load_player(user_id) do
    case File.read(filepath(user_id)) do
      {:ok, data} ->
        user_state = :erlang.binary_to_term(data)
        # Map.put(user_state, :last_player_tick_datetime, Timex.now())
        {:ok, user_state}
      _ ->
        :error
    end
  end

  def list_user_ids do
    Path.wildcard("./persistence/*")
    |> Enum.map(&extract_user_id_from_filepath/1)
  end

  defp extract_user_id_from_filepath(filepath) do
    "player_game_state-" <> user_id =
      filepath
      |> Path.basename(".bin")

    user_id
  end

  defp filepath(user_id) do
    Path.join("./persistence/", "player_game_state-#{user_id}.bin")
    |> Path.expand
  end
end
