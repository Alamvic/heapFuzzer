Class {
	#name : #HFCollectionEvent,
	#superclass : #Object,
	#category : #HeapFuzzer
}

{ #category : #building }
HFCollectionEvent class >> buildEventOn: aHeapFuzzer [ 
	
	^ self new
]

{ #category : #testing }
HFCollectionEvent >> isAllocation [
	
	^ false
]

{ #category : #resetting }
HFCollectionEvent >> reset [
	
	"Nothing"
]
