Class {
	#name : #HFEvent,
	#superclass : #Object,
	#category : #HeapFuzzer
}

{ #category : #executing }
HFEvent >> executeOn: aFuzzing [

	self subclassResponsibility
]

{ #category : #testing }
HFEvent >> isAllocation [
	
	^ false
]

{ #category : #resetting }
HFEvent >> reset [
	
	"Nothing"
]
