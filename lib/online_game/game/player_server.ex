defmodule Game.PlayerServer do
  use ExActor.GenServer
  alias Game.PlayerGameState

  @moduledoc """
  Manages the Player State in a separate thread of execution.

  Sends itself a tick every two seconds to update the state.
  The Game State is only written to persistence whenever something
  noteworthy happens (i.e. the user made a game decision).
  """

  @tick_interval_ms 1_000

  defstart start(user_id)
  defstart start_link(user_id)

  # Start sending ticks.
  def init({user_id}) do
    initial_state =
      case GamePersistence.Persistence.load_player(user_id) do
        {:ok, player_game_state} -> player_game_state
        :error ->
          state = PlayerGameState.new(user_id)
          Task.start(fn -> GamePersistence.Persistence.persist_player(state) end)
          state
      end
    # IO.inspect(initial_state)
    # IO.inspect(self())
    # send_next_tick()
    :erlang.send_after(1, self(), :first_tick!)
    {:ok, initial_state}
  end

  defcall get, state: state, do: reply(state)

  defcall sell_resource(resource_key), state: state do
    case PlayerGameState.sell_resource(state, resource_key) do
      {:ok, result_state} -> handle_important_change(result_state)
      :error -> reply(:error)
    end
  end

  defcall buy_miner, state: state do
    case PlayerGameState.buy_miner(state) do
      {:ok, result_state} -> handle_important_change(result_state)
      :error -> reply(:error)
    end
  end

  defhandleinfo :tick!, state: state do
    # IO.inspect(state)
    updated_state = tick_until_updated(state)
    send_next_tick()
    broadcast_update(updated_state)
    new_state(updated_state)
  end

  defhandleinfo :first_tick!, state: state do
    updated_state = tick_until_updated(state)
    GamePersistence.Persistence.persist_player(updated_state)
    # IO.puts "First tick completed for #{inspect(state.user_id)}"
    send_next_tick()
    broadcast_update(updated_state)
    new_state(updated_state)
  end

  defhandleinfo _, do: noreply()

  defp send_next_tick() do
    :erlang.send_after(@tick_interval_ms, self(), :tick!)
  end

  # Repeats the `tick` procedure until we are past the current time.
  defp tick_until_updated(state) do
    now = Timex.now()
    if Timex.compare(state.last_player_tick_datetime, now) < 0 do
      PlayerGameState.tick(state)
      |> tick_until_updated()
    else
      state
    end
  end

  # Broadcasts important change,
  # Replies with :ok
  # And also starts task to persist the state!
  defp handle_important_change(state) do
    broadcast_update(state)
    Task.start(fn -> GamePersistence.Persistence.persist_player(state) end)
    set_and_reply(state, :ok)
  end

  defp broadcast_update(state) do
    Phoenix.PubSub.broadcast(OnlineGame.PubSub, "player_state_update:#{state.user_id}", {:player_state_update, state})
  end
end
