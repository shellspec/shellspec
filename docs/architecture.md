# Architecture

```
shellspec command                             specfile execution
+-------------------------------+             +-------------------------------+
| 1. shellspec                  |             | The translated specfile is    |
|   Parsing options.            |             | just a plain shell script     |
|                               |             | that include the core scripts |
| 2. shellspec-runner.sh        |             | of shellspec.                 |
|   Execute executor and        |             |                               |
|   reporter.                   |             | It is executed in a separate  |
|     |                         | translated  | process from shellspec        |
|     v                         | specfile    | command.                      |
|   3. shellspec-executor.sh ---|------------>|                               |
|     Execute translator and    |             | Do not use external command,  |
|     translated specfile.      |             | subshell, pipe, and command   |
|       |                       |             | substituion from core scripts |
|       v                       |             | as much as possibe for        |
|     4. shellspec-translate.sh |             | performance and portability.  |
|       Translate specfile.     | reporting   |                               |
|                               | protocol    | Currently, only command-based |
| 5. shellspec-reporter.sh <----|-------------| mocks use external commands.  |
|   Reporting.                  |             |                               |
|                               |             | This rule applies only to     |
| Can be used POSIX compliant   |             | core scripts. You can use     |
| commands, but make as less    |             | external commands freely in   |
| as possible.                  |             | your test code.               |
+-------------------------------+             +-------------------------------+
```
