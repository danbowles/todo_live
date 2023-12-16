defmodule TodoLive.TasksTest do
  use TodoLive.DataCase

  alias TodoLive.Tasks

  describe "task" do
    alias TodoLive.Tasks.Task

    import TodoLive.TasksFixtures

    @invalid_attrs %{complate: nil, name: nil}

    test "list_task/0 returns all task" do
      task = task_fixture()
      assert Tasks.list_task() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Tasks.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{complate: true, name: "some name"}

      assert {:ok, %Task{} = task} = Tasks.create_task(valid_attrs)
      assert task.complate == true
      assert task.name == "some name"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      update_attrs = %{complate: false, name: "some updated name"}

      assert {:ok, %Task{} = task} = Tasks.update_task(task, update_attrs)
      assert task.complate == false
      assert task.name == "some updated name"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end
end
