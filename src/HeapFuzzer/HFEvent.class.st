Class {
	#name : #HFEvent,
	#superclass : #Object,
	#category : #HeapFuzzer
}

{ #category : #building }
HFEvent class >> buildEventOn: aHeapFuzzer [ 
	
	^ self new
]

{ #category : #executing }
HFEvent >> executeOn: aFuzzing [

	self subclassResponsibility
]

{ #category : #testing }
HFEvent >> isAllocation [
	
	^ false
]

{ #category : #'as yet unclassified' }
HFEvent >> maybeEffectiveOn: previousEvents [

	^ true
]

{ #category : #resetting }
HFEvent >> reset [
	
	"Nothing"
]
