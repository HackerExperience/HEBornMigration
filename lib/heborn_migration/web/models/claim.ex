defmodule HEBornMigration.Web.Claim do

  use Ecto.Schema

  alias HEBornMigration.Web.Account

  import Ecto.Changeset

  @type token :: String.t

  @type t :: %__MODULE__{
    token: String.t,
    display_name: String.t
  }

  @primary_key false
  @ecto_autogenerate {:token, {UUID, :uuid4, []}}
  schema "claims" do
    field :token, :string,
      primary_key: true

    field :display_name, :string, size: 15
  end

  @spec create(Account.display_name) ::
    Ecto.Changeset.t
  def create(display_name),
    do: changeset(%{display_name: display_name})

  @spec unclaimable_changeset(Account.display_name) ::
    Ecto.Changeset.t
  @doc """
  Returns a changeset with `display_name` error, used when trying to migrate an
  already migrated account.
  """
  def unclaimable_changeset(display_name) do
    changeset =
      display_name
      |> create()
      |> add_error(:display_name, "has been taken")

    # phoenix only displays errors from changeset with actions
    %{changeset | action: :insert}
  end

  @doc false
  def changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, [:display_name])
    |> validate_required([:display_name])
    |> validate_change(:display_name, &validate_display_name/2)
    |> unique_constraint(:display_name)
  end

  @spec validate_display_name(:display_name, String.t) ::
    []
    | [display_name: String.t]
  # Validates that the display_name contains just alphanumeric and `!?$%-_.`
  # characters.
  defp validate_display_name(:display_name, value) do
    is_binary(value)
    && Regex.match?(~r/^[a-zA-Z0-9][a-zA-Z0-9\!\?\$\%\-\_\.]{1,15}$/, value)
    && []
    || [display_name: "has invalid format"]
  end

  defmodule Query do

    alias HEBornMigration.Web.Account
    alias HEBornMigration.Web.Claim

    import Ecto.Query, only: [where: 3]

    @spec by_token(Ecto.Queryable.t, Claim.token) :: Ecto.Queryable.t
    def by_token(query \\ Claim, token) do
      token = String.downcase(token)

      where(query, [c], c.token == ^token)
    end

    @spec by_display_name(Ecto.Queryable.t, Account.display_name) ::
      Ecto.Queryable.t
    def by_display_name(query \\ Claim, display_name),
      do: where(query, [c], c.display_name == ^display_name)
  end
end
