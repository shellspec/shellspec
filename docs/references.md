# References

- [Basic structure](#basic-structure)
  - [Example group](#example-group)
    - [`ExampleGroup` / `Describe` / `Context`](#examplegroup--describe--context)
  - [Example](#example)
    - [`Example` / `It` / `Specify`](#example--it--specify)
  - [Evaluation](#evaluation)
    - [`When call`](#when-call)
    - [`When run`](#when-run)
      - [about calling shell function with run](#about-calling-shell-function-with-run)
    - [`When run command`](#when-run-command)
    - [`When run script`](#when-run-script)
    - [`When run source`](#when-run-source)
    - [Comparison](#comparison)
  - [Expectation](#expectation)
    - [`The` ... `should (not)`](#the--should-not)
    - [`Assert`](#assert)
  - [Subjects](#subjects)
    - [`stdout` (`output`) subject](#stdout-output-subject)
    - [`stderr` (`error`) subject](#stderr-error-subject)
    - [`status` subject](#status-subject)
    - [`line` subject](#line-subject)
    - [`word` subject](#word-subject)
    - [`path` / `file` / `directory` subject](#path--file--directory-subject)
    - [`function` subject](#function-subject)
    - [`value` subject](#value-subject)
    - [`variable` subject](#variable-subject)
  - [Modifiers](#modifiers)
    - [`line` modifier](#line-modifier)
    - [`lines` modifier](#lines-modifier)
    - [`word` modifier](#word-modifier)
    - [`length` modifier](#length-modifier)
    - [`contents` modifier](#contents-modifier)
    - [`result` modifier](#result-modifier)
  - [Matchers](#matchers)
    - [`satisfy` matcher](#satisfy-matcher)
    - [stat matchers](#stat-matchers)
      - [`be exist` matcher](#be-exist-matcher)
      - [`be file` matcher](#be-file-matcher)
      - [`be directory` matcher](#be-directory-matcher)
      - [`be empty file` matcher](#be-empty-file-matcher)
      - [`be empty directory` matcher](#be-empty-directory-matcher)
      - [`be symlink` matcher](#be-symlink-matcher)
      - [`be pipe` matcher](#be-pipe-matcher)
      - [`be socket` matcher](#be-socket-matcher)
      - [`be readable` matcher](#be-readable-matcher)
      - [`be writable` matcher](#be-writable-matcher)
      - [`be executable` matcher](#be-executable-matcher)
      - [`be block_device` matcher](#be-block_device-matcher)
      - [`be character_device` matcher](#be-character_device-matcher)
      - [`has setgid` matcher](#has-setgid-matcher)
      - [`has setuid` matcher](#has-setuid-matcher)
    - [status matchers](#status-matchers)
      - [`be success` matcher](#be-success-matcher)
      - [`be failure` matcher](#be-failure-matcher)
    - [string matchers](#string-matchers)
      - [`equal` matcher](#equal-matcher)
      - [`start with` matcher](#start-with-matcher)
      - [`end with` matcher](#end-with-matcher)
      - [`include` matcher](#include-matcher)
      - [`match pattern` matcher](#match-pattern-matcher)
    - [`successful` matcher](#successful-matcher)
    - [valid matchers](#valid-matchers)
    - [variable matchers](#variable-matchers)
      - [`be defined` matcher](#be-defined-matcher)
      - [`be undefined` matcher](#be-undefined-matcher)
      - [`be present` matcher](#be-present-matcher)
      - [`be blank` matcher](#be-blank-matcher)
      - [`be exported` matcher](#be-exported-matcher)
      - [`be readonly` matcher](#be-readonly-matcher)
- [Helper](#helper)
  - [Skip / Pending](#skip--pending)
    - [`Skip`](#skip)
    - [`Skip if`](#skip-if)
    - [`Pending`](#pending)
    - [`Todo`](#todo)
  - [Data](#data)
    - [`Data[:raw]`](#dataraw)
    - [`Data:expand`](#dataexpand)
    - [`Data <FUNCTION>`](#data-function)
    - [`Data "<STRING>"`](#data-string)
    - [`Data < "<FILE>"`](#data--file)
  - [Parameters](#parameters)
    - [`Parameters[:block]`](#parametersblock)
    - [`Parameters:value`](#parametersvalue)
    - [`Parameters:matrix`](#parametersmatrix)
    - [`Parameters:dynamic`](#parametersdynamic)
  - [Others](#others)
    - [`Include`](#include)
    - [`Path` / `File` / `Dir`](#path--file--dir)
    - [`Intercept`](#intercept)
    - [`Set`](#set)
    - [`Dump`](#dump)
- [Hooks](#hooks)
  - [`Before` / `After`](#before--after)
  - [`BeforeAll` / `AfterAll`](#beforeall--afterall)
  - [`BeforeCall` / `AfterCall`](#beforecall--aftercall)
  - [`BeforeRun` / `AfterRun`](#beforerun--afterrun)
- [Directive](#directive)
  - [`%const` (`%`)](#const-)
  - [`%text`](#text)
  - [`%puts` (`%-`) / `%putsn` (`%=`)](#puts----putsn-)
  - [%preserve](#preserve)
  - [`%logger`](#logger)
- [Special environment Variables](#special-environment-variables)

## Basic structure

You can write a structured *Example* by using the DSL shown below:

### Example group

| DSL                  | Description                 |
| :------------------- | :-------------------------- |
| ExampleGroup ... End | Define a example group.     |
| Describe ... End     | Synonym for `ExampleGroup`. |
| Context ... End      | Synonym for `ExampleGroup`. |

#### `ExampleGroup` / `Describe` / `Context`

Examples groups are nestable.

### Example

| DSL             | Description            |
| :-------------- | :--------------------- |
| Example ... End | Define a example.      |
| It ... End      | Synonym for `Example`. |
| Specify ... End | Synonym for `Example`. |

#### `Example` / `It` / `Specify`

### Evaluation

The line beginning with `When` is the evaluation.

| Evaluation       | Description                                                          |
| :--------------- | :------------------------------------------------------------------- |
| When call        | Call shell function without subshell.                                |
| When run         | Run shell function (within subshell) or external command.            |
| When run command | Run external command (including non-shell scripts).                  |
| When run script  | Run shell script by new process of the current shell.                |
| When run source  | Run shell script in the current shell by `.` command (aka `source`). |

#### `When call`

```sh
When call <FUNCTION> [ARGUMENTS...]
```

This is primarily designed for shell function calls. It is the recommended evaluation as a unit test.
It does not use a subshell, therefore most fast and and you can assert variables.

#### `When run`

```sh
When run <FUNCTION | COMMAND> [ARGUMENTS...]
```

This is primarily designed for external command calls.
The external command does not have to be a shell script.
Even shell scripts are executed as external commands according to the shebang, so they are not covered by coverage.

##### about calling shell function with run

If a shell function is specified, it will be executed in a subshell. The slight advantage of
executing shell functions with `run` is that you can trap errors with `set -e`.
Unlike `call`, it does not cause an error, so you can use assert the exit status.

Also, Because executed in in the subshell, the variable changed is restored.
This is often a disadvantage, but ShellSpec's itself tests intentionally use `run`
because changing internal variables confuse ShellSpec behavior.

If you want to assert variables with `run`, use the `%preserve` directive in function called by `AfterRun` hook.
It can preserve variables even if it exits the subshell.

#### `When run command`

```sh
When run command <COMMAND> [ARGUMENTS...]
```

Run an external command explicitly.
The external command does not have to be a shell script.
Even shell scripts are executed as external commands according to the shebang, so they are not covered by coverage.

#### `When run script`

```sh
When run script <SCRIPT> [ARGUMENTS...]
```

Run the external shell script in the same shell as the currently running shell.

#### `When run source`

```sh
When run source <SCRIPT> [ARGUMENTS...]
```

This is similar to the `run script`, but simulate the running of shell
script with `.` command instead of running directly.

The advantage over `run script` is that you can use `Intercept` to intercept
at any point in the external shell script.
This is useful for preparation testing and mocking with shell functions.

#### Comparison

|                    | `call`                 | `run`                | `run command`        | `run script`         | `run source`         |
| ------------------ | ---------------------- | -------------------- | -------------------- | -------------------- | -------------------- |
| Run in subshell    | No                     | Yes                  | Yes                  | Yes                  | Yes                  |
| Target             | function               | function / command   | command              | shell script         | shell script         |
| Stop with `set -e` | No                     | Yes                  | -                    | Yes                  | Yes                  |
| Catch `exit`       | No                     | Yes                  | -                    | Yes                  | Yes                  |
| Expectation Hooks  | BeforeCall / AfterCall | BeforeRun / AfterRun | BeforeRun / AfterRun | BeforeRun / AfterRun | BeforeRun / AfterRun |
| Intercept          | No                     | No                   | -                    | No                   | Yes                  |
| Coverage           | Yes                    | Yes (function only)  | No                   | Yes                  | Yes                  |

### Expectation

#### `The` ... `should (not)`

The line beginning with `The` is the evaluation. The *subject* or the *modifier* follows after `The`. And last is the *matcher*.

```sh
The [MODIFIER of...] <SUBJECT> should <MATCHER>
The [MODIFIER of...] <SUBJECT> should not <MATCHER>
```

#### `Assert`

```sh
Assert <FUNCTION> [ARGUMENTS...]
```

### Subjects

| Subject                 | Description                                   |
| :---------------------- | :-------------------------------------------- |
| stdout / output         | Use the stdout of *Evaluation* as subject.    |
| line                    | Same as `line NUMBER of stdout`.              |
| word                    | Same as `word NUMBER of stdout`.              |
| stderr / error          | Use the stderr of *Evaluation* as subject.    |
| status                  | Use the status of *Evaluation* as subject.    |
| path / file / directory | Use the alias resolved path as the subject.   |
| value                   | Use the value as the subject.                 |
| function                | Use the function name as the subject.         |
| variable                | Use the value of the variable as the subject. |

#### `stdout` (`output`) subject

```sh
The stdout should equal "foo"
The output should equal "foo"
```

#### `stderr` (`error`) subject

```sh
The stderr should equal "foo"
The error should equal "foo"
```

#### `status` subject

```sh
The status should be success
```

#### `line` subject

When combined with line, `stdout` can be omitted.

```sh
The line 1 of stdout should equal foo
The line 1 should equal foo # stdout omitted
```

#### `word` subject

When combined with word, `stdout` can be omitted.

```sh
The line 1 of stdout should equal foo
The line 1 should equal foo # stdout omitted
```

#### `path` / `file` / `directory` subject

```sh
Path data-file /tmp/data.txt
The path data-file should be exist
```

#### `function` subject

```sh
The result of function foo should be successful
The result of "foo()" should be successful # shorthand
```

#### `value` subject

```sh
The value "foo" should equal "foo"
```

I do not recommend using this subject as it will may generate not clear
failure messages. Use the `variable` subject instead.

#### `variable` subject

```sh
The variable var should equal "foo"
```

### Modifiers

| Modifier | Description                            |
| :------- | :------------------------------------- |
| line     | The specified line of the subject.     |
| lines    | The number of lines of the subject.    |
| word     | The specified word of the subject.     |
| length   | The length of the subject.             |
| contents | The contents of the file as subject.   |
| result   | The result of the function as subject. |

#### `line` modifier

```sh
The line 1 of stdout should equal "line1"
```

#### `lines` modifier

```sh
The lines of stdout should equal 5
```

#### `word` modifier

```sh
The word 2 of stdout should equal "word2"
```

#### `length` modifier

```sh
The length of value "abcd" should equal 5
```

#### `contents` modifier

```sh
The contents of file "/tmp/file.txt" should equal "temp data"
```

#### `result` modifier

```sh
get_version() {
  # The result of the evaluation is passed as arguments
  # $1: stdout, $2: stderr, $3: status
  echo "$1" | grep -o '[0-9.]*' | head -1
}

When call echo "GNU bash, version 4.4.20(1)-release (x86_64-pc-linux-gnu)"
The result of function get_version should equal "4.4.20"
The result of "get_version()" should equal "4.4.20" # shorthand
```

```sh
check_version() {
  # The result of the evaluation is passed as arguments
  # $1: stdout, $2: stderr, $3: status
  [ "$("$1" | grep -o '[0-9.]*' | head -1)" = "4.4.20" ]
}

When call echo "GNU bash, version 4.4.20(1)-release (x86_64-pc-linux-gnu)"
The result of function check_version should be successful
The result of "check_version()" should be successful # shorthand
```

### Matchers

#### `satisfy` matcher

| Matcher | Description                                              |
| :------ | :------------------------------------------------------- |
| satisfy | The subject should satisfy <code>&lt;FUNCTION&gt;</code> |

```sh
satisfy <FUNCTION> [ARGUMENTS...]
```

satisfy examples

```sh
value() {
  # The subject is stored in the same variable name as the function name
  test "${value:?}" "$1" "$2"
}

formula() {
  value=${formula:?}
  [ $(($1)) -eq 1 ]
}

When call echo "50"
The output should satisfy value -gt 10
The output should satisfy formula "10 <= value && value <= 100"
```

#### stat matchers

the subject expected file path

| Matcher             | Description                                 |
| :------------------ | :------------------------------------------ |
| be exist            | The file should exist.                      |
| be file             | The file should be a file.                  |
| be directory        | The file should be a directory.             |
| be empty file       | The file should be an empty file.           |
| be empty directory  | The directory should be an empty directory. |
| be symlink          | The file should be a symlink.               |
| be pipe             | The file should be a pipe.                  |
| be socket           | The file should be a socket.                |
| be readable         | The file should be readable.                |
| be writable         | The file should be writable.                |
| be executable       | The file should be executable.              |
| be block_device     | The file should be a block device.          |
| be character_device | The file should be a character device.      |
| has setgid          | The file should have the setgid flag set.   |
| has setuid          | The file should have the setuid flag set.   |

##### `be exist` matcher

```sh
The path /target/path should be exist
```

##### `be file` matcher

```sh
The path /target/path should be file
```

##### `be directory` matcher

```sh
The path /target/path should be directory
The path /target/path should be dir
```

##### `be empty file` matcher

```sh
The path /target/path should be empty file
```

##### `be empty directory` matcher

```sh
The path /target/path should be empty directory
The path /target/path should be empty dir
```

##### `be symlink` matcher

```sh
The path /target/path should be symlink
```

##### `be pipe` matcher

```sh
The path /target/path should be pipe
```

##### `be socket` matcher

```sh
The path /target/path should be socket
```

##### `be readable` matcher

```sh
The path /target/path should be readable
```

##### `be writable` matcher

```sh
The path /target/path should be writable
```

##### `be executable` matcher

```sh
The path /target/path should be executable
```

##### `be block_device` matcher

```sh
The path /target/path should be block_device
```

##### `be character_device` matcher

```sh
The path /target/path should be character_device
```

##### `has setgid` matcher

```sh
The path /target/path should has setgid
```

##### `has setuid` matcher

```sh
The path /target/path should has setuid
```

#### status matchers

the subject expected status

| Matcher    | Description                                 |
| :--------- | :------------------------------------------ |
| be success | The status should be success (`0`).         |
| be failure | The status should be failure (`1` - `255`). |

##### `be success` matcher

```sh
The status should be success
```

##### `be failure` matcher

```sh
The status should be failure
```

#### string matchers

| Matcher                                                             | Description                                                   |
| :------------------------------------------------------------------ | :------------------------------------------------------------ |
| equal <code>&lt;STRING&gt;</code><br>eq <code>&lt;STRING&gt;</code> | The subject should equal <code>&lt;STRING&gt;</code>          |
| start with <code>&lt;STRING&gt;</code>                              | The subject should start with <code>&lt;STRING&gt;</code>     |
| end with <code>&lt;STRING&gt;</code>                                | The subject should end with <code>&lt;STRING&gt;</code>       |
| include <code>&lt;STRING&gt;</code>                                 | The subject should include <code>&lt;STRING&gt;</code>        |
| match pattern <code>&lt;PATTERN&gt;</code>                          | The subject should match pattern <code>&lt;PATTERN&gt;</code> |

##### `equal` matcher

```sh
The outout should equal <STRING>
The outout should eq <STRING>
```

##### `start with` matcher

```sh
The outout should start with <STRING>
```

##### `end with` matcher

```sh
The outout should end with <STRING>
```

##### `include` matcher

```sh
The outout should include <STRING>
```

##### `match pattern` matcher

```sh
The outout should match pattern <PATTERN>
```

PATTERN examples

- `foo*`
- `foo?`
- `[fF]oo`
- `[!F]oo`
- `[a-z]`
- `foo|bar`

#### `successful` matcher

Use with [result](#result) modifier.

#### valid matchers

**Plan to deprecate in the future.**

| Matcher           | Description                             |
| :---------------- | :-------------------------------------- |
| be valid number   | The subject should be a valid number.   |
| be valid funcname | The subject should be a valid funcname. |

#### variable matchers

the subject expect variable

| Matcher      | Description                                                 |
| :----------- | :---------------------------------------------------------- |
| be defined   | The variable should be defined (set).                       |
| be undefined | The variable should be undefined (unset).                   |
| be present   | The variable should be present (non-zero length string).    |
| be blank     | The variable should be blank (unset or zero length string). |
| be exported  | The variable should be exported.                            |
| be readonly  | The variable should be readonly.                            |

##### `be defined` matcher

```sh
The variable VAR should be defined
```

##### `be undefined` matcher

```sh
The variable VAR should be undefined
```

##### `be present` matcher

```sh
The variable VAR should be present
```

##### `be blank` matcher

```sh
The variable VAR should be blank
```

##### `be exported` matcher

```sh
The variable VAR should be exported
```

##### `be readonly` matcher

```sh
The variable VAR should be readonly
```

## Helper

### Skip / Pending

| DSL                                                                              | Description                          |
| :------------------------------------------------------------------------------- | :----------------------------------- |
| Skip <code>&lt;REASON&gt;</code>                                                 | Skip current block.                  |
| Skip if <code>&lt;REASON&gt;</code> <code>&lt;FUNCTION&gt; [ARGUMENTS...]</code> | Skip current block with conditional. |
| Pending <code>&lt;REASON&gt;</code>                                              | Pending current block.               |
| Todo                                                                             | Define pending example               |

#### `Skip`

#### `Skip if`

#### `Pending`

#### `Todo`

### Data

| DSL                                                                      | Description                                                  |
| :----------------------------------------------------------------------- | :----------------------------------------------------------- |
| Data[:raw]<br>#\|...<br>End                                              | Define stdin data for evaluation (without expand variables). |
| Data:expand<br>#\|...<br>End                                             | Define stdin data for evaluation (with expand variables).    |
| Data <code>&lt;FUNCTION&gt; [ARGUMENTS...]</code>                        | Use function for stdin data for evaluation.                  |
| Data <code>"&lt;STRING&gt;"</code><br>Data <code>'&lt;STRING&gt;'</code> | Use string for stdin data for evaluation.                    |
| Data <code>&lt; &lt;FILE&gt;</code>                                      | Use file for stdin data for evaluation.                      |

NOTE: The `Data` helper can also be used with filters.

```sh
Data | tr 'abc' 'ABC' # comment
#|aaa
#|bbb
#|ccc
End
```

#### `Data[:raw]`

```sh
Describe 'Data helper'
  Example 'provide with Data helper block style'
    Data
      #|item1 123
      #|item2 456
      #|item3 789
    End
    When call awk '{total+=$2} END{print total}'
    The output should eq 1368
  End
End
```

#### `Data:expand`

#### `Data <FUNCTION>`

#### `Data "<STRING>"`

#### `Data < "<FILE>"`

### Parameters

| DSL                                       | Description                       |
| :---------------------------------------- | :-------------------------------- |
| Parameters ... End                        | Define parameters (block style)   |
| Parameters:block ... End                  | Same as Parameters                |
| Parameters:value <code>[VALUES...]</code> | Define parameters (value style)   |
| Parameters:matrix ... End                 | Define parameters (matrix style)  |
| Parameters:dynamic ... End                | Define parameters (dynamic style) |

NOTE: Multiple `Parameters` definitions are merged.

#### `Parameters[:block]`

```sh
Describe 'example'
  Parameters
    "#1" 1 2 3
    "#2" 1 2 3
  End

  Example "example $1"
    When call echo "$(($2 + $3))"
    The output should eq "$4"
  End
End
```

#### `Parameters:value`

```sh
Parameters:value foo bar baz
```

#### `Parameters:matrix`

```sh
Parameters:matrix
  foo bar
  1 2

  # expanded as follows
  #   foo 1
  #   foo 2
  #   bar 1
  #   bar 2
End
```

#### `Parameters:dynamic`

```sh
Parameters:dynamic
  for i in 1 2 3; do
    %data "#$i" 1 2 3
  done
End
```

Only %data directive can be used within Parameters:dynamic block.
You can not call function or accessing variable defined within specfile.
You can refer to variables defined with %const.

### Others

| DSL                                            | Description                                   |
| :--------------------------------------------- | :-------------------------------------------- |
| Include <code>&lt;NAME&gt;</code>              | Include other files.                          |
| Path<br>File<br>Dir                            | Define a path alias.                          |
| Intercept <code>[NAMES...]</code>              | Define an interceptor.                        |
| Set <code>[OPTION:&lt;on \| off&gt;...]</code> | Set shell option before running each example. |
| Dump                                           | Dump stdout, stderr and status for debugging. |

#### `Include`

#### `Path` / `File` / `Dir`

#### `Intercept`

#### `Set`

#### `Dump`

## Hooks

| DSL        | Description                                       |
| :--------- | :------------------------------------------------ |
| Before     | Define a hook called before running each example. |
| After      | Define a hook called after running each example.  |
| BeforeAll  |                                                   |
| AfterAll   |                                                   |
| BeforeCall |                                                   |
| AfterCall  |                                                   |
| BeforeRun  |                                                   |
| AfterRun   |                                                   |

### `Before` / `After`

### `BeforeAll` / `AfterAll`

### `BeforeCall` / `AfterCall`

### `BeforeRun` / `AfterRun`

## Directive

| Directive  | Description                                   |
| :--------- | :-------------------------------------------- |
| %const, %  | Define a constant variable.                   |
| %text      | Define a multiline texts to output to stdout. |
| %putsn, %= | Output arguments with the newline.            |
| %puts, %-  | Output arguments.                             |
| %logger    | Output log message.                           |

### `%const` (`%`)

```sh
% <VERNAME>: "<VALUE>"
```

### `%text`

### `%puts` (`%-`) / `%putsn` (`%=`)

### %preserve

Use this with the `When run` evaluation.

### `%logger`

## Special environment Variables

ShellSpec provides special environment variables with prefix `SHELLSPEC_`.
They are useful for writing tests and extensions.
I will not change it as much as possible for compatibility, but currently not guaranteed.
There are many undocumented variables. You can use them at your own risk.

These variables can be overridden by `--env-from` option except for some variables.
This is an assumed usage, but has not been fully tested.

| Name                 | Description                              | Value                                                               |
| :------------------- | :--------------------------------------- | ------------------------------------------------------------------- |
| SHELLSPEC_ROOT       | ShellSpec root directory                 |                                                                     |
| SHELLSPEC_LIB        | ShellSpec lib directory                  | `${SHELLSPEC_ROOT}/lib`                                             |
| SHELLSPEC_LIBEXEC    | ShellSpec libexec directory              | `${SHELLSPEC_ROOT}/libexec`                                         |
| SHELLSPEC_TMPDIR     | Temporary directory                      | `${TMPDIR}` or `/tmp` if not specified.                             |
| SHELLSPEC_TMPBASE    | Temporary directory used by ShellSpec    | `${SHELLSPEC_TMPDIR}/shellspec.${SHELLSPEC_UNIXTIME}.$$`.           |
| SHELLSPEC_WORKDIR    | Temporary directory for each spec number | `${SHELLSPEC_TMPBASE}/${SHELLSPEC_SPEC_NO}`.                        |
| SHELLSPEC_SPECDIR    | Specfiles directory                      | `${PWD}/spec`                                                       |
| SHELLSPEC_LOAD_PATH  | Load path of library                     | `${SHELLSPEC_SPECDIR}:${SHELLSPEC_LIB}:${SHELLSPEC_LIB}/formatters` |
| SHELLSPEC_UNIXTIME   | Unix Time when ShellSpec starts          |                                                                     |
| SHELLSPEC_SPEC_NO    | Current specfile number                  |                                                                     |
| SHELLSPEC_GROUP_ID   | Current group ID                         | e.g. `1-2`                                                          |
| SHELLSPEC_EXAMPLE_ID | Current example ID (including group ID)  | e.g. `1-2-3`                                                        |
| SHELLSPEC_EXAMPLE_NO | Current serial number of example         |                                                                     |
