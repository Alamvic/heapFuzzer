Class {
	#name : #HFCloneEvent,
	#superclass : #HFUnaryObjectEvent,
	#category : #HeapFuzzer
}

{ #category : #executing }
HFCloneEvent >> basicExecuteOn: aFuzzing [

	| oop |
	oop := allocation oop.
	(aFuzzing heap memory isForwarded: oop) ifTrue:
		[oop := aFuzzing heap memory followForwarded: oop].

	aFuzzing heap memory clone: oop
]
