Describe "Profiler sample"
  Example "1: sleep 0.1 (line 2)"
    When call sleep 0.1
    The status should be success
  End

  Example "2: sleep 0.4 (line 7)"
    When call sleep 0.4
    The status should be success
  End

  Example "3: sleep 0.3 (line 12)"
    When call sleep 0.3
    The status should be success
  End

  Example "4: sleep 0.2 (line 17)"
    When call sleep 0.2
    The status should be success
  End

  Example "5: sleep 0.5 (line 22)"
    When call sleep 0.5
    The status should be success
  End
End
