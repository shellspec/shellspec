# Reporter

## Reporting protocol

```
| pair   | type      | number of times                 |
| ------ | --------- | ------------------------------- |
|        | meta      | 1                               |
| +----- | begin     | 0..N (number of specfiles)      |
| :  +-- | example   | 0..N                            |
| :  :   | statement | 0..N                            |
| :  +-- | result    | same number of times as example |
| +----- | end       | same number of times as begin   |
|        | finished  | 1                               |
```

### types

| type      | fields                                                       |
| --------- | ------------------------------------------------------------ |
| meta      | shell, shell_type, shell_version                             |
| begin     | specfile                                                     |
| example   | id, block_no, example_no, focused, description, lineno_range |
| statement | tag, lineno                                                  |
| result    |                                                              |
| end       |                                                              |
| finished  |                                                              |

### statement type

| tag        | fields                                      |
| ---------- | ------------------------------------------- |
| evaluation | note, fail:,  evaluation                    |
| good       | note, fail:,  message                       |
| bad        | note, fail:y, message, failure_message      |
| warn       | note, fail:?, message, failure_message      |
| skip       | note, fail:,  message, skipid, temporary:?  |
| pending    | note, fail:,  message, pending, temporary:? |

### result type

| tag       | fields                              |
| --------- | ----------------------------------- |
| succeeded | note, fail: , quick:                |
| failed    | note, fail:y, quick:y               |
| warned    | note, fail:?, quick:?               |
| todo      | note, fail: , quick:?, temporary:?, |
| fixed     | note, fail:y, quick:?, temporary:?, |
| skipped   | note, fail: , quick: , temporary:?, |

- warned
  - fail: 'y' if enabled warning-as-failure, otherwise empty
  - quick: 'y' if enabled warning-as-failure, otherwise empty
- todo
  - temporary: 'y' if pending statement is temporary, otherwise empty
  - quick: 'y' if it is temporary
- fixed
  - temporary: 'y' if pending statement is temporary, otherwise empty
  - quick: 'y' if it is temporary
- skipped
  - temporary: 'y' if pending statement is temporary, otherwise empty
