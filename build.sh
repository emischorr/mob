# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
npm run deploy --prefix ./assets
mix phx.digest

# build release
MIX_ENV=prod mix release
