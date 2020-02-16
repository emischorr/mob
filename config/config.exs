# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :mob, MobWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hd3+cDrq3Ae0xR2AKt/BSrOU78nSg2dBrK+UHxjoTvlopwoHWyya7b5dZLlnUfvZ",
  render_errors: [view: MobWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Mob.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
     signing_salt: "4e08/ladlnyiJ6fWynonsAxZEAVQU1vK"
   ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :libcluster,
  topologies: [
    gossip_example: [
      strategy: Elixir.Cluster.Strategy.Gossip,
      config: [
        port: 45892,
        if_addr: "0.0.0.0",
        multicast_addr: "255.255.255.255",
        broadcast_only: true]]]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
