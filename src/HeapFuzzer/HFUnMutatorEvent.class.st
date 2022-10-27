Class {
	#name : #HFUnMutatorEvent,
	#superclass : #HFMutatorEvent,
	#instVars : [
		'mutator'
	],
	#category : #HeapFuzzer
}

{ #category : #building }
HFUnMutatorEvent class >> buildEventOn: aHeapFuzzer [ 
	
	| mutator |

	mutator := aHeapFuzzer randomEvent: [ :evt | evt class = HFMutatorEvent ].
	mutator ifNil: [ ^ HFNopEvent new ].
	
	^ self new
		mutator: mutator;
		referer: mutator referer;
		referee: mutator referer;
		index: mutator index;
		yourself
]

{ #category : #accessing }
HFUnMutatorEvent >> mutator [

	^ mutator
]

{ #category : #accessing }
HFUnMutatorEvent >> mutator: anObject [

	mutator := anObject
]
