defmodule HEBornMigration.Controller.HEBorningUser do

  alias HEBornMigration.Controller.Token
  alias HEBornMigration.Model.HEBorningUser
  alias HEBornMigration.Repo

  @spec request_migration(String.t) ::
    {:ok, HEBorningUser.t}
    | {:error, Ecto.Changeset.t}
  def request_migration(display_name) do
    get_unique_token()
    |> HEBorningUser.create(display_name)
    |> Repo.insert()
  end

  @spec fetch(String.t) ::
    HEBorningUser.t
    | nil
  def fetch(token),
    do: Repo.get(HEBorningUser, token)

  @spec finish_migration(HEBorningUser.t | String.t) :: :ok
  def finish_migration(heborning_user = %HEBorningUser{}),
    do: finish_migration(heborning_user.token)
  def finish_migration(token) do
    token
    |> HEBorningUser.Query.by_token()
    |> Repo.delete_all()

    :ok
  end

  defp get_unique_token do
    # REVIEW: maybe add a cache server to make this check faster
    token = Token.generate()

    if fetch(token),
      do: get_unique_token(),
      else: token
  end
end
