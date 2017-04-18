defmodule HEBornMigration.Web.ErrorHelpers do
  use Phoenix.HTML

  def error_tag(form, field) do
    if error = form.errors[field] do
      content_tag :span, translate_error(error), class: "help-block"
    end
  end

  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(HEBornMigration.Web.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(HEBornMigration.Web.Gettext, "errors", msg, opts)
    end
  end
end
