"
I represent a code coverage session.

Here is a quick usage

```
| coverage result |
coverage := CoverageCollector new. ""Instantiate""
coverage methods: collectionOfCompiledMethods. ""Configure with the methods to watch.""
result := coverage runOn: [ some. code ]. ""Setup, execute and teardown.""
result percentage. ""Inspect the results""
```

The `CoverageCollector>>#runOn:` methods is a high level method.
It calls the following fine grained methods in order:

* `CoverageCollector>>#install` to instrument the preselected methods
* `CoverageCollector>>#basicRun:` to watch the execution of a block.
* `CoverageCollector>>#uninstall` to remove the instrumentation on methods.
* `CoverageCollector>>#collectResult` to build and return a `CoverageResult` instance.
* `CoverageCollector>>#reset` to clear the annotation on executed methods.

Note: if `uninstall` is not called, some instrumentation may leaks.
You can use the global `CoverageCollector class>>#uninstallAll` to remove all instrumentation if needed.



"
Class {
	#name : #CoverageCollector,
	#superclass : #Object,
	#instVars : [
		'metalink',
		'methods',
		'nodes'
	],
	#category : #Coverage
}

{ #category : #'as yet unclassified' }
CoverageCollector class >> uninstalAll [

	"If for some reason metalinks are not removed, force a full image cleaning"

	<script>
	MetaLink allInstancesDo: [ :each | 
		(each selector == #tagExecuted and: [ each metaObject == #node ]) 
			ifTrue: [ each uninstall ] ]
]

{ #category : #'as yet unclassified' }
CoverageCollector >> basicRun: aBlock [

"just run the block. We consider that the correct setup is done and that a teardown will be performed."

	^ aBlock value
]

{ #category : #accessing }
CoverageCollector >> collectResult [

	| res |
	"Collect the result"
	res := CoverageResult new.
	res collector: self.
	res methods: (methods select: [ :m | m ast hasBeenExecuted ]).
	res nodes: Set new.
	nodes do: [ :node | 
			node hasBeenExecuted ifTrue: [ res nodes add: node ] ].
	self reset.

	^ res
]

{ #category : #accessing }
CoverageCollector >> initialize [

	metalink := MetaLink new
		            selector: #tagExecuted;
		            metaObject: #node.
	methods := IdentitySet new.
	nodes := IdentitySet new.
]

{ #category : #actions }
CoverageCollector >> install [

	"Prepare the metalink. This can be slow.
	
	Sequence nodes are also prepared. This enable a basic path coverage."

	[ 
	methods do: [ :meth | 
		meth ast link: metalink.
		meth ast nodesDo: [ :node | 
			node isSequence ifTrue: [ 
				node link: metalink.
				nodes add: node ] ] ] ] valueUnpreemptively
]

{ #category : #accessing }
CoverageCollector >> installOn: aBlock [

	"just run a block, with installation and uninstallation."

	self install.
	aBlock ensure: [ self uninstall ].
]

{ #category : #accessing }
CoverageCollector >> metalink [

	^ metalink
]

{ #category : #accessing }
CoverageCollector >> methods [

	^ methods
]

{ #category : #accessing }
CoverageCollector >> methods: anObject [

	methods := anObject
]

{ #category : #accessing }
CoverageCollector >> nodes [
	^ nodes
]

{ #category : #printing }
CoverageCollector >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: ' methods: ';
		print: methods size;
		nextPutAll: ' nodes: ';
		print: nodes size
]

{ #category : #initialization }
CoverageCollector >> reset [

	"Cleanup the annotations, metalikns remains installed.
	You should call if before you measure something."

	methods do: [ :meth | meth ast removeProperty: #tagExecuted ifAbsent: [ ] ].
	nodes do: [ :each | each removeProperty: #tagExecuted ifAbsent: [ ] ].
]

{ #category : #accessing }
CoverageCollector >> runOn: aBlock [

	"full run self, with installation, execution and uninstallation."

	self install.
	self reset.
	[ self basicRun: aBlock ] ensure: [ self uninstall ].
	^ self collectResult
]

{ #category : #actions }
CoverageCollector >> uninstall [

	metalink uninstall
]
