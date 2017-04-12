defmodule HEBornMigration.Model.Account do

  use Ecto.Schema

  alias Comeonin.Bcrypt
  alias HEBornMigration.Model.Claim

  import Ecto.Changeset

  @type id :: pos_integer

  @type t :: %__MODULE__{
    id: pos_integer,
    email: String.t,
    username: String.t,
    display_name: String.t,
    password: String.t,
    confirmed: boolean,
    inserted_at: NaiveDateTime.t,
    updated_at: NaiveDateTime.t
  }

  schema "accounts" do
    field :email, :string
    field :username, :string
    field :display_name, :string
    field :password, :string
    field :confirmed, :boolean,
      default: false

    timestamps()
  end

  @spec create(Claim.t, String.t, String.t) ::
    Ecto.Changeset.t
  @doc """
  Creates Account to be migrated
  """
  def create(claim, email, password) do
    params = %{
      email: email,
      display_name: claim.display_name,
      password: password
    }

    changeset(%__MODULE__{}, params)
  end

  @spec confirm(t) ::
    Ecto.Changeset.t
  @doc """
  Confirms existing account
  """
  def confirm(struct),
    do: changeset(struct, %{confirmed: true})

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :display_name, :password, :confirmed])
    |> validate_change(:email, &validate_email/2)
    |> validate_change(:display_name, &validate_display_name/2)
    |> validate_length(:password, min: 8)
    |> update_change(:email, &String.downcase/1)
    |> update_change(:password, &Bcrypt.hashpwsalt/1)
    |> put_user_name()
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  @spec put_user_name(Ecto.Changeset.t) ::
    Ecto.Changeset.t
  defp put_user_name(changeset) do
    case fetch_change(changeset, :display_name) do
      {:ok, display_name} ->
        put_change(changeset, :username, String.downcase(display_name))
      :error ->
        changeset
    end
  end

  @spec validate_email(:email, String.t) ::
    []
    | [email: String.t]
  # Validates that the email is a valid email address
  #
  # TODO: Remove this regex and use something better
  defp validate_email(:email, value) do
    is_binary(value)
    && Regex.match?(~r/^[\w0-9\.\-\_\+]+@[\w0-9\.\-\_]+\.[\w0-9\-]+$/ui, value)
    && []
    || [email: "has invalid format"]
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

    alias HEBornMigration.Model.Account

    import Ecto.Query, only: [where: 3]

    @spec by_id(Ecto.Queryable.t, Account.id) :: Ecto.Queryable.t
    def by_id(query \\ Account, account_id),
      do: where(query, [a], a.account_id == ^account_id)

    @spec by_username(Ecto.Queryable.t, String.t) :: Ecto.Queryable.t
    def by_username(query \\ Account, username) do
      username = String.downcase(username)

      where(query, [a], a.username == ^username)
    end
  end
end
