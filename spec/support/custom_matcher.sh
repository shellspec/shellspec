#shellcheck shell=sh

# always matched
shellspec_syntax shellspec_matcher__matched_
shellspec_matcher__matched_() { shellspec_on MATCHED; }

# always unmatched
shellspec_syntax shellspec_matcher__unmatched_
shellspec_matcher__unmatched_() { :; }

shellspec_syntax shellspec_matcher__syntax_error_matcher_
shellspec_matcher__syntax_error_matcher_() { shellspec_on SYNTAX_ERROR; }
