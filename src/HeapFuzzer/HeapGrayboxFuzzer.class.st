Class {
	#name : #HeapGrayboxFuzzer,
	#superclass : #HeapFuzzer,
	#instVars : [
		'collector',
		'seeds',
		'errors',
		'coverageCounter'
	],
	#category : #HeapFuzzer
}

{ #category : #'as yet unclassified' }
HeapGrayboxFuzzer >> basicFuzz [

	| n i |
	seeds := OrderedCollection new.
	errors := OrderedCollection new.
	coverageCounter := Dictionary new.

	self prepareSeeds.
	n := 2.
	i := 1.

	[ self atEnd ] whileFalse: [
		(1 to: n)
			do: [ :j |
				self doStep.
				self atEnd ifTrue: [ ^self ].
				i := i + 1. 	]
			displayingProgress: [ :iteration | 
				| first last |
				first := nil.
				last := nil.
				seeds ifNotEmpty: [ first := seeds first. last := seeds last ].
				'Fuzzing step ' , i asString, String cr, 'best: ', first asString, String cr, 'last: ', last asString ].
		n := n * 2 ].
]

{ #category : #'as yet unclassified' }
HeapGrayboxFuzzer >> chooseSeed [

	"Chose a seed according to the local policies"

	| seed |
	
	"Recompute the score of all seeds. It is here that most of the graybox magic happens."
	seeds do: [ :s | 
		s score: 10.0 * s coverage nodes size - s events size - (coverageCounter at: s coverage nodes) size
		" + (1.0 / (covers at: s coverage nodes) size) * 1.0"
		" * ((1 + s effectCount) / (1 + s chooseCount))" ].

	"We sort because it is easier to display"
	seeds sort: [ :a :b | a score > b score ].

	seed := seeds atRandom: random weighting: [ :each | each score ].
	"seed := seeds at: 1." "Alternative to weighted choice"
	seed chooseCount: seed chooseCount + 1.
	^ seed
]

{ #category : #'as yet unclassified' }
HeapGrayboxFuzzer >> doStep [

	"Get a fuzzing, execute it and uptate information"

	| fuzzing seed |
	"Get a prepared seed, or generate a new fuzzing"
	seed := nil.
	fuzzing := seeds detect: [ :x | x result isNil ] ifNone: [ 
		           seed := self chooseSeed.
		           fuzzing := self mutate: seed ].

	"Execute the fuzzing"
	fuzzing executeCoverage: collector.
	fuzzing result isError ifTrue: [ 
		errors add: fuzzing.
		errors size = 1 ifTrue: [ errors inspect ] ].
	fuzzing reset.

	seed ifNotNil: [ seeds add: fuzzing ].

	"Update global coverage information"
	(coverageCounter at: fuzzing coverage nodes ifAbsentPut: [ 
		 seed ifNotNil: [ seed effectCount: seed effectCount + 1 ].
		 OrderedCollection new ]) add: fuzzing.

	^ fuzzing
]

{ #category : #'as yet unclassified' }
HeapGrayboxFuzzer >> fuzz [

	collector := CoverageCollector new.
"	collector methods: #VMMaker asPackage methods."
"	collector methods: SpurMemoryManager methods."
"	collector methods: Spur64BitMemoryManager allMethods."
	collector methods: ((#VMMaker asPackage classes select: [:c| 'Spur*' match: c name ]) flatCollect: [:c | c methods]).

	collector installOn: [ self basicFuzz ].
]

{ #category : #'as yet unclassified' }
HeapGrayboxFuzzer >> prepareSeeds [

	"Generate the first seeds"

	1 to: 5 do: [ :iteration | 
		| fuzzing |
		fuzzing := HeapFuzzing new.
		fuzzing build: 1 events: self.
		seeds add: fuzzing ]
]