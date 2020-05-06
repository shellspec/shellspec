#shellcheck shell=sh disable=SC2016

Describe "core/hook.sh"
  Before 'shellspec_create_hook EXAMPLE'
  BeforeAll :
  AfterAll :

  Describe 'shellspec_call_before_hooks()'
    Describe "before each"
      Context 'when hooks are empty'
        It 'does nothing if not exists before hooks'
          When call shellspec_call_before_hooks EXAMPLE
          The stdout should be blank
        End
      End

      Context 'when hooks are exists'
        example_hooks() {
          shellspec_register_before_hook EXAMPLE 'echo 1'
          shellspec_register_before_hook EXAMPLE 'echo 2'
          shellspec_register_before_hook EXAMPLE 'echo 3'
        }

        It 'calls hooks in registration order'
          BeforeCall example_hooks
          When call shellspec_call_before_hooks EXAMPLE
          The line 1 of stdout should equal 1
          The line 2 of stdout should equal 2
          The line 3 of stdout should equal 3
        End
      End
    End

    Describe "before all"
      BeforeRun setup mock
      setup() { shellspec_register_before_hook ALL 'echo foo'; }

      Context 'when group is not executed'
        mock() { shellspec_is_marked_group() { false; }; }

        It 'calls before all hooks'
          When run shellspec_call_before_hooks ALL
          The stdout should eq foo
        End
      End

      Context 'when group is already executed'
        mock() { shellspec_is_marked_group() { true; }; }

        It 'not calls before all hooks'
          When run shellspec_call_before_hooks ALL
          The stdout should be blank
        End
      End
    End
  End

  Describe 'shellspec_call_after_hooks()'
    Describe "after each"
      Context 'when hooks are empty'
        It 'does nothing if not exists after hooks'
          When call shellspec_call_after_hooks EXAMPLE
          The stdout should be blank
        End
      End

      Context 'when hooks are exists'
        example_hooks() {
          shellspec_register_after_hook EXAMPLE 'echo 1'
          shellspec_register_after_hook EXAMPLE 'echo 2'
          shellspec_register_after_hook EXAMPLE 'echo 3'
        }

        It 'calls hooks in reverse registration order'
          BeforeCall example_hooks
          When call shellspec_call_after_hooks EXAMPLE
          The line 1 of stdout should equal 3
          The line 2 of stdout should equal 2
          The line 3 of stdout should equal 1
        End
      End
    End

    Describe "after all"
      BeforeRun setup mock
      setup() { shellspec_register_after_hook ALL 'echo foo'; }

      Context 'when group is not executed'
        mock() { shellspec_is_marked_group() { false; }; }

        It 'does not call after all hooks'
          When run shellspec_call_after_hooks ALL
          The stdout should be blank
        End
      End

      Context 'when group is already executed'
        mock() { shellspec_is_marked_group() { true; }; }

        It 'calls after all hooks'
          When run shellspec_call_after_hooks ALL
          The stdout should eq foo
        End

        Context 'when SHELLSPEC_GROUP_ID is not matched'
          BeforeRun 'SHELLSPEC_GROUP_ID=99999'
          It 'does not call after all hooks'
            When run shellspec_call_after_hooks ALL
            The stdout should be blank
          End
        End
      End
    End
  End

  Describe 'shellspec_mark_group()'
    setup() { mkdir "$SHELLSPEC_TMPBASE/workdir"; }
    cleanup() { rm -rf "$SHELLSPEC_TMPBASE/workdir"; }
    Before setup
    After cleanup

    BeforeRun 'SHELLSPEC_WORKDIR=$SHELLSPEC_TMPBASE/workdir'

    It 'creates mark group files'
      When run shellspec_mark_group 1-2-3
      The file "$SHELLSPEC_TMPBASE/workdir/@" should be exist
      The file "$SHELLSPEC_TMPBASE/workdir/@1" should be exist
      The file "$SHELLSPEC_TMPBASE/workdir/@1-2" should be exist
      The file "$SHELLSPEC_TMPBASE/workdir/@1-2-3" should be exist
    End
  End
End
