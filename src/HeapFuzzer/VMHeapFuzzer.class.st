Class {
	#name : #VMHeapFuzzer,
	#superclass : #VMSpurOldSpaceGarbageCollectorTest,
	#instVars : [
		'classCache',
		'fuzzer'
	],
	#category : #HeapFuzzer
}

{ #category : #accessing }
VMHeapFuzzer >> classCache [

	^ classCache
]

{ #category : #accessing }
VMHeapFuzzer >> classCache: anObject [

	classCache := anObject
]

{ #category : #accessing }
VMHeapFuzzer >> fuzzer [

	^ fuzzer
]

{ #category : #accessing }
VMHeapFuzzer >> fuzzer: anObject [

	fuzzer := anObject
]

{ #category : #tests }
VMHeapFuzzer >> testFuzzHeap [

	| heapEvents |
	100 timesRepeat: [
		1halt.
		fuzzer := HeapFuzzer new.
		fuzzer test: self.
		self memory setCheckForLeaks: 31 "all".
		heapEvents := fuzzer generateEvents.
		heapEvents do: [ :ev | ev executeOn: fuzzer ].
		1halt.
	]
]
