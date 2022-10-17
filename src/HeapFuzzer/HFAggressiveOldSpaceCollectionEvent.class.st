Class {
	#name : #HFAggressiveOldSpaceCollectionEvent,
	#superclass : #HFCollectionEvent,
	#category : #HeapFuzzer
}

{ #category : #executing }
HFAggressiveOldSpaceCollectionEvent >> executeOn: aVMHeapFuzzer [ 

	aVMHeapFuzzer heap memory compactor biasForSnapshot.
	aVMHeapFuzzer heap memory fullGC.
	aVMHeapFuzzer heap memory compactor biasForGC.
	aVMHeapFuzzer remapObjects
]
