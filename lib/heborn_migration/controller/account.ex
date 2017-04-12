defmodule HEBornMigration.Controller.Account do

  alias HEBornMigration.Model.Account
  alias HEBornMigration.Model.Claim
  alias HEBornMigration.Repo

  @spec create(Claim.t, String.t, String.t) ::
    {:ok, Account.t}
    | {:error, Ecto.Changeset.t}
  def create(claim, email, password) do
    claim
    |> Account.create(email, password)
    |> Repo.insert()
  end

  @spec fetch(pos_integer) ::
    Account.t
    | nil
  def fetch(id),
    do: Repo.get(Account, id)

  @spec fetch_by_username(String.t) ::
    Account.t
    | nil
  def fetch_by_username(username),
    do: Repo.get_by(Account, username: String.downcase(username))

  @spec confirm(Account.t) ::
    {:ok, Account.t}
    | {:error, Ecto.Changeset.t}
  def confirm(account) do
    account
    |> Account.confirm()
    |> Repo.update()
  end
end
