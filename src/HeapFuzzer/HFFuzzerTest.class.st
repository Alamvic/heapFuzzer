Class {
	#name : #HFFuzzerTest,
	#superclass : #TestCase,
	#category : #HeapFuzzer
}

{ #category : #tests }
HFFuzzerTest >> testEventGeneration [

	| fuzzer fuzzing |
	fuzzer := HeapFuzzer forCompaction.
	fuzzer := HeapFuzzer fullRandom.
	fuzzing := HeapFuzzing new.

	100 timesRepeat: [ fuzzing buildEvent: fuzzer ].
	self assert: fuzzing events size equals: 100. 
]

{ #category : #tests }
HFFuzzerTest >> testFuzzFor [

	| fuzzer res |
	fuzzer := HeapFuzzer new.
	fuzzer addEventBuilder: HFNopEvent.
	res := fuzzer fuzzFor: 1 milliSecond.
	self assert: res isError not.
]

{ #category : #tests }
HFFuzzerTest >> testNewCollectedObjectIsDead [

	| fuzzer allocation |
	fuzzer := HeapFuzzing new.
	allocation := HFAllocationEvent new
		objectType: #ephemeron;
		objectSize: 2;
		isNew: true;
		isRoot: false;
		yourself.
	fuzzer addEvent: allocation.
	fuzzer addEvent: HFNewSpaceCollectionEvent new.
	fuzzer basicExecute.
	
	self deny: (allocation isMaybeAliveIn: fuzzer) 
]

{ #category : #tests }
HFFuzzerTest >> testOldCollectedObjectIsDead [

	| fuzzer allocation |
	fuzzer := HeapFuzzing new.
	allocation := HFAllocationEvent new
		objectType: #ephemeron;
		objectSize: 2;
		isNew: false;
		isRoot: false;
		yourself.
	fuzzer addEvent: allocation.
	fuzzer addEvent: HFOldSpaceCollectionEvent new.
	fuzzer basicExecute.
	
	self deny: (allocation isMaybeAliveIn: fuzzer) 
]
