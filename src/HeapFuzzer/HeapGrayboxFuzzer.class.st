Class {
	#name : #HeapGrayboxFuzzer,
	#superclass : #HeapFuzzer,
	#instVars : [
		'collector',
		'seeds',
		'errors',
		'coverageCounter',
		'nodesCounter',
		'callgraph',
		'nodeDistances',
		'maxDist'
	],
	#category : #HeapFuzzer
}

{ #category : #'as yet unclassified' }
HeapGrayboxFuzzer >> basicFuzz [

	| n i |

	seeds ifEmpty: [ self prepareSeeds ].
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
	
	seed := seeds atRandom: random weighting: [ :each | each score ].
	"seed := seeds at: 1." "Alternative to weighted choice"
	seed chooseCount: seed chooseCount + 1.
	^ seed
]

{ #category : #'as yet unclassified' }
HeapGrayboxFuzzer >> computeScore [

	"Recompute the score of all seeds. It is here that most of the graybox magic happens."
	seeds do: [ :s |
		| score xscore | "use xscore do disable a line :)"
		score := 10.0 * s coverage nodes size. "what is uber important is coverage"
		score := score / (self seedDistance: s) second. "directed fuzzing with avg distance"
		xscore := score - s events size. "small bonus for the size."
		xscore := score - (coverageCounter at: s coverage nodes) size. "Small bonus for rare coverage. Maybe more bugs are lurking in rare path"
		xscore := (1 + s effectCount) * score / (1 + s chooseCount). "Big bonus for effective seeds"
		xscore := score * (self nodeScore: s). "Big bonus for rare path taken/not taken"
		score := score raisedTo: 5. "powerscaling"
		score := score / (coverageCounter at: s coverage nodes) size. "cancel bonus for coverages that have many seeds"
		s score: score ].

	"We sort because it is easier to display"
	seeds sort: [ :a :b | a score > b score ].
]

{ #category : #'as yet unclassified' }
HeapGrayboxFuzzer >> doStep [

	"Get a fuzzing, execute it and uptate information"

	| fuzzing seed seed2 |
	"Get a prepared seed, or generate a new fuzzing"
	seed := nil.
	fuzzing := seeds detect: [ :x | x result isNil ] ifNone: [
					  self computeScore.
		           seed := self chooseSeed.
		           seed2 := self chooseSeed.
					  fuzzing := self combine: seed and: seed2.
		           fuzzing := self mutate: fuzzing.
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
	nodesCounter addAll: fuzzing coverage nodes.

	^ fuzzing
]

{ #category : #'as yet unclassified' }
HeapGrayboxFuzzer >> fuzz [

	collector := CoverageCollector new.
"	collector methods: #VMMaker asPackage methods."
"	collector methods: SpurMemoryManager methods."
"	collector methods: Spur64BitMemoryManager allMethods."
	collector methods: ((#VMMaker asPackage classes select: [:c| 'Spur*' match: c name ]) flatCollect: [:c | c methods]).
   collector callgraph.
	nodeDistances := collector nodeDistancesTo: (SpurGenerationScavenger>>#scavengeUnfiredEphemeronsInRememberedSet).

	collector installOn: [ self basicFuzz ].
]

{ #category : #initialization }
HeapGrayboxFuzzer >> initialize [

	super initialize.

	seeds := OrderedCollection new.
	errors := OrderedCollection new.
	coverageCounter := Dictionary new.
	nodesCounter := Bag new.
]

{ #category : #'as yet unclassified' }
HeapGrayboxFuzzer >> methodMissing [

	| methods all missing |
	methods := seeds flatCollect: [ :s | s coverage methods collect: [ :m | m currentMethod ]  ] as: Set.
	all := collector methods collect: [ :m | m currentMethod ] as: Set.
	self assert: (all includesAll: methods).
	missing := all \ methods.
	
	^ missing
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
HeapGrayboxFuzzer >> nodeScore: aFuzzing [

	| result size |

	size := seeds size.

	"This compute the vector distance (on each covered node) between aFuzzing and the average fuzzing.
	
		eg. if the average is (0.5, 0.9, 0.1) and aFuzzing hit all 3 node (i.e 1, 1, 1) it gets
			((0.5-1)squared + (0.9-1)squared + (0.1-1)squared)sqrt = 1.03440804327886

		note: undiscovered nodes behave nicely avg=0 hit=0.
   "

	result := 0.
	nodesCounter doWithOccurrences: [ :each :occ |
		| hitRate itsHit |
		hitRate := occ / size.
		itsHit := (aFuzzing coverage nodes includes: each) ifTrue: [ 1 ] ifFalse: [ 0 ].
		result := result + (hitRate-itsHit) squared.
	].

	^ result sqrt.
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
		fuzzing build: 20 events: self.
		seeds add: fuzzing ]
]

{ #category : #'as yet unclassified' }
HeapGrayboxFuzzer >> seedDistance: aFuzzing [

	"The best distance.
	Returns an array `{min. avg}` with respectively the minimal distance and the average distance"

	| min sum max |

	max := maxDist.
	max ifNil: [ 
		max := maxDist := nodeDistances max.
	].

	min := max+1.
	sum := 0.
	nodeDistances associationsDo: [ :assoc |
		(aFuzzing coverage nodes includes: assoc key)
			ifTrue: [
				(min > assoc value) ifTrue: [ min := assoc value ].
				sum := sum + assoc value. ]
			ifFalse: [
				sum := sum + max + 1. ]
	].
	sum := sum / nodeDistances size.

	^ { min. sum }
]

{ #category : #accessing }
HeapGrayboxFuzzer >> seeds [

	^ seeds
]

{ #category : #accessing }
HeapGrayboxFuzzer >> seeds: anObject [

	seeds := anObject
]
