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

{ #category : #accessing }
HeapGrayboxFuzzer >> chart [

| timeline list chart max listmax |

timeline := seeds select: [ :f | f coverage isNotNil ].
timeline sort: [ :a :b | a timestamp < b timestamp ].
list := timeline collect: [ :f| f coverage nodes size ].

max := 0.
listmax := timeline collect: [ :f | max := f coverage nodes size max: max ].

chart := RSChart new.
chart add: (RSScatterPlot new
    x: (1 to: list size)
    y: list).
chart add: (RSLinePlot new
    x: (1 to: listmax size)
    y: listmax).
chart add: (RSHorizontalTick new
    numberOfTicks: 10;
    useDiagonalLabel;
    yourself).
chart add: RSVerticalTick new.
^ chart
]

{ #category : #'as yet unclassified' }
HeapGrayboxFuzzer >> chooseSeed [

	"Chose a seed according to the local policies"

	| seed |
	
	"Recompute the score of all seeds. It is here that most of the graybox magic happens."
	seeds do: [ :s |
		| score xscore | "use xscore do disable a line :)"
		score := 10.0 * s coverage nodes size. "what is uber important is coverage"
		score := score - s events size. "small bonus for the size."
		xscore := score - (coverageCounter at: s coverage nodes) size. "Small bonus for rare coverage. Maybe more bugs are lurking in rare path"
		xscore := (1 + s effectCount) * score / (1 + s chooseCount). "Big bonus for effective seeds"
		score := score / (coverageCounter at: s coverage nodes) size. "cancel bonus for coverages that have many seeds"
		score := score raisedTo: 5. "powerscaling"
		s score: score ].

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

	| fuzzing fuzzing2 seed seed2 |
	"Get a prepared seed, or generate a new fuzzing"
	seed := nil.
	fuzzing := seeds detect: [ :x | x result isNil ] ifNone: [ 
		           seed := self chooseSeed.
		           fuzzing := self mutate: seed.
		           seed2 := self chooseSeed.
		           fuzzing2 := self mutate: seed2.
					fuzzing := self combine: fuzzing and: fuzzing2.
					  fuzzing simplify ].

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
HeapGrayboxFuzzer >> methodOverview [

	| methods all missing |
	methods := seeds flatCollect: [ :s | s coverage methods collect: [ :m | m name ] ] as: Set.
	all := collector methods collect: [ :m | m name ] as: Set.
	missing := all \ methods.
	
	methods := methods asArray sort.
	missing := missing asArray sort.
	
	^ { #coveredMethods -> methods.
		#missingMethods -> missing }
]

{ #category : #'as yet unclassified' }
HeapGrayboxFuzzer >> nodesPopularity [

	| result |
	result := Bag new.
	seeds do: [ :s |
		result addAll: s coverage nodes ].
	^ result.
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
