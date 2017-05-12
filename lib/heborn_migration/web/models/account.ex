defmodule HEBornMigration.Web.Account do

  use Ecto.Schema

  alias Comeonin.Bcrypt
  alias HEBornMigration.Web.Confirmation

  import Ecto.Changeset

  @type id :: pos_integer
  @type email :: String.t
  @type username :: String.t
  @type display_name :: String.t
  @type password :: String.t

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

  # unconfirmed account expire date
  @expiration_time 1 * 24 * 60 * 60

  schema "accounts" do
    field :email, :string
    field :username, :string
    field :display_name, :string
    field :password, :string
    field :token, :string,
      virtual: true
    field :password_confirmation, :string,
      virtual: true
    field :confirmed, :boolean,
      default: false

    has_one :confirmation, Confirmation,
      foreign_key: :id

    timestamps()
  end

  @spec create(display_name, email, password, confirmation :: password) ::
    Ecto.Changeset.t
  @doc """
  Creates Account to be migrated.
  """
  def create(display_name, email, password, password_confirmation) do
    params = %{
      display_name: display_name,
      email: email,
      password: password,
      password_confirmation: password_confirmation
    }

    %__MODULE__{}
    |> changeset(params)
    |> validate_password()
    |> put_assoc(:confirmation, Confirmation.create())
  end

  @spec invalid_token_changeset(email, password, confirmation :: password) ::
    Ecto.Changeset.t
  @doc """
  Returns a changeset with an invalid_token error, used when trying to migrate
  with an invalid/expired token.
  """
  def invalid_token_changeset(email, password, password_confirmation) do
    params = %{
      email: email,
      password: password,
      password_confirmation: password_confirmation
    }

    changeset =
      %__MODULE__{}
      |> changeset(params)
      |> validate_password()
      |> add_error(:token, "is invalid")

    # phoenix only displays errors from changeset with actions
    %{changeset | action: :insert}
  end

  @spec expired?(t) ::
    boolean
  @doc """
  Checks if the account is unconfirmed for more than 24 hours.
  """
  def expired?(struct) do
    now = NaiveDateTime.utc_now()
    NaiveDateTime.diff(now, struct.inserted_at) > @expiration_time
  end

  @spec confirm(t) ::
    Ecto.Changeset.t
  @doc """
  Confirms existing account.
  """
  def confirm(struct),
    do: changeset(struct, %{confirmed: true})

  @doc false
  def changeset(struct, params) do
    # no display_name validation is being done here as it was already
    # validated on Claim model
    struct
    |> cast(params, [:token, :display_name, :email, :password, :confirmed])
    |> propagate_change(:display_name, :username, &String.downcase/1)
    |> unique_constraint(:username)
    |> validate_change(:email, &validate_email/2)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 8)
    |> update_change(:password, &Bcrypt.hashpwsalt/1)
    |> validate_required([:display_name, :username, :email, :password])
  end

  # propagates a change to another field, optionall accepts a mapping function
  defp propagate_change(changeset, from, to, fun) do
    case fetch_change(changeset, from) do
      {:ok, value} ->
        put_change(changeset, to, fun.(value))
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
    || [email: "Invalid email format"]
  end

  @spec validate_password(Ecto.Changeset.t) :: Ecto.Changeset.t
  defp validate_password(changeset) do
    validate_confirmation(
      changeset,
      :password,
      required: true,
      message: "Passwords do not match")
  end

  defmodule Query do

    alias HEBornMigration.Web.Account

    import Ecto.Query, only: [where: 3]

    @spec by_username(
      Ecto.Queryable.t,
      Account.username | Account.display_name) :: Ecto.Queryable.t
    def by_username(query \\ Account, username) do
      username = String.downcase(username)

      where(query, [a], a.username == ^username)
    end
  end
end
