defmodule OnlineGame.Web.GameChannel do
  use Phoenix.Channel

  def join("player_state_update", _params, socket) do
    # TODO load from current user information.
    user_id = 1
    pid = Game.PlayerServerPool.lookup_player(user_id)
    Phoenix.PubSub.subscribe(OnlineGame.PubSub, "player_state_update:#{user_id}")
    {:ok, assign(socket, :player_server, pid)}
  end

  def handle_in("player_buy_miner", _, socket) do
    player_server = socket.assigns[:player_server]
    Game.PlayerServer.buy_miner(player_server)
    {:noreply, socket}
  end

  def handle_in("player_sell_resource", %{"resource" => resource_key_str}, socket) do
    player_server = socket.assigns[:player_server]
    resource_key = String.to_existing_atom(resource_key_str)

    Game.PlayerServer.sell_resource(player_server, resource_key)
    {:noreply, socket}
  end

  def handle_info({:player_state_update, player_state}, socket) do
    push socket, "player_state_update", player_state
    {:noreply, socket}
  end
end
