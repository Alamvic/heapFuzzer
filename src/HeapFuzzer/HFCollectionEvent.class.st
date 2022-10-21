Class {
	#name : #HFCollectionEvent,
	#superclass : #HFEvent,
	#category : #HeapFuzzer
}

{ #category : #building }
HFCollectionEvent class >> buildEventOn: aHeapFuzzer [ 
	
	^ self new
]
