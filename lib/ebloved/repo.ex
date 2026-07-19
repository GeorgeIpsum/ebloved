defmodule Ebloved.Repo do
  use Ecto.Repo,
    otp_app: :ebloved,
    adapter: Ecto.Adapters.Postgres
end
