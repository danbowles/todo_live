defmodule TodoLiveWeb.HomeLive do
  use Phoenix.LiveView
  import TodoLiveWeb.CoreComponents
  alias TodoLive.Repo
  alias TodoLive.Tasks.Task

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_assigns = %{
      tasks: TodoLive.Repo.all(TodoLive.Tasks.Task),
      add_task_form:
        Phoenix.Component.to_form(TodoLive.Tasks.Task.changeset(%TodoLive.Tasks.Task{}, %{}))
    }

    {:ok, assign(socket, default_assigns)}
  end

  defp title(assigns) do
    ~H"""
    <div class="flex items-center mb-6">
      <TodoLiveWeb.CoreComponents.icon
        name="hero-rectangle-stack-solid"
        class="h-12 w-12 text-purple-400 stroke-current"
      />

      <h4 class="font-semibold ml-3 text-2xl">Live Tasks</h4>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("create_task", %{"task" => params}, socket) do
    case Repo.insert(Task.changeset(%Task{}, params)) do
      {:error, message} ->
        {:noreply, socket |> put_flash(:error, inspect(message))}

      {:ok, _} ->
        new_assigns = %{
          tasks: TodoLive.Repo.all(TodoLive.Tasks.Task)
        }

        socket =
          socket
          |> put_flash(:info, "Task created successfully")
          |> assign(new_assigns)
          |> push_event("close_modal", %{to: "close_button_add_task_modal"})

        {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center w-screen h-screen font-medium">
      <div class="flex flex-grow items-center justify-center h-full text-gray-600 bg-gray-100">
        <div class="max-w-full p-8 bg-white rounded-lg shadow-lg w-96">
          <%= title(assigns) %>
          <ul class="mb-5">
            <%= for task <- @tasks do %>
              <li>
                <.input
                  type="checkbox"
                  id={task.id}
                  name={task.name}
                  checked={task.complete}
                  label={task.name}
                  phx-click="toggle_task"
                />
              </li>
            <% end %>
          </ul>
          <%!-- Add New --%>
          <div class="flex justify-end">
            <.button class="flex items-center" phx-click={show_modal("add_task_modal")}>
              <.icon class="mr-1" name="hero-plus-circle" /> Add New Task
            </.button>
          </div>
          <%!-- End Add New --%>
        </div>
      </div>
      <.modal id="add_task_modal">
        <h2>What needs doin'?</h2>
        <.simple_form for={@add_task_form} phx-submit="create_task">
          <.input field={@add_task_form[:name]} label="Task Name" />
          <:actions>
            <.button class="flex items-center mr-1">
              <.icon class="mr-1" name="hero-plus" /> Save
            </.button>
            <.button
              type="reset"
              class="flex items-center bg-red-900 hover:bg-red-700"
              phx-click={hide_modal("add_task_modal")}
            >
              <.icon class="mr-1" name="hero-x-circle" /> Cancel
            </.button>
          </:actions>
        </.simple_form>
      </.modal>
    </div>
    """
  end
end
