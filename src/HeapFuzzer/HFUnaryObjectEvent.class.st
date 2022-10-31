Class {
	#name : #HFUnaryObjectEvent,
	#superclass : #HFEvent,
	#instVars : [
		'allocation'
	],
	#category : #HeapFuzzer
}

{ #category : #'instance creation' }
HFUnaryObjectEvent class >> buildEventOn: aHeapFuzzer [

	| object |

	object := aHeapFuzzer randomAllocationEvent.
	object ifNil: [ ^ HFNopEvent new ].

	^ self new
		  allocation: object;
		  yourself
]

{ #category : #accessing }
HFUnaryObjectEvent >> allocation [

	^ allocation
]

{ #category : #accessing }
HFUnaryObjectEvent >> allocation: anObject [

	allocation := anObject
]

{ #category : #executing }
HFUnaryObjectEvent >> basicExecuteOn: aHeapFuzzing [

	self subclassResponsibility
]

{ #category : #executing }
HFUnaryObjectEvent >> executeOn: aHeapFuzzer [

	"If either was already collected, this event does nothing..."

	allocation oop ifNil: [ ^ self ].

	(aHeapFuzzer heap memory addressCouldBeOop: allocation oop) ifFalse: [ 
		^ self ].


	(aHeapFuzzer heap memory hashBitsOf: allocation oop)
	= allocation objectHash ifFalse: [ ^ self ].

	"aHeapFuzzer heap memory checkOkayOop: allocation oop."

	self basicExecuteOn: aHeapFuzzer
]

{ #category : #printing }
HFUnaryObjectEvent >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: allocation id;
		nextPut: $)
]

{ #category : #initialization }
HFUnaryObjectEvent >> reset [ 

	allocation reset
]
