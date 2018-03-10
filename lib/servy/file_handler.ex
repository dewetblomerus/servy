defmodule Servy.FileHandler do
  def handle_file({:ok, contents}, conv) do
    %{ conv | status: 200, resp_body: contents }
  end

  def handle_file({:error, :enoent}, conv) do
    %{ conv | status: 404, resp_body: "file not found" }
  end

  def handle_file({:error, contents}, conv) do
    %{ conv | status: 500, resp_body: "file read error #{contents}" }
  end
end
