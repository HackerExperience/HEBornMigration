defmodule HEBornMigration.Exporter.Client do

  alias HEBornMigration.Web.Account

  require Logger

  def export_to_helix(account = %Account{confirmed: true}) do
    config = Application.get_env(:heborn_migration, :exporter)
    token = config[:token]
    headers = [
      "Authorization": "Bearer " <> token,
      "Content-Type": "application/json;charset=UTF-8"
    ]

    body = Poison.encode!(%{
      username: account.display_name,
      password: account.password,
      email: account.email
    })

    {:ok, _} = HTTPoison.post(config[:url], body, headers)

    Logger.info("Successfully exported user \"#{account.username}\"")
  end
end
