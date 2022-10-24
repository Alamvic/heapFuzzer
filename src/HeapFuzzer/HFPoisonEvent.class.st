Class {
	#name : #HFPoisonEvent,
	#superclass : #HFEvent,
	#category : #HeapFuzzer
}

{ #category : #executing }
HFPoisonEvent >> executeOn: aFuzzing [

	aFuzzing heap memory pinObject: -1. "This should always fail"
]
