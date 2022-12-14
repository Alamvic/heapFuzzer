Extension { #name : #CollectionTest }

{ #category : #'*HeapFuzzer' }
CollectionTest >> testAtRandomWeighting [

	| random collection hits |
	collection := { 0. 0. 1. 0. 4. 0. 3. 0. 2. 0. 0. }.

	"Fixed randomness"
	random := (Random seed: 42).
	
	"Collect results"	
	hits := Bag new.
	1000 timesRepeat: [ 
		hits add: (collection atRandom: random weighting: [ :x | x ])
	].

	self assert: (hits occurrencesOf: 0) equals: 0. "exactly 0%"
	self assert: (hits occurrencesOf: 1) equals: 111. "approx 10%"
	self assert: (hits occurrencesOf: 2) equals: 180. "approx 20%"
	self assert: (hits occurrencesOf: 3) equals: 286. "approx 30%"
	self assert: (hits occurrencesOf: 4) equals: 423. "approx 40%"
]

{ #category : #'*HeapFuzzer' }
CollectionTest >> testAtRandomWeightingMultiple [

	| random collection hits |
	collection := { 1. 1. 1. 5. 1. 1. 1. }.

	"Fixed randomness"
	random := (Random seed: 42).
	
	"Collect results"	
	hits := Bag new.
	1000 timesRepeat: [ 
		hits add: (collection atRandom: random weighting: [ :x | x ])
	].

	self assert: (hits occurrencesOf: 1) equals: 546. "approx 50%"
	self assert: (hits occurrencesOf: 5) equals: 454. "approx 50%"

]
