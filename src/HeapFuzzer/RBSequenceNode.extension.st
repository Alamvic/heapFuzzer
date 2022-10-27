Extension { #name : #RBSequenceNode }

{ #category : #'*HeapFuzzer' }
RBSequenceNode >> printOn: aStream [

	"Ad hoc entension as printOn is se sloooowwwww to print and freeze the ui with a lot of such nodes"

	|methname|
	methname := self methodNode ifNil: [ '?' ] ifNotNil: [ :n | n compiledMethod name ].
	aStream
		nextPutAll: self class name;
		nextPut: $ ;
		print: methname;
		nextPut: $:;
		print: self sourceInterval;
		nextPut: $ ;
		print: self children size.
]
