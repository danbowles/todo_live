defmodule TodoLiveWeb.HomeLive do
  use TodoLiveWeb, :live_view
  import TodoLiveWeb.CoreComponents
  alias TodoLive.Repo
  alias TodoLive.Tasks
  alias TodoLive.Tasks.Task

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    tasks = Tasks.list_task()

    case params["show"] do
      "complete" ->
        completed_tasks = Enum.filter(tasks, &(&1.complete == true))
        {:noreply, assign(socket, tasks: completed_tasks)}

      "active" ->
        active_tasks = Enum.filter(tasks, &(&1.complete == false))
        {:noreply, assign(socket, tasks: active_tasks)}

      _ ->
        {:noreply, assign(socket, tasks: tasks)}
    end
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
