defmodule Game.Resources do
  alias Game.Resource
  defstruct [
    {Resource.Stone, 0},
    {Resource.Copper, 0},
    {Resource.Tin, 0}
  ]

  def new do
    %__MODULE__{}
  end

  @resources [:stone, :copper, :tin]
  def resources do
    @resources
  end

  def resource_keys do
    resources
    |> Enum.map(&get_resource_key/1)
  end

  for resource_name <- @resources do
    def get(resources_struct = %__MODULE__{}, unquote(resource_name)) do
      key = get_resource_key(unquote(resource_name))
      Map.get(resources_struct, key)
    end
  end

  defp get_resource_key(resource_name) do
    Module.concat(Resource, "#{resource_name}" |> String.capitalize)
  end

  def mine_resources(resources_struct, n_miners) do
    updated_resources =
      resources_struct
      |> Map.from_struct
      |> Enum.map(&mine_resource(&1, n_miners))
      |> Enum.into(%{})
    struct(__MODULE__, updated_resources)
  end

  defp mine_resource({resource_module, current_amount}, n_miners) do
    mined_amount = resource_module.mining_speed(n_miners)
    {resource_module, current_amount + mined_amount}
  end

  def sell_all_of_resource(resources_struct, resource_type) do
    resource_amount = Map.get(resources_struct, resource_type)
    result_money = resource_type.selling_price_per_piece * resource_amount
    result_resources_struct = Map.put(resources_struct, resource_type, 0)

    {:ok, result_resources_struct, result_money}
  end
end
