Class {
	#name : #HFNewSpaceCollectionEvent,
	#superclass : #HFCollectionEvent,
	#category : #HeapFuzzer
}

{ #category : #executing }
HFNewSpaceCollectionEvent >> executeOn: aVMHeapFuzzer [ 

	aVMHeapFuzzer heap memory scavengingGCTenuringIf: 1 "Tenure by age".
	aVMHeapFuzzer remapObjects
]
