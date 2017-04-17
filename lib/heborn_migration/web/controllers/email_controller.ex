defmodule HEBornMigration.Web.EmailController do

  alias HELF.Mailer
  import HEBornMigration.Web.Router.Helpers, only: [page_path: 2, page_path: 3]

  # FIXME: use a template for both html_message and text_message
  def send_confirmation(conn, to, code) do
    link = page_path(conn, :get_confirm)
    link_with_code = page_path(conn, :confirm_by_link, code)

    html_message = """
    <p>Click <a href="#{link_with_code}">here</a> to confirm your account</p>
    <p>
      Trouble with the link?<br/>
      Access #{link} and use the following code to confirm your account:
    </p>
    <pre>#{code}</pre>
    """

    text_message = """
    Access #{link} and use the following code to confirm your account:
    #{code}
    """

    Mailer.new()
    |> Mailer.to(to)
    |> Mailer.subject("Confirm your new HEBorn account")
    |> Mailer.html(html_message)
    |> Mailer.text(text_message)
    |> Mailer.send()
  end
end
