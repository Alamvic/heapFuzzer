Class {
	#name : #HFResultsErrorsClassifier,
	#superclass : #HFErrorsClassifier,
	#category : #HeapFuzzer
}

{ #category : #accessing }
HFResultsErrorsClassifier >> fileName [

	^ 'results.ston'
]

{ #category : #classification }
HFResultsErrorsClassifier >> fuzzingsIn: results [

	^ (results flattened flatCollect: [ :experiment | experiment fuzzings ])
		  select: [ :fuzzingResult | fuzzingResult isError ]
		  thenCollect: [ :fuzzingError | fuzzingError fuzzing ]
]
