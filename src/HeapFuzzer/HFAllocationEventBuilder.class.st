Class {
	#name : #HFAllocationEventBuilder,
	#superclass : #Object,
	#instVars : [
		'rootValues',
		'pinValues',
		'objectTypes',
		'objectSizes',
		'allocationSpaces'
	],
	#category : #'HeapFuzzer-Builders'
}

{ #category : #accessing }
HFAllocationEventBuilder class >> default [

	^ self new
		objectTypes: { #array . #ephemeron };
		objectSizes: (0 to: 1000);
		allocationSpaces: { #old . #new };
		rootValues: {true . false};
		yourself
]

{ #category : #accessing }
HFAllocationEventBuilder >> allocationSpaces [

	^ allocationSpaces
]

{ #category : #accessing }
HFAllocationEventBuilder >> allocationSpaces: anObject [

	allocationSpaces := anObject
]

{ #category : #building }
HFAllocationEventBuilder >> buildEventOn: aHeapFuzzer [ 
	
	^ aHeapFuzzer addAllocation: self newRandom
]

{ #category : #building }
HFAllocationEventBuilder >> newRandom [
	
	^ HFAllocationEvent new
		objectType: objectTypes atRandom;
		objectSize: objectSizes atRandom;
		isNew: allocationSpaces atRandom == #new;
		isRoot: rootValues atRandom;
		yourself
]

{ #category : #accessing }
HFAllocationEventBuilder >> objectSizes [

	^ objectSizes
]

{ #category : #accessing }
HFAllocationEventBuilder >> objectSizes: anObject [

	objectSizes := anObject
]

{ #category : #accessing }
HFAllocationEventBuilder >> objectTypes [

	^ objectTypes
]

{ #category : #accessing }
HFAllocationEventBuilder >> objectTypes: anObject [

	objectTypes := anObject
]

{ #category : #accessing }
HFAllocationEventBuilder >> pinValues [

	^ pinValues
]

{ #category : #accessing }
HFAllocationEventBuilder >> pinValues: anObject [

	pinValues := anObject
]

{ #category : #accessing }
HFAllocationEventBuilder >> rootValues [

	^ rootValues
]

{ #category : #accessing }
HFAllocationEventBuilder >> rootValues: anObject [

	rootValues := anObject
]
