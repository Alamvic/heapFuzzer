Class {
	#name : #HFNopEvent,
	#superclass : #HFEvent,
	#category : #HeapFuzzer
}

{ #category : #executing }
HFNopEvent >> executeOn: aVMHeapFuzzer [ 
	
	"Nothing!"
]

{ #category : #'as yet unclassified' }
HFNopEvent >> maybeEffectiveOn: events [

	^ false
]
