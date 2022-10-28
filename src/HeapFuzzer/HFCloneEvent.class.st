Class {
	#name : #HFCloneEvent,
	#superclass : #HFUnaryObjectEvent,
	#category : #HeapFuzzer
}

{ #category : #executing }
HFCloneEvent >> basicExecuteOn: aFuzzing [

	aFuzzing heap memory clone: allocation oop
]
