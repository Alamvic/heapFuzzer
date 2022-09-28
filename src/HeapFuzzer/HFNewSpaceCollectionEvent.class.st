Class {
	#name : #HFNewSpaceCollectionEvent,
	#superclass : #HFCollectionEvent,
	#category : #'HeapFuzzer-Core'
}

{ #category : #executing }
HFNewSpaceCollectionEvent >> executeOn: aVMHeapFuzzer [ 

	aVMHeapFuzzer heap memory scavengingGCTenuringIf: 1 "Tenure by age".
	aVMHeapFuzzer remapObjects
]
