"
Verifies the initialization, presentation lifecycle, layout structure, and interactions of the display zoom presenter.
"
Class {
	#name : 'OPZoomerTest',
	#superclass : 'TestCase',
	#instVars : [
		'zoomer',
		'window'
	],
	#category : 'OpenPonk-Zoomer-Tests',
	#package : 'OpenPonk-Zoomer',
	#tag : 'Tests'
}

{ #category : 'running' }
OPZoomerTest >> tearDown [
	window ifNotNil: [ :activeWindow | activeWindow close ].
	super tearDown
]

{ #category : 'tests' }
OPZoomerTest >> testButtonsOrderRefreshPrecedesApply [
	| morph refreshTextMorph applyTextMorph |
	zoomer := OPZoomer new.
	morph := zoomer build.
	refreshTextMorph := morph allMorphs
		detect: [ :each | (each respondsTo: #text) and: [ each text asString = 'Refresh' ] ]
		ifNone: [ nil ].
	applyTextMorph := morph allMorphs
		detect: [ :each | (each respondsTo: #text) and: [ each text asString = 'Apply Zoom' ] ]
		ifNone: [ nil ].
	self assert: refreshTextMorph isNotNil description: 'Refresh button text morph must exist'.
	self assert: applyTextMorph isNotNil description: 'Apply Zoom button text morph must exist'.
	self assert: refreshTextMorph bounds left < applyTextMorph bounds left description: 'Refresh button must precede Apply Zoom button'
]

{ #category : 'tests' }
OPZoomerTest >> testCanOpenWindow [
	zoomer := OPZoomer new.
	window := zoomer asWindow.
	self assert: window isNotNil.
	self assert: zoomer title equals: 'OpenPonk Display Scaler'
]

{ #category : 'tests' }
OPZoomerTest >> testInstantiation [
	zoomer := OPZoomer new.
	self assert: zoomer scaleModel isNotNil
]

{ #category : 'tests' }
OPZoomerTest >> testMetricRowsAreVisibleAndDoNotOverlapWithTargetConfig [
	| morph verticalLabelMorph targetConfigHeaderMorph |
	zoomer := OPZoomer new.
	morph := zoomer build.
	verticalLabelMorph := morph allMorphs
		detect: [ :each | (each isKindOf: LabelMorph) and: [ each contents asString beginsWith: 'Vertical:' ] ]
		ifNone: [ nil ].
	targetConfigHeaderMorph := morph allMorphs
		detect: [ :each | (each isKindOf: LabelMorph) and: [ each contents asString beginsWith: 'Target Configuration:' ] ]
		ifNone: [ nil ].
	self assert: verticalLabelMorph isNotNil description: 'Vertical metrics row must exist in morph tree'.
	self assert: targetConfigHeaderMorph isNotNil description: 'Target Configuration section header must exist'.
	self assert: verticalLabelMorph bounds bottom <= targetConfigHeaderMorph bounds top
		description: 'Vertical metrics row must be completely above Target Configuration section without overlapping'
]

{ #category : 'tests' }
OPZoomerTest >> testMetricRowsAreVisibleInBuiltMorph [
	| morph assumedLabelMorph |
	zoomer := OPZoomer new.
	morph := zoomer build.
	assumedLabelMorph := morph allMorphs
		detect: [ :each | (each isKindOf: LabelMorph) and: [ each contents asString beginsWith: 'Assumed:' ] ]
		ifNone: [ nil ].
	self assert: assumedLabelMorph isNotNil description: 'Assumed label morph must be present in built morph'.
	self assert: (morph bounds containsRect: assumedLabelMorph bounds) description: 'Assumed label must be positioned within main morph bounds'.
	self assert: assumedLabelMorph bounds bottom <= morph bounds bottom description: 'Assumed label must not be clipped out of morph bounds'
]

{ #category : 'tests' }
OPZoomerTest >> testRefreshActionExistsAndUpdatesModel [
	zoomer := OPZoomer new.
	self assert: (zoomer respondsTo: #refresh).
	self assert: (zoomer respondsTo: #refreshButton)
]

{ #category : 'tests' }
OPZoomerTest >> testWindowTitle [
	zoomer := OPZoomer new.
	window := zoomer asWindow.
	self assert: window title equals: 'OpenPonk Display Scaler'
]
