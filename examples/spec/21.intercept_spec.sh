#shellcheck shell=sh

Describe 'intercept example'
  Intercept begin
  __begin__() {
    # Define stubs for cat
    cat() {
      if [ "${1:-}" = "/proc/cpuinfo" ];then
        %text
        #|processor       : 0
        #|vendor_id       : GenuineIntel
        #|cpu family      : 6
        #|model           : 58
        #|model name      :         Intel(R) Core(TM) i7-3770 CPU @ 3.40GHz
        #|
        #|processor       : 1
        #|vendor_id       : GenuineIntel
        #|cpu family      : 6
        #|model           : 58
        #|model name      :         Intel(R) Core(TM) i7-3770 CPU @ 3.40GHz
        #|
        #|processor       : 2
        #|vendor_id       : GenuineIntel
        #|cpu family      : 6
        #|model           : 58
        #|model name      :         Intel(R) Core(TM) i7-3770 CPU @ 3.40GHz
      else
        command cat "$@"
      fi
    }
  }
  Example 'test cpunum.sh with stubbed cat /cpu/info'
    When run source ./count_cpus.sh
    The stdout should eq 3
  End
End
