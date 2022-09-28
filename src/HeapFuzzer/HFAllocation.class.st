Class {
	#name : #HFAllocation,
	#superclass : #Object,
	#instVars : [
		'oop',
		'hash'
	],
	#category : #'HeapFuzzer-Core'
}

{ #category : #testing }
HFAllocation >> isMaybeAliveIn: aHeapFuzzing [ 
	
	(aHeapFuzzing heap memory hashBitsOf: oop) = hash
		ifFalse: [ ^ false ].
	
	^ (aHeapFuzzing heap memory addressCouldBeOop: oop)
]

{ #category : #remapping }
HFAllocation >> markAsDead [

	oop := nil.
	hash := nil
]

{ #category : #accessing }
HFAllocation >> objectHash [

	^ hash
]

{ #category : #accessing }
HFAllocation >> objectHash: aHash [

	hash := aHash
]

{ #category : #accessing }
HFAllocation >> oop [
	^ oop
]

{ #category : #accessing }
HFAllocation >> oop: anObject [

	oop := anObject
]

{ #category : #remapping }
HFAllocation >> remapObjectOn: aRelocationMap [ 
	
	oop ifNil: [ ^ self ].
	
	oop := aRelocationMap
		at: hash
		ifAbsent: [ ^ self markAsDead ]
]

{ #category : #accessing }
HFAllocation >> reset [

	oop := nil.
	hash := nil
]
