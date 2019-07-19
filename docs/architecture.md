# Architecture

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
|                               |              | Of course you can use        |
| Can be used POSIX compliant   |              | external commands and etc    |
| commands, but make as less    |              | freely in your test code.    |
| as possible.                  |              |                              |
+-------------------------------+              +------------------------------+
```
