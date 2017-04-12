defmodule HEBornMigration.Controller.Claim do

  alias HEBornMigration.Controller.Token
  alias HEBornMigration.Model.Claim
  alias HEBornMigration.Repo

  @spec request_migration(String.t) ::
    {:ok, Claim.t}
    | {:error, Ecto.Changeset.t}
  def request_migration(display_name) do
    get_unique_token()
    |> Claim.create(display_name)
    |> Repo.insert()
  end

  @spec fetch(String.t) ::
    Claim.t
    | nil
  def fetch(token),
    do: Repo.get(Claim, token)

  @spec finish_migration(Claim.t | String.t) :: :ok
  def finish_migration(claim = %Claim{}),
    do: finish_migration(claim.token)
  def finish_migration(token) do
    token
    |> Claim.Query.by_token()
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
