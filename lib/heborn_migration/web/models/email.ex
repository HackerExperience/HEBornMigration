defmodule HEBornMigration.Web.Email do

  alias HELF.Mailer
  alias HEBornMigration.Web.LayoutView
  alias HEBornMigration.Web.PageView

  import Phoenix.View, only: [render_to_string: 3]

  def confirmation(to, code) do
    link = "https://migrate.hackerexperience.com/confirm"

    assigns = [
      code: code,
      link: link,
      link_with_code: link <> "/#{code}",
      layout: {LayoutView, "email.html"}
    ]

    html_message = render_to_string(PageView, "confirmation_email.html", assigns)

    text_message = """
    Access [#{link}] and confirm your account with the following code: [#{code}]
    """
    {LayoutModule, "template.extension"}

    Mailer.new()
    |> Mailer.to(to)
    |> Mailer.subject("Confirm your new HEBorn account")
    |> Mailer.html(html_message)
    |> Mailer.text(text_message)
  end
end
