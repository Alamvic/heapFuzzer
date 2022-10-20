Class {
	#name : #HeapFuzzingResult,
	#superclass : #Object,
	#instVars : [
		'fuzzing'
	],
	#category : #HeapFuzzer
}

{ #category : #accessing }
HeapFuzzingResult >> fuzzing [

	^ fuzzing
]

{ #category : #accessing }
HeapFuzzingResult >> fuzzing: anObject [

	fuzzing := anObject
]
