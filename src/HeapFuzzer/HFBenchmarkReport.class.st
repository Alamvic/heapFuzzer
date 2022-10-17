Class {
	#name : #HFBenchmarkReport,
	#superclass : #Object,
	#instVars : [
		'fuzzings'
	],
	#category : #HeapFuzzer
}

{ #category : #accessing }
HFBenchmarkReport >> allocationPattern [

	| allocations allocationsPerType |
	allocations := fuzzings gather: [ :fuzzingResult | 
		               fuzzingResult isError
			               ifTrue: [ fuzzingResult fuzzing allocations ]
			               ifFalse: [ #(  ) ] ].
	allocationsPerType := allocations groupedBy: [ :e | e objectType ].
	^ allocationsPerType collect: [ :e | 
		  (e groupedBy: [ :allocation | allocation objectSize ]) collect: [ 
			  :allocationsPerSize | allocationsPerSize size ] ]
]

{ #category : #accessing }
HFBenchmarkReport >> errorPercentage [

	^ ((fuzzings count: [ :e | e isError ]) / fuzzings size * 100) asFloat
]

{ #category : #accessing }
HFBenchmarkReport >> fuzzings [
	^ fuzzings
]

{ #category : #accessing }
HFBenchmarkReport >> fuzzings: aCollection [ 
	fuzzings := aCollection
]
