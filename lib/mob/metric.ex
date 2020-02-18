defmodule Mob.Metric do
  use GenServer

  @init_state %{calls: 0, responses: %{}, errors: %{}, slots: %{}, current_slot: 0, live: true, active: true}
  @slot_length 2*1000 # 2 seconds
  @number_live_slots 30

  # Client

  def start_link(name) do
    GenServer.start_link(__MODULE__, @init_state, name: via_tuple(name))
  end

  defp via_tuple(group) do
    {:via, Horde.Registry, {Mob.Registry, "metric_"<>group}}
  end

  def update(group, update_data) do
    try do
      GenServer.cast(via_tuple(group), {:update, update_data})
    catch
      :exit, _ -> {:error, "No such group"}
    end
  end

  def list(group) do
    try do
      GenServer.call(via_tuple(group), {:list})
    catch
      :exit, _ -> {:error, "No such group"}
    end
  end

  def stop(group) do
    GenServer.stop(via_tuple(group))
  end


  # Server (Callbacks)

  @impl true
  def init(state) do
    Process.send_after(self(), :switch_slot, @slot_length)
    {:ok, new_slot(state)}
  end

  @impl true
  def handle_info(:switch_slot, state) do
    Process.send_after(self(), :switch_slot, @slot_length)
    {:noreply, state |> new_slot |> clean_up_slot}
  end

  @impl true
  def handle_cast({:update, update_data}, state) do
    new_state = case update_data do
      {:call} -> %{state | calls: state.calls+1}
      {:response, status_code, resp_time} ->
        state
        |> update_responses(status_code)
        |> update_slot(status_code, resp_time)
      {:error, reason} -> update_errors(state, reason)
      _ -> state
    end
    {:noreply, new_state}
  end

  @impl true
  def handle_call({:list}, _from, state) do
    {:reply, state, state}
  end


  defp update_errors(state, reason) do
    count = case state[:errors][reason] do
      nil -> 1
      x -> x+1
    end
    put_in(state[:errors][reason], count)
  end

  defp update_responses(state, status_code) do
    count = case state[:responses][status_code] do
      nil -> 1
      x -> x+1
    end
    put_in(state[:responses][status_code], count)
  end

  defp new_slot(state) do
    new_slot = DateTime.to_unix(DateTime.utc_now)

    state
    |> put_in([:slots, new_slot], %{requests: %{number: 0, total_time: 0, mean_time: 0}, responses: %{}})
    |> put_in([:current_slot], new_slot)
  end

  defp clean_up_slot(state) do
    if state.live do
      if length(Map.keys(state.slots)) > @number_live_slots do
        old_slot = state.slots |> Map.keys |> List.first
        pop_in(state, [:slots, old_slot]) |> elem(1)
      else
        state
      end
    else
      state
    end
  end

  defp update_slot(state, status_code, resp_time) do
    # TODO: save incoming status_code for current time slot
    response_count = case state[:slots][state.current_slot][:responses][status_code] do
      nil -> 1
      x -> x+1
    end
    # TODO: do not use current timestamp to associate a slot! instead rely on supplied timestamp from client process
    state
    |> update_in([:slots, state.current_slot, :requests, :number], &(&1+1))
    |> update_in([:slots, state.current_slot, :requests, :total_time], &(&1+resp_time))
    |> update_in([:slots, state.current_slot, :requests], &calculate_times/1)
    |> update_in([:slots, state.current_slot, :responses], &(calculate_responses(&1 ,status_code)))
    #state
  end

  defp calculate_times(requests) do
    mean_time = case requests do
      %{number: 0} -> 0
      %{total_time: time, number: count} -> time/count
    end
    put_in(requests, [:mean_time], mean_time)
  end

  defp calculate_responses(responses, status_code) do
    response_count = case responses[status_code] do
      nil -> 1
      x -> x+1
    end
    put_in(responses, [status_code], response_count)
  end

end
