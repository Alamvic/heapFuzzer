Class {
	#name : #HFPinObjectEvent,
	#superclass : #HFUnaryObjectEvent,
	#category : #HeapFuzzer
}

{ #category : #executing }
HFPinObjectEvent >> basicExecuteOn: aHeapFuzzer [

	aHeapFuzzer heap memory pinObject: allocation oop.
	(aHeapFuzzer heap memory isForwarded: allocation oop) ifTrue: [
		allocation oop: (aHeapFuzzer heap memory followForwarded: allocation oop) ]
]
