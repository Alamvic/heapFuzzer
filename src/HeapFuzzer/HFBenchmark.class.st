"
fullRandom := HFBenchmark new
	fuzzerBuilder: [ HeapFuzzer fullRandom ];
	run.

cornerAllocations := HFBenchmark new
	fuzzerBuilder: [ HeapFuzzer forCornerAllocationCases ];
	run.

ephemerons := HFBenchmark new
	fuzzerBuilder: [ HeapFuzzer forEphemerons ];
	run.

compaction := HFBenchmark new
	iterations: 30;
	fuzzerBuilder: [ HeapFuzzer forCompaction ];
	run.
"
Class {
	#name : #HFBenchmark,
	#superclass : #Object,
	#instVars : [
		'iterations',
		'fuzzerBuilder'
	],
	#category : #HeapFuzzer
}

{ #category : #adding }
HFBenchmark >> fuzzerBuilder: aBuilder [
	
	fuzzerBuilder := aBuilder
]

{ #category : #adding }
HFBenchmark >> initialize [
	super initialize.
	iterations := 30
]

{ #category : #adding }
HFBenchmark >> iterations: aNumber [

	iterations := aNumber
]

{ #category : #executing }
HFBenchmark >> run [

	| fuzzings |
	fuzzings := OrderedCollection new.

	(1 to: iterations)
		do: [ :it | fuzzings add: fuzzerBuilder value fuzz ]
		displayingProgress: [ :iteration | 
		'Benchmark iteration ' , iteration asString ].

	^ HFBenchmarkReport new
		  fuzzings: fuzzings;
		  yourself
]
