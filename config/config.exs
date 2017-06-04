# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :online_game,
  ecto_repos: [OnlineGame.Repo]

# Configures the endpoint
config :online_game, OnlineGame.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FTl8wPNJSgXwIwm/qGCAwfCNYjkQfYOa9+IQL+/j0SpoenjIwpj0dVfyyTZ8h0+R",
  render_errors: [view: OnlineGame.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: OnlineGame.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
