defmodule HEBornMigration.Controller.Account do

  alias HEBornMigration.Model.Account
  alias HEBornMigration.Model.Claim
  alias HEBornMigration.Repo

  @spec claim(display_name :: String.t) ::
    {:ok, token :: String.t}
    | {:error, Ecto.Changeset.t}
  def claim(display_name) do
    result =
      display_name
      |> Claim.create()
      |> Repo.insert()

    case result do
      {:ok, claim = %Claim{}} ->
        {:ok, claim.token}
      {:error, reason = %Ecto.Changeset{}} ->
        {:error, reason}
    end
  end

  @spec migrate(Claim.token, email :: String.t, password :: String.t) ::
    {:ok, Account.t}
    | {:error, Ecto.Changeset.t}
  def migrate(token, email, password) do
    Repo.transaction fn ->
      result =
        Claim
        |> Repo.get(token)
        |> Account.create(email, password)
        |> Repo.insert()

      case result do
        {:ok, account = %Account{}} ->
          # TODO: send email here
          account
        {:error, reason = %Ecto.Changeset{}} ->
          Repo.rollback(reason)
      end
    end
  end
end
