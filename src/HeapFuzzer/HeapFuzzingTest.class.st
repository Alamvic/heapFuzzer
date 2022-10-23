"
A HeapFuzzingTest is a test class for testing the behavior of HeapFuzzing
"
Class {
	#name : #HeapFuzzingTest,
	#superclass : #TestCase,
	#category : #HeapFuzzer
}

{ #category : #test }
HeapFuzzingTest >> testExecute [

	| fuzzing result |
	fuzzing := HeapFuzzing new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	result := fuzzing execute.
	
	self assert: result isError not
]

{ #category : #test }
HeapFuzzingTest >> testExecuteEmpty [

	| fuzzing result |
	fuzzing := HeapFuzzing new.
	result := fuzzing execute.
	
	self assert: result isError not
]

{ #category : #test }
HeapFuzzingTest >> testExecutePoison [

	| fuzzing result |
	fuzzing := HeapFuzzing new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFPoisonEvent new.
	result := fuzzing execute.
	
	self assert: result isError
]

{ #category : #tests }
HeapFuzzingTest >> testNewCollectedObjectIsDead [

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
HeapFuzzingTest >> testNewEventFor [

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
HeapFuzzingTest >> testOldCollectedObjectIsLive [

	| fuzzer allocation |
	fuzzer := HeapFuzzing new.
	allocation := HFAllocationEvent new
		objectType: #ephemeron;
		objectSize: 2;
		isNew: false;
		isRoot: true;
		yourself.
	fuzzer addEvent: allocation.
	fuzzer addEvent: HFOldSpaceCollectionEvent new.
	fuzzer basicExecute.
	
	self assert: (allocation isMaybeAliveIn: fuzzer) 
]

{ #category : #test }
HeapFuzzingTest >> testRandomAllocationEvent [

	| fuzzing evt |
	fuzzing := HeapFuzzing new.
	self assert: fuzzing randomAllocationEvent equals: nil.

	evt := fuzzing addEvent: HFNopEvent new.
	self assert: fuzzing randomAllocationEvent equals: nil.
	
	evt := fuzzing addEvent: HFAllocationEvent new.
	self assert: fuzzing randomAllocationEvent equals: evt.
]

{ #category : #test }
HeapFuzzingTest >> testReduce [

	| fuzzing reduced poison |
	fuzzing := HeapFuzzing new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	poison := fuzzing addEvent: HFPoisonEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing addEvent: HFNopEvent new.
	fuzzing execute.
	reduced := fuzzing reduce.
	
	self assert: reduced fuzzing events size equals: 1.
	self assert: reduced fuzzing events first equals: poison.
]
