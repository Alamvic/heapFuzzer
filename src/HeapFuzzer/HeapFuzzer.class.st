Class {
	#name : #HeapFuzzer,
	#superclass : #Object,
	#category : #HeapFuzzer
}

{ #category : #fuzzing }
HeapFuzzer >> fuzz [
	
	| fuzzing |
	fuzzing := HeapFuzzing withRandomEvents.
	^ fuzzing execute.
]
