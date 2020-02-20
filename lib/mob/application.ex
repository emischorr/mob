defmodule Mob.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Retrieve the topologies from the config
    topo = Application.get_env(:libcluster, :topologies)

    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      MobWeb.Endpoint,
      # Starts a worker by calling: Mob.Worker.start_link(arg)
      # {Mob.Worker, arg},
      {Cluster.Supervisor, [topo, [name: Mob.ClusterSupervisor]]},
      {Mob.Cluster.Registry, [keys: :unique, name: Mob.Registry]},
      # {Horde.DynamicSupervisor, [name: HelloWorld.HelloSupervisor, strategy: :one_for_one]},
      {Mob.Cluster.NodeListener, []},
      supervisor(Task.Supervisor, [[name: Mob.TaskSupervisor]]),
      #timeout is the time we keep the connection alive in the pool, max_connections is the number of connections maintained in the pool. Each connection in a pool is monitored and closed connections are removed automatically.
      :hackney_pool.child_spec(:mob_pool, [timeout: 15000, max_connections: 2048])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mob.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MobWeb.Endpoint.config_change(changed, removed)
    :ok
  end

end
