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
- [Envronment Variables](#envronment-variables)

## Example Group

You can write structured *Example* by below DSL.

| DSL              | Description                                                  |
| :--------------- | :----------------------------------------------------------- |
| Describe ... End | Define a block for Example group. Example group is nestable. |
| Context ... End  | Synonym for `Describe`.                                      |

## Example

| DSL             | Description                                                                                  |
| :-------------- | :------------------------------------------------------------------------------------------- |
| Example ... End | Define a block for Example. write your example.                                              |
| Specify ... End | Synonym for `Example`.                                                                       |
| It ... End      | Synonym for `Example`.                                                                       |
| Todo            | Same as empty example, but not a block. One-liner syntax that it means to be implementation. |

### Evaluation

The line start with `When` is the evaluation. The evaluation type follows after `When`.

| evaluation type                             | Description                                          |
| :------------------------------------------ | :--------------------------------------------------- |
| call `<FUNCTION | COMMAND> [ARGUMENTS...]`  | Call shell function or external command.             |
| invoke `<FUNCTION| COMMAND> [ARGUMENTS...]` | Call shell function or external command in subshell. |
| run `<COMMAND> [ARGUMENTS...]`              | Run external command.                                |
| execute `<SCRIPT> [ARGUMENTS...]`           | Execute shell script file.                           |

Normally you will use `call`. `invoke` is similar to `call` but execute in subshell.
`invoke` usefull for *override function in evaluation only* and trap `exit`.

### Expectation

The line start with `The` is the evaluation. The *subject* or the *modifier* follows after `The`. And last is the *matcher*.

#### Subject

| Subject                                         | Description                                   |
| :---------------------------------------------- | :-------------------------------------------- |
| output<br>stdout                                | Use the stdout of *Evaluation* as subject.    |
| error<br>stderr                                 | Use the stderr of *Evaluation* as subject.    |
| status                                          | Use the status of *Evaluation* as subject.    |
| path `<PATH>`<br> file `<PATH>`<br>dir `<PATH>` | Use the alias resolved path as the subject.   |
| value `<VALUE>`<br>function `<VALUE>`           | Use the value as the subject.                 |
| variable `<NAME>`                               | Use the value of the variable as the subject. |

#### Modifier

| Modifier        | Description                           |
| :-------------- | :------------------------------------ |
| line `<NUMBER>` | The specified line of the subject.    |
| lines           | The number of lines of the subject.   |
| word `<NUMBER>` | The specified word of the subject.    |
| length          | The length of the subject.            |
| contents        | The contents of the file (subject).   |
| result          | The result of the function (subject). |

#### Matcher

status (the subject expect status)

| Matcher    | Description                   |
| :--------- | :---------------------------- |
| be success | The status should be success. |
| be failure | The status should be failure. |

stat (the subject expect file path)

| Matcher                            | Description                                 |
| :--------------------------------- | :------------------------------------------ |
| be exist                           | The file should be exist.                   |
| be file                            | The file should be a file.                  |
| be directory                       | The file should be a directory.             |
| be empty file                      | The file should be an empty file.           |
| be empty directory<br>be empty dir | The directory should be an empty directory. |
| be symlink                         | The file should be a symlink.               |
| be pipe                            | The file should be a pipe.                  |
| be socket                          | The file should be a socket.                |
| be readable                        | The file should be a readable.              |
| be writable                        | The file should be a writable.              |
| be executable                      | The file should be an executable.           |
| be block_device                    | The file should be a block device.          |
| be charactor_device                | The file should be a charactor device.      |
| has setgid                         | The file should has setgid.                 |
| has setuid                         | The file should has setuid.                 |

valid

| Matcher           | Description                                |
| :---------------- | :----------------------------------------- |
| be valid number   | The subject should be valid as a number.   |
| be valid funcname | The subject should be valid as a funcname. |

variable (the subject expect variable)

| Matcher      | Description                                                 |
| :----------- | :---------------------------------------------------------- |
| be defined   | The variable should be defined (set).                       |
| be undefined | The variable should be undefined (unset).                   |
| be present   | The variable should be present (non-zero length string).    |
| be blank     | The variable should be blank (unset or zero length string). |

string

| Matcher                           | Description                              |
| :-------------------------------- | :--------------------------------------- |
| equal `<STRING>`<br>eq `<STRING>` | The subject should equal `<STRING>`      |
| start with `<STRING>`             | The subject should start with `<STRING>` |
| end with `<STRING>`               | The subject should end with `<STRING>`   |
| include `<STRING>`                | The subject should include `<STRING>`    |
| match `<PATTERN>`                 | The subject should match `<PATTERN>`     |

other

| Matcher                             | Description                             |
| :---------------------------------- | :-------------------------------------- |
| satisfy `<FUNCTION> [ARGUMENTS...]` | The subject should satisfy `<FUNCTION>` |

## Helper

| DSL                                            | Description                                       |
| :--------------------------------------------- | :------------------------------------------------ |
| Include `<NAME>`                               | Include other files.                              |
| Before                                         | Define a hook called before running each example. |
| After                                          | Define a hook called after running each example.  |
| Path<br>File<br>Dir                            | Define path alias.                                |
| Data `[ | FILTER ]`... End                     | Define stdin data for evaluation.                 |
| Data `<FUNCTION> [ARGUMENTS...] [ | FILTER ]`  | Use function for stdin data for evaluation.       |
| Data `"<STRING>"`<br>Data `'<STRING>'`         | Use string for stdin data for evaluation.         |
| Data `< <FILE> [ | FILTER ]`                   | Use file for stdin data for evaluation.           |
| Skip `<REASON>`                                | Skip current block.                               |
| Skip if `<REASON>` `<FUNCTION> [ARGUMENTS...]` | Skip current block with conditional.              |
| Pending `<REASON>`                             | Pending current block.                            |
| Intercept `[NAMES...]`                         | Define an interceptor.                            |
| Set `[OPTION:<on | off>...]`                   | Set shell option before running each example.     |

## Directive

| Directive  | Description                                   |
| :--------- | :-------------------------------------------- |
| %const, %  | Define a constant variable.                   |
| %text      | Define a multiline texts to output to stdout. |
| %putsn, %= | Output arguments with the newline.            |
| %puts, %-  | Output arguments.                             |
| %logger    | Output log message.                           |

## Envronment Variables

| Name                | Description                                   | Value                                                         |
| :------------------ | :-------------------------------------------- | ------------------------------------------------------------- |
| SHELLSPEC_ROOT      | shellspec root directory                      | If not specified, it detect automatically.                    |
| SHELLSPEC_LIB       | shellspec lib directory                       | `$SHELLSPEC_ROOT/lib` if not specified.                       |
| SHELLSPEC_LIBEXEC   | shellspec libexec directory                   | `$SHELLSPEC_ROOT/libexec` if not specified.                   |
| SHELLSPEC_TMPDIR    | Temporary directory used by shellspec         | `$TMPDIR` or `/tmp` if not specified.                         |
| SHELLSPEC_TMPBASE   | Current temporary directory used by shellspec | Provided by shellspec.                                        |
| SHELLSPEC_SPECDIR   | Specfiles directory                           | `spec` directory under the current directory.                 |
| SHELLSPEC_LOAD_PATH | Load path of library                          | `$SHELLSPEC_SPECDIR:$SHELLSPEC_LIB:$SHELLSPEC_LIB/formatters` |
