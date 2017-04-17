defmodule HEBornMigration.Web.EmailController do

  alias HELF.Mailer
  alias HEBornMigration.Web.Email

  # FIXME: use a template for both html_message and text_message
  def send_confirmation(to, code) do
    to
    |> Email.confirmation(code)
    |> Mailer.send()
  end
end
