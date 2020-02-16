defmodule MobWeb.LiveGroup do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias MobWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <section class="group row">

      <div class="header">
        <div class="info">
          <h3><%= @name %></h3>
          <div class="url"><i class="fas fa-fw fa-link"></i><a href="<%= @url %>"><%= @url %></a></div>
        </div>
        <div class="actions"><i class="fas fa-trash"></i></div>
        <div class="control">
          <i class="fas fa-fw fa-users"></i><%= @size %>
          <output phx-update="ignore" for="<%= html_id(@name) %>-size">
            <span class="size-preview" style="display:none;">
              <i class="fas fa-fw fa-chart-line"></i><span class="range_value"></span>
            </span>
          </output>
          <input phx-click="size" type="range" min="0" max="100" value="<%= @size %>" class="slider" id="<%= html_id(@name) %>-size" name="<%= html_id(@name) %>-size">
          <div class="metrics">
            <i class="fas fa-fw fa-arrows-alt-h"></i><%= @requests %>
            <div class="responses">
              <i class="fas fa-fw fa-boxes"></i><span class="ok"><%= @responses.ok %></span> / <span class="warn"><%= @responses.warn %></span> / <span class="error"><%= @responses.error %></span>
            </div>
            <%= if Enum.count(@errors) > 0 do %>
            <i class="fas fa-fw fa-exclamation-triangle errors">
              <div class="error-details">
              <%= for error <- @errors do %>
                <%= elem(error,0) %>: <%= elem(error, 1) %>
              <% end %>
              </div>
            </i>
            <% end %>
          </div>

        </div>
      </div>
      <div class="detail">
        <div phx-hook="Chart" id="<%= @name %>_chart" data-chart-data='{
          "labels": [<%= @labels %>],
          "series": <%= @series %>
        }' class="chart"></div>
      </div>
    </section>
    """
  end

  def mount(%{"group_name" => name}, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    {:ok, assign(socket, name: name, url: "", size: 0, requests: 0, responses: %{ok: 0, warn: 0, error: 0}, errors: %{}, labels: "", series: "[]")}
  end

  def handle_info(:tick, socket) do
    #IO.inspect socket.assigns
    {:noreply, socket
    |> update_group(socket.assigns.name)
    |> update_metrics(socket.assigns.name)
    }
  end

  def handle_event("size", %{"value" => size}, socket) do
    Mob.size_group(socket.assigns.name, String.to_integer(size))
    {:noreply, socket}
  end


  defp html_id(name) do
    name |> String.replace(" ", "-") |> String.downcase
  end

  defp update_group(socket, name) do
    case Mob.group(name) do
      {:ok, info} ->
        assign(socket, name: info.name, url: info.url, size: info.size)
      {:error, reason} ->
        #{:error, reason}
        assign(socket, name: name, url: "", size: 0)
    end
  end

  defp update_metrics(socket, name) do
    case Mob.metrics(name) do
      %{calls: calls, responses: responses, errors: errors, slots: slots} ->
        response = responses |> Enum.map(&("#{elem(&1,0)}: #{elem(&1,1)}")) |> Enum.join(", ")
        socket
        |> assign(requests: calls)
        |> assign(responses: transform_responses(responses))
        |> assign(errors: errors)
        |> assign(labels: transform_slots_to_labels(slots))
        |> assign(series: transform_slots_to_series(slots))
      x ->
        #{:error, reason}
        assign(socket, metrics: "")
    end
  end

  defp transform_responses(responses) do
    response_map = Enum.group_by(responses, &group_status/1, &group_value/1)
    |> reduce_status()
    Map.merge(%{ok: 0, warn: 0, error: 0}, response_map)
  end

  defp group_status({status_code, count}) do
    case div(status_code, 100) do
      2 -> :ok
      3 -> :warn
      4 -> :warn
      5 -> :error
      _ -> :undefined
    end
  end

  defp group_value({status_code, count}), do: count

  defp reduce_status(map) do
    Enum.map(map, &( {elem(&1,0), Enum.reduce(elem(&1, 1), 0, fn x, acc -> x + acc end)} )) |> Enum.into(%{})
  end

  defp transform_slots_to_labels(slots) do
    slots |> Map.keys() |> Enum.map( &DateTime.from_unix!/1 ) |> Enum.map( &("\"#{Time.to_string(&1)}\"") ) |> Enum.join(", ")
  end

  defp transform_slots_to_series(slots) do
    mean_time = slots |> Map.values() |> Enum.map(&( Float.round(trunc(&1.requests.mean_time)/1000) )) |> Enum.join(", ")
    "[[#{mean_time}]]"
  end

end
