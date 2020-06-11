#shellcheck shell=sh

shellspec_proxy 'shellspec_subject' 'shellspec_syntax_dispatch subject'
shellspec_syntax_compound 'shellspec_subject_entire'

shellspec_import 'core/subjects/line'
shellspec_import 'core/subjects/path'
shellspec_import 'core/subjects/status'
shellspec_import 'core/subjects/stderr'
shellspec_import 'core/subjects/stdout'
shellspec_import 'core/subjects/value'
shellspec_import 'core/subjects/variable'
shellspec_import 'core/subjects/word'
