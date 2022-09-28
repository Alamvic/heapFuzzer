Class {
	#name : #HeapFuzzer,
	#superclass : #Object,
	#category : #'HeapFuzzer-Core'
}

{ #category : #fuzzing }
HeapFuzzer >> fuzz [
	
	| fuzzing |
	fuzzing := HeapFuzzing withRandomEvents.
	^ fuzzing execute.
]
