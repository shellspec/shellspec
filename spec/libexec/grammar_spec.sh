#shellcheck shell=sh

Describe "libexec/grammar.sh"
  # shellcheck disable=SC2034
  SHELLSPEC_SOURCE="$SHELLSPEC_LIB/libexec/grammar.sh"
  Include "$SHELLSPEC_LIB/libexec/grammar.sh"

  Describe 'mapping()'
    dsl() { false; }
    directive() { false; }
    is_function_name() { false; }

    It 'does not translate when it unknown line'
      When call mapping func args
      The status should be failure
    End

    It 'translate to DSL when it matches DSL'
      dsl() { echo DSL; return 0; }
      When call mapping func args
      The stdout should eq DSL
    End

    It 'translate to directive when it matches directive'
      is_function_name() { true; }
      directive() { echo directive; return 0; }
      When call mapping "func()" "{ %directive; }"
      The stdout should eq directive
    End
  End
End
