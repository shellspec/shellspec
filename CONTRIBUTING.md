# CONTRIBUTING

1. Understand the architecture
2. Test in supported shells


- [Architecture](#Architecture)
- [Test](#Test)
  - [contrib/all.sh](#contriballsh)
  - [contrib/test_in_docker.sh](#contribtestindockersh)
  - [contrib/check.sh](#contribchecksh)
  - [contrib/bugs.sh](#contribbugssh)

## Architecture

```
shellspec command                              specfile execution
+-------------------------------+              +------------------------------+
| 1. shellspec                  |              | Translated specfile is just  |
|   Parsing options.            |              | a plain shell script.        |
|                               |              |                              |
| 2. shellspec-runner.sh        |              | Execute in a separated       |
|   Execute executor and        |              | process from shellspec       |
|   reporter.                   |              | command.                     |
|     |                         |  translated  |                              |
|     v                         |  specfile    | Do not use external command, |
|   3. shellspec-executor.sh ---|------------->| including POSIX compliant    |
|     Execute translator and    |              | commands for performance.    |
|     translated specfile.      |              |                              |
|       |                       |              | Avoid using subshell, pipe   |
|       v                       |              | and command substituion as   |
|     4. shellspec-translate.sh |              | possibe as you can for       |
|       Translate specfile.     |  reporting   | performance.                 |
|                               |  protocol    |                              |
| 5. shellspec-reporter.sh <----|--------------|                              |
|   Reporting.                  |              |                              |
|                               |              |                              |
| Can be used POSIX compliant   |              |                              |
| commands, but make as less    |              |                              |
| as possible.                  |              |                              |
+-------------------------------+              +------------------------------+
```

## Test

### contrib/all.sh

Use `contrib/all.sh` to test on all installed shells.

Usage: `contrib/all.sh [COMMNAD (shellspec and etc)]`

### contrib/test_in_docker.sh

Use `contrib/test_in_docker.sh` to test on supported shells (Requires docker).

Usage: `contrib/test_in_docker.sh <DOCKERFILES...> [-- COMMAND]`

Dockerfile is in `dockerfiles` directory
(The filename begin with `.` is not a supported shell).

### contrib/check.sh

Use `contrib/check.sh` to check shell scripts (Requires docker).

Usage: `contrib/check.sh`

### contrib/bugs.sh

This script detects shell bugs and problems.

Usage: `contrib/bugs.sh`
