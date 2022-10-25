Extension { #name : #Collection }

{ #category : #'*HeapFuzzer' }
Collection >> atRandom: aRandom weighting: aBlock [

	"Retrieve an element with a probability related to the weigting block.
	The block takes and element as argument and is expected to provide a number as result.
	An implicit normalization is performed.
	
	Multiple occurences of equals elements multiply the probability to be choosen.
	
	Warning: negative values will behave badly."

	"({'1'. '2'. '3'. '4'} atRandom: (Random seed: -42) weighting: [ :each | each asInteger ]) >>> '4'"
	"({'1'. '1'. '2'. '1'. '1'} atRandom: (Random seed: -42) weighting: [ :each | each asInteger ]) >>> '1'"

	| sum |
	sum := self sum: aBlock.
	sum := sum * aRandom next.

	self do: [ :each | 
		sum := sum - (aBlock value: each).
		sum <= 0 ifTrue: [ ^ each ] ].
	self error: 'This should not happen'
]
