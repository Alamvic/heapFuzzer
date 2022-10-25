"
I represents the result of a code coverage measure.

I'm produced by `CoverageCollector`
"
Class {
	#name : #CoverageResult,
	#superclass : #Object,
	#instVars : [
		'collector',
		'methods',
		'nodes'
	],
	#category : #Coverage
}

{ #category : #accessing }
CoverageResult >> collector [

	^ collector
]

{ #category : #accessing }
CoverageResult >> collector: anObject [

	collector := anObject
]

{ #category : #'as yet unclassified' }
CoverageResult >> crown [

	| uncoveredMethods uncoveredSelectors crown |
	uncoveredMethods := collector methods difference: methods.
	self assert:
		uncoveredMethods size + methods size = collector methods size.

	uncoveredSelectors := uncoveredMethods
		                      collect: [ :each | each selector ]
		                      as: Set.

	crown := Dictionary new.

	methods do: [ :m | 
		m sendNodes do: [ :n | 
			| selector |
			selector := n selector.
			(uncoveredSelectors includes: selector) ifTrue: [ 
				| c |
				c := crown at: selector ifAbsentPut: [ 
					     | nc |
					     nc := Crown new.
					     nc selector: selector.
					     uncoveredMethods
						     select: [ :x | x selector = selector ]
						     thenDo: [ :x | nc callees add: x ].
					     nc ].
				c callers add: n ] ] ].

	^ crown
]

{ #category : #'as yet unclassified' }
CoverageResult >> crownNodes [

	"Return the uncovered nodes of each covered methods."

	| res |
	res := Dictionary new.

	methods do: [ :each |
		| list |
		list := OrderedCollection new.
		each ast nodesDo: [  :n |
			((collector nodes includes: n) and: [(nodes includes: n) not]) ifTrue: [ list add: n ] ].
		list ifNotEmpty: [ res at: each put: list. ] ].

	^res
]

{ #category : #accessing }
CoverageResult >> methods [

	^ methods
]

{ #category : #accessing }
CoverageResult >> methods: anObject [

	methods := anObject
]

{ #category : #accessing }
CoverageResult >> nodes [

	^ nodes
]

{ #category : #accessing }
CoverageResult >> nodes: anObject [

	nodes := anObject
]

{ #category : #'accessing - computed' }
CoverageResult >> percentage [

	collector methods isEmpty ifTrue: [ ^ Float nan ].
	^ 100.0 * methods size / collector methods size
]

{ #category : #printing }
CoverageResult >> printOn: aStream [

	"Append a sequence of characters to aStream that identify the receiver."

	super printOn: aStream.
	aStream
		nextPutAll: ' methods: ';
		print: methods size;
		nextPutAll: ' (';
		print: ((100.0 * methods size / collector methods size) rounded) ;
		nextPutAll: '%) nodes: ';
		print: nodes size;
		nextPutAll: ' (';
		print: ((100.0 * nodes size / collector nodes size) rounded) ;
		nextPutAll: '%)'

]
