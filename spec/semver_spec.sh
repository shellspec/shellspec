#shellcheck shell=sh

Describe "semver.sh"
  Include "$SHELLSPEC_LIB/semver.sh"

  Describe "check_semver()"
    Parameters
      0.10              failure
      0.10.0-pre%       failure
      0.10.0            success
      0.10.0-pre        success
      0.10.0-pre.rc     success
      0.10.0+build      success
      0.10.0-pre+build  success
      0.10a.0           failure
      0.1.2@a           failure
      0.1               failure
      0.1.              failure
      0.1.2.            failure
      .1.2              failure
      0..2              failure
      0.1.2.3           failure
    End

    It 'checks semantic version'
      When call check_semver "$1"
      The status should be "$2"
    End
  End

  Describe "cmp_semver()"
    Parameters
      # 0: x=y, 1: x<y, 2: x>y
      0.27.0        0.28.0            1
      0.28.0        0.28.0            0
      0.28.0-patch  0.28.0            1
      0.28.0-patch  0.28.0-patch2     0
      0.28.0+build  0.28.0            0
      0.28.0+build  0.28.0+build      0
      0.28.0+build  0.28.0+build2     0
      0.28.1        0.28.0            2
      0.28.0        1.0.0             1
      0.28.0        0.28.0-dev        2
      0.28.0        0.28.0-dev+patch  2
      0.28.0        0.28.0+patch      0
      0.28.0        0.28.0+patch-foo  0
    End

    It 'compares semantic version'
      When call cmp_semver "$1" "$2"
      The status should eq "$3"
    End
  End

  Describe "semver()"
    It 'raises error when specified an invalid operator'
      When run semver 1.0.0 -x 2.0.0
      The status should be failure
      The error should eq "Unexpected operator: -x"
    End

    Parameters
      0.27.0 -lt 0.28.0 success
      0.27.0 -lt 0.27.0 failure
      0.29.0 -lt 0.28.0 failure

      0.27.0 -le 0.28.0 success
      0.27.0 -le 0.27.0 success
      0.29.0 -le 0.28.0 failure

      0.27.0 -eq 0.28.0 failure
      0.27.0 -eq 0.27.0 success
      0.29.0 -eq 0.28.0 failure

      0.27.0 -ne 0.28.0 success
      0.27.0 -ne 0.27.0 failure
      0.29.0 -ne 0.28.0 success

      0.27.0 -gt 0.28.0 failure
      0.27.0 -gt 0.27.0 failure
      0.29.0 -gt 0.28.0 success

      0.27.0 -ge 0.28.0 failure
      0.27.0 -ge 0.27.0 success
      0.29.0 -ge 0.28.0 success
    End

    It 'compares semantic version'
      When call semver "$1" "$2" "$3"
      The status should be "$4"
    End
  End
End
