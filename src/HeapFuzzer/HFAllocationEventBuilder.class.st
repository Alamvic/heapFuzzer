Class {
	#name : #HFAllocationEventBuilder,
	#superclass : #Object,
	#instVars : [
		'rootValues',
		'pinValues',
		'objectTypes',
		'allocationSpaces',
		'variableObjectSizes',
		'fixedObjectSizes'
	],
	#category : #'HeapFuzzer-Builders'
}

{ #category : #accessing }
HFAllocationEventBuilder class >> default [

	^ self new
		objectTypes: { #array . #ephemeron };
		variableObjectSizes: (0 to: 1000);
		fixedObjectSizes: (0 to: 1000);
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
	
	^ self newRandom
]

{ #category : #accessing }
HFAllocationEventBuilder >> fixedObjectSizes: anObject [

	fixedObjectSizes := anObject
]

{ #category : #building }
HFAllocationEventBuilder >> newRandom [
	
	^ HFAllocationEvent new
		objectType: objectTypes atRandom;
		variableObjectSize: variableObjectSizes atRandom;
		fixedObjectSize: fixedObjectSizes atRandom;
		isNew: allocationSpaces atRandom == #new;
		isRoot: rootValues atRandom;
		yourself
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

{ #category : #accessing }
HFAllocationEventBuilder >> variableObjectSizes [

	^ variableObjectSizes
]

{ #category : #accessing }
HFAllocationEventBuilder >> variableObjectSizes: anObject [

	variableObjectSizes := anObject
]
