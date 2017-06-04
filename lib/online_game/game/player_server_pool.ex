defmodule Game.PlayerServerPool do
  use ExActor.GenServer, export: __MODULE__

  @moduledoc """
  Manages the PlayerServers that are active.

  At some point in the future, should monitor PlayerServers
  and re-start them from persistence when they go down.
  """


  defstart start_link do
    send(self(), :initialize)
    {:ok, %{}}
    initial_state(%{})
  end

  defhandleinfo :initialize, state: state do
    GamePersistence.Persistence.list_user_ids
    |> Task.async_stream(&start_player/1)
    |> Enum.map(fn {:ok, val} -> val end)
    |> Enum.into(state)
    |> IO.inspect()
    |> new_state()
  end
  defhandleinfo _, do: noreply()

  @doc """
  Will lookup the given player,
  or spin up a new GenServer for that player with a default state.
  """
  defcall lookup_player(user_id), state: state do
    user_id = "#{user_id}"
    if Map.has_key?(state, user_id) do
      reply(state[user_id])
    else
      result_state = add_player(state, user_id)
      set_and_reply(result_state, result_state[user_id])
    end
  end

  defp add_player(state, user_id) do
    # TODO Trapping exits/proper restarting from persistence when PlayerServer crashes.
    {:ok, pid} = Game.PlayerServerSupervisor.start_child(user_id)
    IO.inspect({"Adding", user_id, pid})
    Map.put(state, user_id, pid)
  end

  defp start_player(user_id) do
    {:ok, pid} =  Game.PlayerServerSupervisor.start_child(user_id)
    {user_id, pid}
  end
end
