defmodule HEBornMigration.Model.HEBorningUser do

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
    display_name: String.t,
    token: String.t
  }

  @primary_key false
  schema "heborning_users" do
    field :token, :string,
      primary_key: true

    field :display_name, :string, size: 15
  end

  @spec create(String.t, String.t) :: Ecto.Changeset.t
  def create(token, display_name) do
    changeset(%__MODULE__{}, %{token: token, display_name: display_name})
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:token, :display_name])
    |> validate_required([:token, :display_name])
    |> validate_length(:display_name, max: 15)
    |> unique_constraint(:display_name)
  end

  defmodule Query do

    alias HEBornMigration.Model.HEBorningUser

    import Ecto.Query, only: [where: 3]

    @spec by_token(Ecto.Queryable.t, String.t) :: Ecto.Queryable.t
    def by_token(query \\ HEBorningUser, token),
      do: where(query, [ma], ma.token == ^token)
  end
end
