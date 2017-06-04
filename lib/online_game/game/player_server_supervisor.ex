defmodule Game.PlayerServerSupervisor do
  # Automatically imports Supervisor.Spec
  use Supervisor


  @name __MODULE__

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_child(user_id) do
    Supervisor.start_child(__MODULE__, [user_id])
  end

  def init(:ok) do
    IO.inspect("STARTING SUPERVISOR! :D")
    children = [
      worker(Game.PlayerServer, [], restart: :transient)
    ]

    # supervise/2 is imported from Supervisor.Spec
    supervise(children, strategy: :simple_one_for_one)
  end
end
