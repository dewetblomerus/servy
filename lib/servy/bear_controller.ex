defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %{ conv | status: 200, resp_body: "Bear #{bear.id}: #{bear.name}" }
  end

  defp bear_item(bear) do
    "<li>#{bear.name} - #{bear.type}</li>"
  end

  def index(conv) do
    items = Wildthings.list_bears()
    |> Enum.filter(&Bear.is_grizzly/1)
    |> Enum.sort(&Bear.order_asc_name/2)
    |> Enum.map(&bear_item/1)
    |> Enum.join

    %{ conv | status: 200, resp_body: "<ul>#{items}</ul>" }
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{ conv | status: 201,
      resp_body: "Created a #{type} Bear named #{name}!" }
  end
end
