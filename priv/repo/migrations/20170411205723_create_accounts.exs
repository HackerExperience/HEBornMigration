defmodule HEBornMigration.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :username, :string, null: false
      add :password, :string, null: false
      add :display_name, :string, null: false
      add :email, :string, null: false
      add :confirmed, :boolean, default: false

      timestamps()
    end

    create unique_index(:accounts, [:username])
    create unique_index(:accounts, [:email])
  end
end
