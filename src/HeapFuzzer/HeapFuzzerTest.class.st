Class {
	#name : #HeapFuzzerTest,
	#superclass : #TestCase,
	#category : #HeapFuzzer
}

{ #category : #test }
HeapFuzzerTest >> testAddEventBuilder [

	| fuzzer |
	fuzzer := HeapFuzzer new.
	self assert: fuzzer eventBuilders isEmpty.
	fuzzer addEventBuilder: HFNopEvent.
	self assert: fuzzer eventBuilders size equals: 1.
	fuzzer addEventBuilder: HFNopEvent frequency: 10.
	self assert: fuzzer eventBuilders size equals: 11.

]

{ #category : #tests }
HeapFuzzerTest >> testEventGeneration [

	| fuzzer fuzzing |
	fuzzer := HeapFuzzer forCompaction.
	fuzzer := HeapFuzzer fullRandom.
	fuzzing := HeapFuzzing new.

	100 timesRepeat: [ fuzzing buildEvent: fuzzer ].
	self assert: fuzzing events size equals: 100. 
]

{ #category : #tests }
HeapFuzzerTest >> testFuzzFor [

	| fuzzer res |
	fuzzer := HeapFuzzer new.
	fuzzer addEventBuilder: HFNopEvent.
	res := fuzzer fuzzFor: 1 milliSecond.
	self assert: res isError not.
]
