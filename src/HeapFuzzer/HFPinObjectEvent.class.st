Class {
	#name : #HFPinObjectEvent,
	#superclass : #HFUnaryObjectEvent,
	#category : #HeapFuzzer
}

{ #category : #executing }
HFPinObjectEvent >> basicExecuteOn: aHeapFuzzer [

	| oop |
	oop := allocation oop.
	(aHeapFuzzer heap memory isForwarded: oop) ifTrue:
		[oop := aHeapFuzzer heap memory followForwarded: oop].

	aHeapFuzzer heap memory pinObject: oop.
	(aHeapFuzzer heap memory isForwarded: oop) ifTrue: [
		allocation oop: (aHeapFuzzer heap memory followForwarded: allocation oop) ]
]
