Class {
	#name : #HFBinaryObjectEvent,
	#superclass : #HFEvent,
	#instVars : [
		'referer',
		'referee'
	],
	#category : #HeapFuzzer
}

{ #category : #executing }
HFBinaryObjectEvent >> executeOn: aFuzzing [

	"If either was already collected, this event does nothing..."
	referer oop ifNil: [ ^ self ].
	referee oop ifNil: [ ^ self ].

	(aFuzzing heap memory addressCouldBeOop: referer oop)
		ifFalse: [ ^ self ].
	(aFuzzing heap memory addressCouldBeOop: referee oop)
		ifFalse: [ ^ self ].

	((aFuzzing heap memory hashBitsOf: referer oop)
		= referer objectHash) ifFalse: [ ^ self ].

	((aFuzzing heap memory hashBitsOf: referee oop)
		= referee objectHash) ifFalse: [ ^ self ].

	^ self basicExecuteOn: aFuzzing
]

{ #category : #'as yet unclassified' }
HFBinaryObjectEvent >> maybeEffectiveOn: events [

	^ (events includes: referee) and: [ events includes: referer ] 
]

{ #category : #printing }
HFBinaryObjectEvent >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: referer id;
		nextPutAll: ', ';
		print: referee id;
		nextPut: $)
]

{ #category : #accessing }
HFBinaryObjectEvent >> referee [

	^ referee
]

{ #category : #accessing }
HFBinaryObjectEvent >> referee: anObject [

	referee := anObject
]

{ #category : #accessing }
HFBinaryObjectEvent >> referer [

	^ referer
]

{ #category : #accessing }
HFBinaryObjectEvent >> referer: anObject [

	referer := anObject
]

{ #category : #resetting }
HFBinaryObjectEvent >> reset [
	
	referer reset.
	referee reset.
]
