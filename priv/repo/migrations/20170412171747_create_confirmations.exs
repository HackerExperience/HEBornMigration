defmodule HEBornMigration.Repo.Migrations.CreateConfirmations do
  use Ecto.Migration

  def change do
    create table(:confirmations, primary_key: false) do
      add :code, :string, primary_key: true
      add :id, references(:accounts, on_delete: :delete_all), null: false
    end

    create unique_index(:confirmations, [:id])
  end
end
