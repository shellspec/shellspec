#shellcheck shell=sh

shellspec_proxy 'shellspec_modifier' 'shellspec_syntax_dispatch modifier'
# dummy modifier to only dispatch to verb
shellspec_syntax_alias 'shellspec_modifier_should' \
  'shellspec_syntax_dispatch verb should'
shellspec_syntax_compound 'shellspec_modifier_entire'

shellspec_import 'core/modifiers/contents'
shellspec_import 'core/modifiers/length'
shellspec_import 'core/modifiers/line'
shellspec_import 'core/modifiers/lines'
shellspec_import 'core/modifiers/result'
shellspec_import 'core/modifiers/word'
