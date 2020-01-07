# References

- [Example Group](#example-group)
- [Example](#example)
  - [Evaluation](#evaluation)
  - [Expectation](#expectation)
    - [Subject](#subject)
    - [Modifier](#modifier)
    - [Matcher](#matcher)
- [Helper](#helper)
- [Directive](#directive)
- [Environment Variables](#environment-variables)

## Example Group

You can write a structured *Example* by using the DSL shown below:

| DSL              | Description                                                         |
| :--------------- | :------------------------------------------------------------------ |
| Describe ... End | Define a block for examples grouping. Examples groups are nestable. |
| Context ... End  | Synonym for `Describe`.                                             |

## Example

| DSL             | Description                                                                                    |
| :-------------- | :--------------------------------------------------------------------------------------------- |
| Example ... End | Define a block for Example. Write your example.                                                |
| Specify ... End | Synonym for `Example`.                                                                         |
| It ... End      | Synonym for `Example`.                                                                         |
| Todo            | Same as empty example, but not a block. One-liner syntax meaning it needs to be implementated. |

### Evaluation

The line beginning with `When` is the evaluation.

| Evaluation                                                       | Description                              |
| :--------------------------------------------------------------- | :--------------------------------------- |
| When call <code>&lt;FUNCTION&gt; [ARGUMENTS...]</code>           | Call function without subshell.          |
| When run <code>&lt;FUNCTION \| COMMAND&gt; [ARGUMENTS...]</code> | Run function or command within subshell. |
| When run command <code>&lt;COMMAND&gt; [ARGUMENTS...]</code>     | Run external command within subshell.    |
| When run source <code>&lt;SCRIPT&gt; [ARGUMENTS...]</code>       | Run script within subshell.              |

The differences between `call` and `run` / `run command` / `run source`:

|                    | `call`                 | `run`                | `run command`        | `run source`         |
| ------------------ | ---------------------- | -------------------- | -------------------- | -------------------- |
| Use of subshell    | call without subshell  | run within subshell  | run within subshell  | run within subshell  |
| target             | function               | function / command   | command              | shell script         |
| Stop with `set -e` | x                      | o                    | -                    | o                    |
| Catch `exit`       | x                      | o                    | -                    | o                    |
| Variable reference | o                      | x                    | -                    | x                    |
| Expectation Hooks  | BeforeCall / AfterCall | BeforeRun / AfterRun | BeforeRun / AfterRun | BeforeRun / AfterRun |
| Intercept          | x                      | x                    | -                    | o                    |

### Expectation

The line beginning with `The` is the evaluation. The *subject* or the *modifier* follows after `The`. And last is the *matcher*.

#### Subject

| Subject                                                                                           | Description                                   |
| :------------------------------------------------------------------------------------------------ | :-------------------------------------------- |
| output<br>stdout                                                                                  | Use the stdout of *Evaluation* as subject.    |
| error<br>stderr                                                                                   | Use the stderr of *Evaluation* as subject.    |
| status                                                                                            | Use the status of *Evaluation* as subject.    |
| path <code>&lt;PATH&gt;</code><br>file <code>&lt;PATH&gt;</code><br>dir <code>&lt;PATH&gt;</code> | Use the alias resolved path as the subject.   |
| value <code>&lt;VALUE&gt;</code><br>function <code>&lt;VALUE&gt;</code>                           | Use the value as the subject.                 |
| variable <code>&lt;NAME&gt;</code>                                                                | Use the value of the variable as the subject. |

#### Modifier

| Modifier                         | Description                           |
| :------------------------------- | :------------------------------------ |
| line <code>&lt;NUMBER&gt;</code> | The specified line of the subject.    |
| lines                            | The number of lines of the subject.   |
| word <code>&lt;NUMBER&gt;</code> | The specified word of the subject.    |
| length                           | The length of the subject.            |
| contents                         | The contents of the file (subject).   |
| result                           | The result of the function (subject). |

#### Matcher

status (the subject expected status)

| Matcher    | Description                   |
| :--------- | :---------------------------- |
| be success | The status should be success. |
| be failure | The status should be failure. |

stat (the subject expected file path)

| Matcher                            | Description                                 |
| :--------------------------------- | :------------------------------------------ |
| be exist                           | The file should exist.                      |
| be file                            | The file should be a file.                  |
| be directory                       | The file should be a directory.             |
| be empty file                      | The file should be an empty file.           |
| be empty directory<br>be empty dir | The directory should be an empty directory. |
| be symlink                         | The file should be a symlink.               |
| be pipe                            | The file should be a pipe.                  |
| be socket                          | The file should be a socket.                |
| be readable                        | The file should be readable.                |
| be writable                        | The file should be writable.                |
| be executable                      | The file should be executable.              |
| be block_device                    | The file should be a block device.          |
| be character_device                | The file should be a character device.      |
| has setgid                         | The file should have the `setgid` flag set. |
| has setuid                         | The file should have the `setuid` flag set. |

valid

| Matcher           | Description                             |
| :---------------- | :-------------------------------------- |
| be valid number   | The subject should be a valid number.   |
| be valid funcname | The subject should be a valid funcname. |

variable (the subject expect variable)

| Matcher      | Description                                                 |
| :----------- | :---------------------------------------------------------- |
| be defined   | The variable should be defined (set).                       |
| be undefined | The variable should be undefined (unset).                   |
| be present   | The variable should be present (non-zero length string).    |
| be blank     | The variable should be blank (unset or zero length string). |

string

| Matcher                                                             | Description                                               |
| :------------------------------------------------------------------ | :-------------------------------------------------------- |
| equal <code>&lt;STRING&gt;</code><br>eq <code>&lt;STRING&gt;</code> | The subject should equal <code>&lt;STRING&gt;</code>      |
| start with <code>&lt;STRING&gt;</code>                              | The subject should start with <code>&lt;STRING&gt;</code> |
| end with <code>&lt;STRING&gt;</code>                                | The subject should end with <code>&lt;STRING&gt;</code>   |
| include <code>&lt;STRING&gt;</code>                                 | The subject should include <code>&lt;STRING&gt;</code>    |
| match <code>&lt;PATTERN&gt;</code>                                  | The subject should match <code>&lt;PATTERN&gt;</code>     |

other

| Matcher                                              | Description                                              |
| :--------------------------------------------------- | :------------------------------------------------------- |
| satisfy <code>&lt;FUNCTION&gt; [ARGUMENTS...]</code> | The subject should satisfy <code>&lt;FUNCTION&gt;</code> |

## Helper

| DSL                                                                              | Description                                       |
| :------------------------------------------------------------------------------- | :------------------------------------------------ |
| Include <code>&lt;NAME&gt;</code>                                                | Include other files.                              |
| Before                                                                           | Define a hook called before running each example. |
| After                                                                            | Define a hook called after running each example.  |
| Path<br>File<br>Dir                                                              | Define a path alias.                              |
| Data <code>[ \| FILTER ]</code><br>#\|...<br>End                                           | Define stdin data for evaluation.                 |
| Data <code>&lt;FUNCTION&gt; [ARGUMENTS...] [ \| FILTER ]</code>                  | Use function for stdin data for evaluation.       |
| Data <code>"&lt;STRING&gt;"</code><br>Data <code>'&lt;STRING&gt;'</code>         | Use string for stdin data for evaluation.         |
| Data <code>&lt; &lt;FILE&gt; [ \| FILTER ]</code>                                | Use file for stdin data for evaluation.           |
| Skip <code>&lt;REASON&gt;</code>                                                 | Skip current block.                               |
| Skip if <code>&lt;REASON&gt;</code> <code>&lt;FUNCTION&gt; [ARGUMENTS...]</code> | Skip current block with conditional.              |
| Pending <code>&lt;REASON&gt;</code>                                              | Pending current block.                            |
| Intercept <code>[NAMES...]</code>                                                | Define an interceptor.                            |
| Set <code>[OPTION:&lt;on \| off&gt;...]</code>                                   | Set shell option before running each example.     |

## Directive

| Directive  | Description                                   |
| :--------- | :-------------------------------------------- |
| %const, %  | Define a constant variable.                   |
| %text      | Define a multiline texts to output to stdout. |
| %putsn, %= | Output arguments with the newline.            |
| %puts, %-  | Output arguments.                             |
| %logger    | Output log message.                           |

## Environment Variables

| Name                | Description                                   | Value                                                         |
| :------------------ | :-------------------------------------------- | ------------------------------------------------------------- |
| SHELLSPEC_ROOT      | shellspec root directory                      | If not specified, it is automatically detected.               |
| SHELLSPEC_LIB       | shellspec lib directory                       | `$SHELLSPEC_ROOT/lib` if not specified.                       |
| SHELLSPEC_LIBEXEC   | shellspec libexec directory                   | `$SHELLSPEC_ROOT/libexec` if not specified.                   |
| SHELLSPEC_TMPDIR    | Temporary directory used by shellspec         | `$TMPDIR` or `/tmp` if not specified.                         |
| SHELLSPEC_TMPBASE   | Current temporary directory used by shellspec | Provided by shellspec.                                        |
| SHELLSPEC_SPECDIR   | Specfiles directory                           | `spec` directory under the current directory.                 |
| SHELLSPEC_LOAD_PATH | Load path of library                          | `$SHELLSPEC_SPECDIR:$SHELLSPEC_LIB:$SHELLSPEC_LIB/formatters` |
