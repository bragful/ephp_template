defmodule Ephp.Template do
  require Logger
  @moduledoc """
  The Phoenix engine that handles the `.php` extension.
  """

  alias Ephp.Template, as: EphpTemplate
  alias :ephp, as: Ephp
  alias :ephp_config, as: EphpConfig
  alias :ephp_output, as: EphpOutput
  alias :ephp_context, as: EphpContext
  alias :ephp_parser, as: EphpParser
  alias :ephp_array, as: EphpArray

  @behaviour Phoenix.Template.Engine

  def register_server(context, conn) do
    method = to_string(conn.method)
    remote_ip = to_string(:inet.ntoa(conn.remote_ip))
    data = [
      {"_SERVER", ["PHP_SELF"], to_string(conn.script_name)},
      # {"_SERVER", ["SERVER_ADDR"], conn.},
      {"_SERVER", ["SERVER_NAME"], conn.host},
      # {"_SERVER", ["SERVER_SOFTWARE"], conn.},
      {"_SERVER", ["REQUEST_METHOD"], method},
      # {"_SERVER", ["REQUEST_TIME"], conn.},
      # {"_SERVER", ["REQUEST_TIME_FLOAT"], conn.},
      {"_SERVER", ["QUERY_STRING"], conn.query_string},
      {"_SERVER", ["DOCUMENT_ROOT"], File.cwd!()},
      # {"_SERVER", ["HTTP_ACCEPT"], conn.},
      # {"_SERVER", ["HTTP_ACCEPT_CHARSET"], conn.},
      # {"_SERVER", ["HTTP_ACCEPT_ENCODING"], conn.},
      # {"_SERVER", ["HTTP_ACCEPT_LANGUAGE"], conn.},
      # {"_SERVER", ["HTTP_CONN.CION"]), conn.},
      # {"_SERVER", ["HTTP_HOST"], conn.},
      # {"_SERVER", ["HTTP_REFERER"], conn.},
      # {"_SERVER", ["HTTP_USER_AGENT"], conn.},
      {"_SERVER", ["REMOTE_ADDR"], remote_ip},
      # {"_SERVER", ["REMOTE_HOST"], conn.},
      # {"_SERVER", ["REMOTE_PORT"], conn.},
      # {"_SERVER", ["SCRIPT_FILENAME"], conn.},
      # {"_SERVER", ["SERVER_ADMIN"], conn.},
      {"_SERVER", ["SERVER_PORT"], conn.port},
      # {"_SERVER", ["SERVER_SIGNATURE"], conn.},
      {"_SERVER", ["SCRIPT_NAME"], to_string(conn.script_name)},
      {"_SERVER", ["REQUEST_URI"], to_string(conn.path_info)},
      {"_SERVER", ["PATH_INFO"], to_string(conn.path_info)},
    ]
    EphpContext.set_bulk(context, data)
  end

  def register_request(context, method, params) do
    method = "_" <> to_string(method)
    data = params
           |> Enum.flat_map(fn {key, val} ->
                              [{method, [key], val},
                               {"_REQUEST", [key], val}]
                            end)
    EphpContext.set_bulk(context, data)
  end

  def register_env(context) do
    data = Enum.map(System.get_env(),
                    fn {k, v} -> {"_ENV", [k], v} end)
    EphpContext.set_bulk(context, data)
  end

  def register_cookies(context, cookies) do
    data = Enum.map(cookies,
                    fn {k, v} -> {"_COOKIE", [k], v} end)
    EphpContext.set_bulk(context, data)
  end

  defp tr(%{} = assigns) do
    assigns
    |> Enum.map(fn {k, v} -> {to_string(k), tr(v)} end)
    |> EphpArray.from_list()
  end
  defp tr(list) when is_list(list) do
    list
    |> Enum.map(&tr/1)
    |> EphpArray.from_list()
  end
  defp tr(true), do: true
  defp tr(false), do: false
  defp tr(nil), do: :undefined
  defp tr(atom) when is_atom(atom), do: to_string(atom)
  defp tr(tuple) when is_tuple(tuple), do: tr(Tuple.to_list(tuple))
  defp tr(other), do: other

  def register_assigns(context, assigns) do
    data = Enum.map(assigns, fn {k, v} -> {to_string(k), tr(v)} end)
    EphpContext.set_bulk(context, data)
  end

  def run(path, name, content, info) do
    Logger.debug "[ephp template] running [#{name}] => #{inspect content}"
    filename = Path.absname(path)
    EphpConfig.start_link(Application.get_env(:php, :php_ini, "php.ini"))
    EphpConfig.start_local()
    {:ok, ctx} = Ephp.context_new(filename)
    conn = info[:conn]
    assigns = conn.assigns
    Logger.debug "[ephp template] assigns => #{inspect assigns}"
    register_assigns(ctx, assigns)
    Ephp.register_superglobals(ctx, [name])
    register_server(ctx, conn)
    register_request(ctx, conn.method, conn.params)
    register_env(ctx)
    register_cookies(ctx, conn.cookies)
    {:ok, output} = EphpOutput.start_link(ctx, false)
    EphpContext.set_output_handler(ctx, output)
    try do
      Ephp.eval(filename, ctx, content)
    catch
      {:ok, :die} -> :ok
    end
    out = EphpContext.get_output(ctx)
    EphpContext.destroy_all(ctx)
    EphpConfig.stop_local
    {:safe, out}
  end

  def compile(path, name) do
    content = path
              |> File.read!()
              |> EphpParser.parse()
              |> Macro.escape()
    quote do
      EphpTemplate.run(unquote(path),
                       unquote(name),
                       unquote(content),
                       var!(assigns))
    end
  end
end
