"
A HeapFuzzingTest is a test class for testing the behavior of HeapFuzzing
"
Class {
	#name : #HeapFuzzingTest,
	#superclass : #TestCase,
	#category : #HeapFuzzer
}

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
