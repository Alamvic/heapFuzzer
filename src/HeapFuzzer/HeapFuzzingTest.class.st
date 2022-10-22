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
