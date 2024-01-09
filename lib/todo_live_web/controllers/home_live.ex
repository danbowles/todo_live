defmodule TodoLiveWeb.HomeLive do
  use TodoLiveWeb, :live_view
  import TodoLiveWeb.CoreComponents
  alias TodoLive.Repo
  alias TodoLive.Tasks
  alias TodoLive.Tasks.Task

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_assigns = %{
      tasks: Tasks.list_task(),
      add_task_form:
        Phoenix.Component.to_form(TodoLive.Tasks.Task.changeset(%TodoLive.Tasks.Task{}, %{})),
      edit_task_form:
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
  def handle_event("edit_task", %{"task" => %{"id" => id} = attrs}, socket) do
    task = Enum.find(socket.assigns.tasks, &(&1.id == id))

    case Repo.update(Tasks.Task.edit_changeset(task, attrs)) do
      {:error, message} ->
        {:noreply, socket |> put_flash(:error, inspect(message))}

      {:ok, _} ->
        new_assigns = %{
          tasks: Tasks.list_task(),
          edit_task_form:
            Phoenix.Component.to_form(TodoLive.Tasks.Task.changeset(%TodoLive.Tasks.Task{}, %{}))
        }

        socket =
          socket
          |> assign(new_assigns)
          |> push_event("close_modal", %{to: "#close_modal_btn_edit_modal"})

        {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("open_edit_modal", %{"task_id" => id}, socket) do
    task = Enum.find(socket.assigns.tasks, fn task -> task.id == id end)

    new_assigns = %{
      edit_task_form: Phoenix.Component.to_form(TodoLive.Tasks.Task.edit_changeset(task, %{}))
    }

    {:noreply, assign(socket, new_assigns)}
  end

  @impl Phoenix.LiveView
  def handle_event("create_task", %{"task" => params}, socket) do
    case Repo.insert(Task.changeset(%Task{}, params)) do
      {:error, message} ->
        {:noreply, socket |> put_flash(:error, inspect(message))}

      {:ok, _} ->
        new_assigns = %{
          tasks: Tasks.list_task()
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
  def handle_event("toggle_task", %{"id" => id}, socket) do
    task = Repo.get(Task, id)
    task |> Tasks.update_task(%{complete: !task.complete})
    socket = assign(socket, tasks: Tasks.list_task())
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center w-screen h-screen font-medium">
      <div class="flex flex-grow items-center justify-center h-full text-gray-600 bg-gray-100">
        <div>
          <span>Show:</span>
          <.link patch={~p"/?#{[show: "all"]}"}>All</.link>
          <.link patch={~p"/?#{[show: "complate"]}"}>Complete</.link>
          <.link patch={~p"/?#{[show: "active"]}"}>Active</.link>
        </div>
        <div class="max-w-full p-8 bg-white rounded-lg shadow-lg w-96">
          <%= title(assigns) %>
          <ul class="mb-5">
            <%= for task <- @tasks do %>
              <li class="flex items-center h-10 px-2 rounded hover:bg-gray-100">
                <.input
                  type="checkbox"
                  id={task.id}
                  name={task.name}
                  checked={task.complete}
                  label={task.name}
                  phx-click="toggle_task"
                  phx-value-id={task.id}
                />
                <button class="ml-auto" phx-click={open_edit_modal(task.id, task.name)}>
                  <span class="hidden">Edit</span>
                  <span class="hero-pencil-square-solid" />
                </button>
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
      <.modal id="edit_task_modal">
        <h2>Update task</h2>
        <.simple_form for={@edit_task_form} phx-submit="edit_task">
          <%= Phoenix.HTML.Form.hidden_input(@edit_task_form, :id, id: "edit_task_id_input") %>
          <.input field={@edit_task_form[:name]} label="Task Name" />
          <:actions>
            <.button class="flex items-center mr-1">
              <.icon class="mr-1" name="hero-plus" /> Save
            </.button>
            <.button
              type="reset"
              class="flex items-center bg-red-900 hover:bg-red-700"
              phx-click={hide_modal("edit_task_modal")}
            >
              <.icon class="mr-1" name="hero-x-circle" /> Cancel
            </.button>
          </:actions>
        </.simple_form>
      </.modal>
    </div>
    """
  end

  defp open_edit_modal(task_id, task_name) do
    %JS{}
    |> JS.push("open_edit_modal", value: %{task_id: task_id})
    |> JS.set_attribute({"value", task_name}, to: "#edit_name")
    |> JS.set_attribute({"value", task_id}, to: "#edit_task_id_input")
    |> show_modal_focus_on(
      "edit_task_modal",
      "close_modal_btn_create_modal"
    )
  end
end
