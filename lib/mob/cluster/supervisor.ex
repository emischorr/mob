defmodule Mob.Cluster.Supervisor do
  use Horde.DynamicSupervisor

  def init(options) do
    {:ok, Keyword.put(options, :members, get_members())}
  end

  defp get_members() do
    Mob.Cluster.nodes |> Enum.map(fn node -> {__MODULE__, node} end)
  end
end
