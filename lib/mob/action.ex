defmodule Mob.Action do

  def process(group, url) when is_binary(url) do
    #IO.puts "processing on node #{Node.self()}"
    Mob.Metric.update(group, {:call})
    case Mob.Http.get(url) do
      {:ok, %HTTPoison.Response{status_code: status_code}, resp_time} ->
        Mob.Metric.update(group, {:response, status_code, resp_time})
        {:ok}
      {:error, %HTTPoison.Error{reason: reason}, resp_time} ->
        Mob.Metric.update(group, {:error, reason})
        {:ok}
    end
  end

  def process(group, action) when is_list(action) do
    # TODO: process action (list of multiple urls)
    {:ok}
  end

end
