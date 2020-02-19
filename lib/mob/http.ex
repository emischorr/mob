defmodule Mob.Http do
  use HTTPoison.Base

  @default_options [
    timeout: 10000, recv_timeout: 10000,
    follow_redirect: true, max_redirect: 5,
    ssl: [{:verify, :verify_none}], "User-Agent": "flash-mob",
    hackney: [pool: :mob_pool, headers: [{"User-Agent", "flash-mob"}]]
  ]

  def request(atom, url, body, headers, options) do
    # TODO: use hackney metrics
    started_at = System.monotonic_time(:microsecond)
    result = super(atom, url, body, headers, @default_options ++ options)
    finished_at = System.monotonic_time(:microsecond)
    resp_time = finished_at - started_at
    {status, response} = result
    {status, response, resp_time}
  end
end
