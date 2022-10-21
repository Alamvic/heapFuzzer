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

{ #category : #tests }
HeapFuzzerTest >> testNewCollectedObjectIsDead [

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

{ #category : #test }
HeapFuzzerTest >> testNewEventFor [

	| fuzzer fuzzing event |
	fuzzer := HeapFuzzer new.
	fuzzing := HeapFuzzing new.
	fuzzer addEventBuilder: HFNopEvent.
	
	event := fuzzer newEventFor: fuzzing.
	self assert: event class equals: HFNopEvent.
	self assert: fuzzing events isEmpty.
	
	event := fuzzing buildEvent: fuzzer.
	self assert: event class equals: HFNopEvent.
	self assert: fuzzing events size equals: 1.

]

{ #category : #tests }
HeapFuzzerTest >> testOldCollectedObjectIsDead [

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
