defmodule Mob.Group do
  use GenServer
  require Logger

  @update_time 1000

  # Client

  def start_link(name, url) do
    GenServer.start_link(__MODULE__, %{name: name, size: 0, url: url, active: true}, name: via_tuple(name))
  end

  defp via_tuple(name) do
    {:via, Horde.Registry, {Mob.Registry, "group_"<>name}}
  end

  def size(name, count) do
    try do
      GenServer.call(via_tuple(name), {:size, count})
    catch
      :exit, _ -> {:error, "No such group"}
    end
  end

  def info(name) do
    try do
      GenServer.call(via_tuple(name), {:info})
    catch
      :exit, _ -> {:error, "No such group"}
    end
  end


  # Server (Callbacks)

  @impl true
  def init(state) do
    Process.send_after(self(), :update, @update_time)
    {:ok, state}
  end

  @impl true
  def handle_call({:size, size}, _from, state) do
    {:reply, {:ok, size}, %{state | size: size}}
  end

  @impl true
  def handle_call({:info}, _from, state) do
    {:reply, {:ok, %{name: state.name, url: state.url, size: state.size}}, state}
  end

  @impl true
  def handle_info(:update, state) do
    Process.send_after(self(), :update, @update_time)
    try do # TODO there must be a better way to handle a lost node
      if (state.size > 0) do
        1..state.size
        |> Enum.map(fn x -> Task.Supervisor.async({Mob.TaskSupervisor, Mob.Cluster.random_node}, Mob.Action, :process, [state.name, state.url]) end)
        #|> Enum.map(fn x -> Task.Supervisor.async({Mob.TaskSupervisor, Mob.random_node}, fn -> process(state.name, state.url) end) end)
        #|> Enum.map(&( Task.await(&1) ))
        #|> IO.inspect
      end
    catch
      :exit, reason -> Logger.warn("Failed to reach node: #{reason}")
    end
    {:noreply, state}
  end

  @impl true
  def handle_info({_ref, {:ok}} = msg, state) do
    # got response
    {:noreply, state}
  end

  @impl true
  def handle_info({_ref, {:error, reason}} = msg, state) do
    # call failed! Should be logged to metric process instead of ending up here.
    IO.puts "Failed call"
    IO.inspect msg
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, :normal}, state) do
    # call closed
    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    IO.inspect msg, label: "Unhandled message"
    {:noreply, state}
  end

end
