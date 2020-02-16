defmodule Mob.Cluster.NodeListener do
  use GenServer

  def start_link(init_arg), do: GenServer.start_link(__MODULE__, [name: __MODULE__])

  def init(_) do
    :net_kernel.monitor_nodes(true, node_type: :visible)
    {:ok, nil}
  end

  def handle_info({:nodeup, _node, _node_type}, state) do
    set_members(Mob.Registry)
    #set_members(MyHordeSupervisor)
    {:noreply, state}
  end

  def handle_info({:nodedown, _node, _node_type}, state) do
    set_members(Mob.Registry)
    #set_members(MyHordeSupervisor)
    {:noreply, state}
  end

  defp set_members(name) do
    members = Mob.Cluster.nodes |> Enum.map(fn node -> {name, node} end)
    :ok = Horde.Cluster.set_members(name, members)
  end
end
