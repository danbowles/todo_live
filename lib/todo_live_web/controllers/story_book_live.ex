defmodule TodoLiveWeb.StoryBookLive do
  use Phoenix.LiveView
  alias TodoLiveWeb.CoreComponents

  defp icon_names() do
    (File.cwd!() <> "/assets/vendor/heroicons/optimized/20/solid")
    |> Path.expand()
    |> File.ls!()
    |> Enum.map(fn path ->
      "hero-" <> String.replace(path, ".svg", "")
    end)
  end

  @impl true
  def mount(_params, _session, socket) do
    CoreComponents.show_modal("basic_modal")
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <CoreComponents.modal id="basic_modal">
      <h2>Modal Title</h2>
      <p>Modal Body</p>
    </CoreComponents.modal>
    <div class="m-6">
      <h1 class="text-lg mb-4 font-semibold">Icons storybook</h1>
      <div class="flex flex-col flex-wrap space-evenly">
        <%= for icon_name <- icon_names() do %>
          <section class="p-4 outline outline-1 mb-2 rounded">
            <h2 class="font-semibold"><%= icon_name %></h2>
            <div class="flex space-x-2 p-y-2 p-x-4 mr-2 my-2">
              <CoreComponents.icon name={icon_name} />
              <p>&ltCoreComponents.icon name="<%= icon_name %>"/&gt</p>
            </div>
            <div class="flex space-x-2 p-y-2 p-x-4 mr-2 my-2">
              <CoreComponents.icon name={icon_name<> "-mini"} />
              <p>&ltCoreComponents.icon name="<%= icon_name %>-mini"/&gt</p>
            </div>
            <div class="flex space-x-2 p-y-2 p-x-4 mr-2 my-2">
              <CoreComponents.icon name={icon_name<> "-solid"} />
              <p>&ltCoreComponents.icon name="<%= icon_name %>-solid"/&gt</p>
            </div>
          </section>
        <% end %>
      </div>
    </div>
    """
  end
end
