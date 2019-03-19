#shellcheck shell=sh

Describe "core/output.sh"
  Describe "shellspec_output_syntax_name()"
    output_syntax_name() {
      shellspec_syntax shellspec_syntaxtype_foo_bar_baz
      shellspec_syntaxtype_foo_bar_baz() { :; }
      shellspec_syntax_dispatch syntaxtype foo_bar_baz
      shellspec_output_syntax_name
    }

    Example "outputs syntax name"
      When invoke output_syntax_name
      The stdout should equal 'foo bar baz syntaxtype'
    End
  End
End
