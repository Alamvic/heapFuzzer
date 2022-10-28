Class {
	#name : #HFNextInstanceEvent,
	#superclass : #HFUnaryObjectEvent,
	#category : #HeapFuzzer
}

{ #category : #executing }
HFNextInstanceEvent >> basicExecuteOn: aFuzzing [

	| result |
	result := aFuzzing heap memory instanceAfter: allocation oop.
	result ifNil: [ ^self].
	"aFuzzing heap memory checkOkayOop: result."
]
