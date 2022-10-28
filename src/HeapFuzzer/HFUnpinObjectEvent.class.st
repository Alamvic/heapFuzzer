Class {
	#name : #HFUnpinObjectEvent,
	#superclass : #HFUnaryObjectEvent,
	#category : #HeapFuzzer
}

{ #category : #executing }
HFUnpinObjectEvent >> basicExecuteOn: aFuzzing [

	aFuzzing heap memory unpinObject: allocation oop
]
