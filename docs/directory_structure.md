# Project directory structure

## Example directory structure and options

Separate a separate directory for each utility and test it with `test_spec.sh`.
The execution directory for testing is where the specfile is located.

```text
<PROJECT-ROOT>
├─ .shellspec
│
├─ script1/
│   ├─ script1.sh
│   └─ test_spec.sh
│
├─ script2/
│   ├─ script2.sh
│   └─ test_spec.sh
│
├─ spec/
│   ├─ spec_helper.sh
│   │        :
```

```test
# .shellspec
--default-path "**/test_spec.sh"
--execdir @specfile
````

Separate a separate directory for each utility and test it with `spec/*_spec.sh`.
The test execution directory is where the script is located.

```text
<PROJECT-ROOT>
├─ .shellspec
│
├─ script1/
│   ├─ .shellspec-basedir
│   ├─ bin/
│   │   ├─ script1.sh
│   │   │    :
│   └─ spec/
│        ├─ script1_spec.sh
│        │    :
│
├─ script2/
│   ├─ .shellspec-basedir
│   ├─ bin/
│   │   ├─ script2.sh
│   │   │    :
│   └─ spec/
│        ├─ script2_spec.sh
│        │    :
│
├─ spec/
│   ├─ spec_helper.sh
│   ├─ support/
│   │        :
```

```test
# .shellspec
--default-path "**/spec"
--execdir @basedir/bin`
````
