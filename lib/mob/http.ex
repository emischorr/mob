defmodule Mob.Http do
  use HTTPoison.Base

  def request(atom, url, body, headers, options) do
    # TODO: use hackney metrics
    started_at = System.monotonic_time(:microsecond)
    result = super(atom, url, body, headers, options ++ [{"User-Agent", "flash-mob"}])
    finished_at = System.monotonic_time(:microsecond)
    resp_time = finished_at - started_at
    {status, response} = result
    {status, response, resp_time}
  end
end
