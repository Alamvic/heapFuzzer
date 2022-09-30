Class {
	#name : #HeapFuzzingError,
	#superclass : #Object,
	#instVars : [
		'error',
		'fuzzing',
		'iterations'
	],
	#category : #HeapFuzzer
}

{ #category : #debugging }
HeapFuzzingError >> debug [
	
	error debug
]

{ #category : #accessing }
HeapFuzzingError >> error [

	^ error
]

{ #category : #accessing }
HeapFuzzingError >> error: anObject [

	error := anObject
]

{ #category : #accessing }
HeapFuzzingError >> events [
	
	^ fuzzing events
]

{ #category : #accessing }
HeapFuzzingError >> fuzzing [

	^ fuzzing
]

{ #category : #accessing }
HeapFuzzingError >> fuzzing: anObject [

	fuzzing := anObject
]

{ #category : #control }
HeapFuzzingError >> ifError: aFullBlockClosure [ 
	
	^ aFullBlockClosure value
]

{ #category : #testing }
HeapFuzzingError >> isError [
	
	^ true
]

{ #category : #testing }
HeapFuzzingError >> isReducible [
	
	^ fuzzing isReducible
]

{ #category : #accessing }
HeapFuzzingError >> iterations [
	^ iterations
]

{ #category : #accessing }
HeapFuzzingError >> iterations: anInteger [ 
	
	iterations := anInteger
]

{ #category : #reduction }
HeapFuzzingError >> reduce [
	
	| reducedCopy previousReducedCopy |
	reducedCopy := self.
	previousReducedCopy := nil.
	[ previousReducedCopy ~= reducedCopy ] whileTrue: [
		previousReducedCopy := reducedCopy.
		reducedCopy := reducedCopy reduceStep ].
	^ reducedCopy
]

{ #category : #reduction }
HeapFuzzingError >> reduceStep [
	
	^ fuzzing reduceStep
]
