#shellcheck shell=sh disable=SC2034

# Pending is better than skip in some case. Skip is just only skips,
# but Pending is runs example and decide the success or failure.
# The pend example success if the expectations fails as expected.
# The pend example fails if the expectation succeeds unexpectedly.

Describe 'pending sample'
  Example 'this example not fails (because it is not yet implemented as expected)'
    Pending 'not yet implemented'
    echo_ok() { :; } # not yet implemented
    When call echo_ok
    The output should eq "ok"
  End

  Example 'this example fails (because it is implemented as unexpected)'
    Pending 'not yet implemented'
    echo_ok() { echo ok; } # implemented
    When call echo_ok
    The output should eq "ok"
  End
End
