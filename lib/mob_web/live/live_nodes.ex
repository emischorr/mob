defmodule MobWeb.LiveNodes do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias MobWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <div class="nodes">
      <span><%= Enum.count(@nodes) %> Nodes</span>
      <ul>
      <%= for node <- @nodes do %>
        <li><%= node %></li>
      <% end %>
      </ul>
    </div>
    """
  end

  def mount(%{}, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)
    {:ok, assign(socket, nodes: Mob.Cluster.nodes)}
  end

  def handle_info(:tick, socket), do: {:noreply, update_nodes(socket)}


  defp update_nodes(socket), do: assign(socket, nodes: Mob.Cluster.nodes)

end
