Class {
	#name : #HFOldSpaceCollectionEvent,
	#superclass : #HFCollectionEvent,
	#category : #'HeapFuzzer-Core'
}

{ #category : #executing }
HFOldSpaceCollectionEvent >> executeOn: aVMHeapFuzzer [ 

	aVMHeapFuzzer heap memory fullGC.
	aVMHeapFuzzer remapObjects
]
