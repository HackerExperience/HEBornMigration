defmodule HEBornMigration.Controller.Account do

  alias HEBornMigration.Model.Account
  alias HEBornMigration.Model.Claim
  alias HEBornMigration.Model.Confirmation
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
      {:ok, claim} ->
        {:ok, claim.token}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec migrate(Claim.token, email :: String.t, password :: String.t) ::
    {:ok, Account.t}
    | {:error, Ecto.Changeset.t}
  def migrate(token, email, password) do
    Repo.transaction fn ->
      claim = Repo.get(Claim, token)

      result =
        claim
        |> Account.create(email, password)
        |> Repo.insert()

      with {:ok, account} <- result do
        Repo.delete(claim)
        account
      else
        {:error, reason} ->
          Repo.rollback(reason)
      end
    end
  end

  @spec confirm(Confirmation.code) ::
    :ok
    | :error
  def confirm(code) do
    {status, _} =
      Repo.transaction(fn ->
        with \
          confirmation = %Confirmation{} <- Repo.get(Confirmation, code),

          changeset =
            confirmation
            |> Repo.preload(:account)
            |> Confirmation.confirm(),

          {:ok, confirmation} <- Repo.update(changeset),
          {:ok, confirmation} <- Repo.delete(confirmation)
        do
          confirmation.account
        else
          {:error, reason} ->
            Repo.rollback(reason)
          nil ->
            Repo.rollback(:notfound)
        end
      end)

    status
  end
end
