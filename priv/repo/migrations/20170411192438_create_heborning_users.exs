defmodule HEBornMigration.Repo.Migrations.CreateHEBorningUsers do
  use Ecto.Migration

  def change do
    create table(:heborning_users, primary_key: false) do
      add :token, :string, primary_key: true
      add :display_name, :string, null: false
    end

    create unique_index(:heborning_users, [:display_name])
  end
end
