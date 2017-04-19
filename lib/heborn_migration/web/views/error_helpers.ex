defmodule HEBornMigration.Web.ErrorHelpers do
  use Phoenix.HTML

  def error_tag(form, field) do
    with {msg, opts} <- form.errors[field] do
      error =
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)

      content_tag :span, error, class: "pure-form-message"
    end
  end
end
