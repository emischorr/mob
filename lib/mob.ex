defmodule Mob do

  alias Mob.Group
  alias Mob.Metric

  # Mob.new_group("Status", "http://httpbin.org/status/200%2C%20302%2C%20404%2C%20502")
  def new_group(name, url) do
    Metric.start_link(name)
    Group.start_link(name, url)
  end

  def remove_group(name) do
    Group.size(name, 0)
    Group.stop(name)
    Metric.stop(name)
  end

  def group_names() do
    Horde.Registry.select(Mob.Registry, [{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.filter(&(String.starts_with?(&1, "group_")))
    |> Enum.map(&(String.trim_leading(&1, "group_")))
  end

  def group(name), do: Group.info(name)

  def size_group(name, size), do: Group.size(name, size)

  def metrics(name) do
    Metric.list(name)
    # m.slots |> Enum.map(&( put_in(elem(&1,1), [:requests, :mean_time], elem(&1,1).requests.total_time / elem(&1,1).requests.number) ))
  end

  def reset_metrics(name) do
    Metric.stop(name)
    Metric.start_link(name)
  end

end
