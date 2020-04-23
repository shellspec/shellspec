#shellcheck shell=sh

Describe "libexec/binary.sh"
  Include "$SHELLSPEC_LIB/libexec/task.sh"

  Describe "task()"
    It 'registers task'
      BeforeCall SHELLSPEC_TASK_SOURCE="test_task.sh"
      BeforeCall 'task "dummy:task" "Dummy task"'
      When call task "test:task" "Test task"
      The variable SHELLSPEC_TASKS should eq "dummy:task test:task"
      The variable SHELLSPEC_TASK_test_task should eq "test_task.sh"
      The variable SHELLSPEC_TASK_DESC_test_task should eq "Test task"
    End
  End

  Describe "enum_tasks()"
    setup() {
      SHELLSPEC_TASK_SOURCE="test_task1.sh"
      task "test:task1" "Task1"
      SHELLSPEC_TASK_SOURCE="test_task2.sh"
      task "test:task2" "Task2"
      SHELLSPEC_TASK_SOURCE="test_task3.sh"
      task "test:task3" "Task3"
    }
    Before setup
    callback() { echo "$@"; }

    It 'enumerates tasks'
      When call enum_tasks callback
      The line 1 of stdout should eq "test:task1 Task1"
      The line 2 of stdout should eq "test:task2 Task2"
      The line 3 of stdout should eq "test:task3 Task3"
    End
  End

  Describe "invoke()"
    setup() {
      # shellcheck disable=SC2034
      SHELLSPEC_TASK_SOURCE="test_task.sh"
      task "test:task" "Task"
    }
    Before setup
    cat() { echo "test_task_task() { echo ok; }"; }

    It 'invokes tasks'
      When call invoke "test:task"
      The stdout should eq "ok"
    End

    It 'aborts with invalid task name'
      When run invoke "test:no-task"
      The stderr should include 'Not found task'
      The stderr should include 'test:no-task'
      The status should be failure
    End
  End
End
