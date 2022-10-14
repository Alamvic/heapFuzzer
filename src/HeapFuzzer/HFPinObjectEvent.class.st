Class {
	#name : #HFPinObjectEvent,
	#superclass : #Object,
	#instVars : [
		'allocation'
	],
	#category : #HeapFuzzer
}

{ #category : #'instance creation' }
HFPinObjectEvent class >> buildEventOn: aHeapFuzzer [

	| object |
	aHeapFuzzer allocations ifEmpty: [ ^ HFNopEvent new ].

	object := aHeapFuzzer allocations atRandom.

	^ self new
		  allocation: object;
		  yourself
]

{ #category : #accessing }
HFPinObjectEvent >> allocation [

	^ allocation
]

{ #category : #accessing }
HFPinObjectEvent >> allocation: anObject [

	allocation := anObject
]

{ #category : #executing }
HFPinObjectEvent >> executeOn: aHeapFuzzer [

	"If either was already collected, this event does nothing..."

	allocation oop ifNil: [ ^ self ].

	(aHeapFuzzer heap memory addressCouldBeOop: allocation oop) ifFalse: [ 
		^ self ].


	(aHeapFuzzer heap memory hashBitsOf: allocation oop)
	= allocation objectHash ifFalse: [ ^ self ].

	aHeapFuzzer heap memory pinObject: allocation oop.
	(aHeapFuzzer heap memory isForwarded: allocation oop) ifTrue: [
		allocation oop: (aHeapFuzzer heap memory followForwarded: allocation oop) ]
]

{ #category : #testing }
HFPinObjectEvent >> isAllocation [
	
	^ false
]

{ #category : #resetting }
HFPinObjectEvent >> reset [
	
	"Nothing"
]