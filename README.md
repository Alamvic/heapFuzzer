# HeapFuzzer

```smalltalk
(1 to: 100) collect: [ :i |
	| fuzzer |
	fuzzer := HeapFuzzer new.
	fuzzer fuzz ].
```
