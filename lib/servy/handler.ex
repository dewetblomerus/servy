require IEx

defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def log(conv), do: IO.inspect(conv)

  def parse(request) do
    [method, path, _] = request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %{
      method: method,
      path: path,
      resp_body: "",
      status: nil,
    }
  end

  def rewrite_path(%{ path: "/wildlife" } = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(%{ path: "/bears?id=" <> id } = conv) do
    %{ conv | path: "/bears/#{id}" }
  end

  def rewrite_path(conv), do: conv

  def track(%{ status: 404, path: path } = conv) do
    IO.puts "Warning, #{path} is on the loose!!!"
    conv
  end

  def track(conv), do: conv

  def route(%{ method: "GET", path: "/wildthings" } = conv) do
    %{ conv | status: 200, resp_body: "Bats, Elepants, Hippos" }
  end

  def route(%{ method: "GET", path: "/bears" } = conv) do
    %{ conv | status: 200, resp_body: "Smokey, Paddington, Poo" }
  end

  def route(%{ method: "GET", path: "/bears/" <> id } = conv) do
    %{ conv | status: 200, resp_body: "Bear #{id}" }
  end

  def route(%{ method: "DELETE", path: "/bears" <> _id } = conv) do
    %{ conv | status: 403, resp_body: "Deleting a bear is forbidden" }
  end

  def route(%{ method: "GET", path: "/about" } = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  # def route(%{ method: "GET", path: "/about" } = conv) do
  #   file =
  #     Path.expand("../../pages", __DIR__)
  #     |> Path.join("about.html")

  #   case File.read(file) do
  #     {:ok, contents} ->
  #       %{ conv | status: 200, resp_body: contents }
  #     {:error, :enoent} ->
  #       %{ conv | status: 404, resp_body: "file not found" }
  #     {:error, contents} ->
  #       %{ conv | status: 500, resp_body: "file read error #{contents}" }
  #   end
  # end

  def route(%{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here" }
  end

  def handle_file({:ok, contents}, conv) do
    %{ conv | status: 200, resp_body: contents }
  end

  def handle_file({:error, :enoent}, conv) do
    %{ conv | status: 404, resp_body: "file not found" }
  end

  def handle_file({:error, contents}, conv) do
    %{ conv | status: 500, resp_body: "file read error #{contents}" }
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: 20

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

"""
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
|> Servy.Handler.handle
|> IO.puts

"""
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
|> Servy.Handler.handle
|> IO.puts

"""
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
|> Servy.Handler.handle
|> IO.puts

"""
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
|> Servy.Handler.handle
|> IO.puts

"""
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
|> Servy.Handler.handle
|> IO.puts

"""
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
|> Servy.Handler.handle
|> IO.puts

"""
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
|> Servy.Handler.handle
|> IO.puts

"""
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
|> Servy.Handler.handle
|> IO.puts
