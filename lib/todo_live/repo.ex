defmodule TodoLive.Repo do
  use Ecto.Repo,
    otp_app: :todo_live,
    adapter: Ecto.Adapters.Postgres
end
