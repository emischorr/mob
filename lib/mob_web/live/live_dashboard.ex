defmodule MobWeb.LiveDashboard do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias MobWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <%= for name <- @groups do %>
      <%= live_render(@socket, MobWeb.LiveGroup, id: name, session: %{"group_name" => name}) %>
    <% end %>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)
    {:ok, assign(socket, groups: Mob.group_names)}
  end

  def handle_info(:tick, socket), do: {:noreply, update_groups(socket)}


  defp update_groups(socket), do: assign(socket, groups: Mob.group_names)

end
