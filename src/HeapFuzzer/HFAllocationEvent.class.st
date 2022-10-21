Class {
	#name : #HFAllocationEvent,
	#superclass : #HFAllocation,
	#instVars : [
		'id',
		'objectType',
		'objectSize',
		'isNew',
		'isRoot'
	],
	#category : #HeapFuzzer
}

{ #category : #building }
HFAllocationEvent class >> buildEventOn: aHeapFuzzer [ 
	
	^ aHeapFuzzer addAllocation: self newRandom
]

{ #category : #helpers }
HFAllocationEvent class >> newObjectSize [

	"in slots size"

	^ 2000 atRandom
]

{ #category : #helpers }
HFAllocationEvent class >> newObjectType [

	^ { #ephemeron . #array } atRandom
]

{ #category : #'instance creation' }
HFAllocationEvent class >> newRandom [
	
	^ self new
		objectType: self newObjectType;
		objectSize: self newObjectSize;
		isNew: {true . false} atRandom;
		isRoot: {true . false} atRandom;
		yourself
]

{ #category : #executing }
HFAllocationEvent >> allocateNew: aVMHeapFuzzer [

	| classObj format |
	format := self
		          perform: (objectType asString , 'Format:') asSymbol
		          with: aVMHeapFuzzer.
	classObj := aVMHeapFuzzer
		            classWithFormat: format
		            fixedSlots: objectSize.
	^ aVMHeapFuzzer heap memory
		  allocateSlots: objectSize
		  format: format
		  classIndex: classObj objectHash
]

{ #category : #executing }
HFAllocationEvent >> allocateOld: aVMHeapFuzzer [

	| classObj format |
	format := self
		          perform: (objectType asString , 'Format:') asSymbol
		          with: aVMHeapFuzzer.
	classObj := aVMHeapFuzzer
		            classWithFormat: format
		            fixedSlots: objectSize.
	^ aVMHeapFuzzer heap memory
		  allocateSlotsInOldSpace: objectSize
		  format: format
		  classIndex: classObj objectHash
]

{ #category : #accessing }
HFAllocationEvent >> arrayFormat: aHeapFuzzing [ 
	
	^ aHeapFuzzing heap memory arrayFormat
]

{ #category : #executing }
HFAllocationEvent >> ephemeronFormat: aVMHeapFuzzer [

	^ aVMHeapFuzzer heap memory ephemeronFormat
]

{ #category : #executing }
HFAllocationEvent >> executeOn: aVMHeapFuzzer [

	oop := isNew
		       ifTrue: [ self allocateNew: aVMHeapFuzzer ]
		       ifFalse: [ self allocateOld: aVMHeapFuzzer ].
	oop ifNil: [ 
		aVMHeapFuzzer heap memory growOldSpaceByAtLeast: 0.
		^ self executeOn: aVMHeapFuzzer ].
	aVMHeapFuzzer heap memory
		fillObj: oop
		numSlots: objectSize
		with: aVMHeapFuzzer heap memory nilObject.
	isRoot ifTrue: [ aVMHeapFuzzer addRoot: oop ].
	hash := aVMHeapFuzzer heap memory hashBitsOf: oop.
	aVMHeapFuzzer addAllocation: self.
]

{ #category : #accessing }
HFAllocationEvent >> id [

	^ id
]

{ #category : #accessing }
HFAllocationEvent >> id: anObject [

	id := anObject
]

{ #category : #testing }
HFAllocationEvent >> isAllocation [
	
	^ true
]

{ #category : #accessing }
HFAllocationEvent >> isNew [

	^ isNew
]

{ #category : #accessing }
HFAllocationEvent >> isNew: anObject [

	isNew := anObject
]

{ #category : #accessing }
HFAllocationEvent >> isRoot [

	^ isRoot
]

{ #category : #accessing }
HFAllocationEvent >> isRoot: anObject [

	isRoot := anObject
]

{ #category : #accessing }
HFAllocationEvent >> numberOfSlots [
	
	^ objectSize
]

{ #category : #accessing }
HFAllocationEvent >> objectSize [

	^ objectSize
]

{ #category : #accessing }
HFAllocationEvent >> objectSize: anObject [

	objectSize := anObject
]

{ #category : #accessing }
HFAllocationEvent >> objectType [

	^ objectType
]

{ #category : #accessing }
HFAllocationEvent >> objectType: aString [ 
	objectType := aString
]

{ #category : #printing }
HFAllocationEvent >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: id;
		nextPut: $)
]
