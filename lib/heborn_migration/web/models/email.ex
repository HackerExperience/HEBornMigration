defmodule HEBornMigration.Web.Email do

  alias HELF.Mailer

  @url "1.hackerexperience.com/migrate"

  # FIXME: use a template for both html_message and text_message
  def confirmation(to, code) do
    link = @url <> "/confirm"
    link_with_code = @url <> "/confirm/#{code}"

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
  end
end
