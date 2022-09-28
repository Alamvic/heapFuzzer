Class {
	#name : #HFNopEvent,
	#superclass : #Object,
	#category : #HeapFuzzer
}

{ #category : #executing }
HFNopEvent >> executeOn: aVMHeapFuzzer [ 
	
	"Nothing!"
]

{ #category : #testing }
HFNopEvent >> isAllocation [
	
	^ false
]

{ #category : #resetting }
HFNopEvent >> reset [
	
	"Nothing"
]
