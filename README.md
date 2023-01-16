# HeapFuzzer

This repository presents an implementation of a lightweight test generation approach for memory managers and garbage collectors.
Directly fuzzing a memory manager allows us to control aspects such as the location where objects are allocated, and low-level events such as GC invocations and their parameters. Our solution generates large sequences of random heap events that exercise the garbage collection algorithms to generate VM crashes and find bugs. We combine fuzzing with a test reduction algorithm that finds the smaller subset of events reproducing an issue.

This approach works on top of the PharoVM (https://github.com/pharo-project/pharo-vm/).

## Basic Usage

Execute the following and inspect the results:

```smalltalk
(1 to: 100) collect: [ :i |
	| fuzzer |
	fuzzer := HeapFuzzer new.
	fuzzer fuzz ].
```


