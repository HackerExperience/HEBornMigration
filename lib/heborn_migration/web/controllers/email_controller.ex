defmodule HEBornMigration.Web.EmailController do

  alias HELF.Mailer
  alias HEBornMigration.Web.Email

  def send_confirmation(to, code) do
    to
    |> Email.confirmation(code)
    |> Mailer.send_async(notify: true)
    |> Mailer.await(30_000)
  end
end
