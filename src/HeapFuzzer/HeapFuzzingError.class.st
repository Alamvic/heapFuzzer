Class {
	#name : #HeapFuzzingError,
	#superclass : #HeapFuzzingResult,
	#instVars : [
		'error',
		'iterations',
		'timestamp'
	],
	#category : #HeapFuzzer
}

{ #category : #'ston-core' }
HeapFuzzingError class >> stonAllInstVarNames [
	"Override to encode my instances using a custom set of instance variables or to define their order."
	
	^ self allInstVarNames copyWithout: 'error'
]

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

{ #category : #control }
HeapFuzzingError >> ifError: aFullBlockClosure [ 
	
	^ aFullBlockClosure value
]

{ #category : #testing }
HeapFuzzingError >> initialize [

	super initialize.
	timestamp := DateAndTime now
]

{ #category : #classification }
HeapFuzzingError >> interestingContextForException: anException [

	| context |
	context := anException signalContext.
	[ context isNotNil ] whileTrue: [ 
		(self isInterestingPackage: context methodClass package name) 
			ifTrue: [ ^ context ].
		context := context sender ].
	^ nil
]

{ #category : #testing }
HeapFuzzingError >> isError [
	
	^ true
]

{ #category : #classification }
HeapFuzzingError >> isInterestingPackage: packageName [

	^ packageName = #VMMaker
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

{ #category : #classification }
HeapFuzzingError >> label [

	| context |
	context := self interestingContextForException: error.
	^ self labelForContext: context
]

{ #category : #classification }
HeapFuzzingError >> labelForContext: context [

	context ifNil: [ ^ nil ].

	^ { 
		  context selector.
		  context sender selector.
		  context sender sender selector.
		  context sender sender sender selector } joinUsing: '<'
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
