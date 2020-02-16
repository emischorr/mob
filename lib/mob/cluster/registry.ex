defmodule Mob.Cluster.Registry do
  use Horde.Registry

  def start_link(init_arg, options \\ []) do
    Horde.Registry.start_link(init_arg)
  end

  def init(init_arg) do
    #{:ok, Keyword.put(init_arg, :members, members())}
    [members: members()]
    |> Keyword.merge(init_arg)
    |> Horde.Registry.init()
  end

  defp members() do
    Mob.Cluster.nodes |> Enum.map(fn node -> {__MODULE__, node} end)
  end
end
