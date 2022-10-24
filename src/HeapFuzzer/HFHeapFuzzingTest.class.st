Class {
	#name : #HFHeapFuzzingTest,
	#superclass : #TestCase,
	#category : #HeapFuzzer
}

{ #category : #factory }
HFHeapFuzzingTest >> fuzzingWithEvents: events [

	| fuzzing |
	fuzzing := HeapFuzzing new.
	events do: [ :event | fuzzing addEvent: event ].
	^ fuzzing
]

{ #category : #factory }
HFHeapFuzzingTest >> pinNilErrorEvent [

	^ HFMockEvent newExecuting: [ :fuzzer | "Throw error in the VM context" 
		  fuzzer heap memory pinObject: nil ]
]

{ #category : #factory }
HFHeapFuzzingTest >> storePointerNilErrorEvent [

	^ HFMockEvent newExecuting: [ :fuzzer | "Throw error in the VM context" 
		  fuzzer heap memory storePointer: nil ofObject: nil withValue: nil ]
]

{ #category : #tests }
HFHeapFuzzingTest >> testFuzzingErrorLabel [

	| fuzzing result |
	fuzzing := self fuzzingWithEvents: { self storePointerNilErrorEvent }.
	result := fuzzing execute.

	self assert: result label equals: 'long64At:<longAt:<isForwarded:<storePointer:ofObject:withValue:'
]

{ #category : #tests }
HFHeapFuzzingTest >> testNewCollectedObjectIsDead [

	| fuzzer allocation |
	fuzzer := HeapFuzzing new.
	allocation := HFAllocationEvent new
		objectType: #ephemeron;
		objectSize: 2;
		isNew: true;
		isRoot: false;
		yourself.
	fuzzer addAllocation: allocation.
	fuzzer addEvent: allocation.
	fuzzer addEvent: HFNewSpaceCollectionEvent new.
	fuzzer basicExecute.
	
	self deny: (allocation isMaybeAliveIn: fuzzer) 
]

{ #category : #tests }
HFHeapFuzzingTest >> testOldCollectedObjectIsDead [

	| fuzzer allocation |
	fuzzer := HeapFuzzing new.
	allocation := HFAllocationEvent new
		objectType: #ephemeron;
		objectSize: 2;
		isNew: false;
		isRoot: false;
		yourself.
	fuzzer addAllocation: allocation.
	fuzzer addEvent: allocation.
	fuzzer addEvent: HFOldSpaceCollectionEvent new.
	fuzzer basicExecute.
	
	self deny: (allocation isMaybeAliveIn: fuzzer) 
]

{ #category : #tests }
HFHeapFuzzingTest >> testReduceFuzzingEventsToError [

	| fuzzing result reducedFuzzer |
	fuzzing := self fuzzingWithEvents: { 
			           HFNopEvent new.
			           HFNopEvent new.
			           self storePointerNilErrorEvent }.
	result := fuzzing execute.
	reducedFuzzer := result reduce.

	self assert: reducedFuzzer events size equals: 1.
	self assert: reducedFuzzer execute isError
]

{ #category : #tests }
HFHeapFuzzingTest >> testReduceFuzzingEventsToHitFirstError [

	| fuzzing result reducedFuzzer |
	fuzzing := self fuzzingWithEvents: { 
			           self storePointerNilErrorEvent.
			           self pinNilErrorEvent }.
	result := fuzzing execute.
	reducedFuzzer := result reduce.


	self assert: reducedFuzzer events size equals: 1.
	self assert: (reducedFuzzer execute label includesSubstring: 'storePointer:ofObject:withValue:')
]

{ #category : #tests }
HFHeapFuzzingTest >> testReduceFuzzingEventsToSameError [

	| fuzzing result reducedFuzzer |
	fuzzing := self fuzzingWithEvents: { 
			           self storePointerNilErrorEvent.
			           self storePointerNilErrorEvent.
			           self storePointerNilErrorEvent }.
	result := fuzzing execute.
	reducedFuzzer := result reduce.

	self assert: reducedFuzzer events size equals: 1
]
