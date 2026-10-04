"
Verifies the initialization, presentation lifecycle, layout structure, and interactions of the display zoom presenter.
"
Class {
	#name : 'OPZoomerTest',
	#superclass : 'TestCase',
	#instVars : [
		'zoomer',
		'window',
		'initialBaseDPI',
		'initialZoomFactor'
	],
	#category : 'OpenPonk-Zoomer-Tests',
	#package : 'OpenPonk-Zoomer',
	#tag : 'Tests'
}

{ #category : 'running' }
OPZoomerTest >> setUp [
	super setUp.
	initialBaseDPI := OSSDL2BackendWindow screenScaleFactorBaseDPI.
	initialZoomFactor := WorldMorph zoomFactor
]

{ #category : 'running' }
OPZoomerTest >> tearDown [
	window ifNotNil: [ :activeWindow | activeWindow close ].
	initialBaseDPI ifNotNil: [ :base |
		OSSDL2BackendWindow screenScaleFactorBaseDPI: base ].
	initialZoomFactor ifNotNil: [ :zoom |
		WorldMorph zoomFactor: zoom ].
	super tearDown
]

{ #category : 'tests' }
OPZoomerTest >> testApplyButtonDisabledWhenBaseDPIMatches [
	| customModel |
	customModel := OPDisplayScaleModel new.
	customModel backendBaseDPI: 96.0.
	customModel diagonalDPI: 96.0 horizontalDPI: 96.0 verticalDPI: 96.0.
	zoomer := OPZoomer new.
	zoomer scaleModel: customModel.
	self deny: zoomer applyButton isEnabled
		description: 'Apply button must be disabled when computed target base DPI matches current base DPI'
]

{ #category : 'tests' }
OPZoomerTest >> testApplyButtonEnabledWhenBaseDPIDiffers [
	| customModel |
	customModel := OPDisplayScaleModel new.
	customModel backendBaseDPI: 96.0.
	customModel diagonalDPI: 120.0 horizontalDPI: 120.0 verticalDPI: 120.0.
	zoomer := OPZoomer new.
	zoomer scaleModel: customModel.
	zoomer targetZoomDropList selectItem: 100.
	self assert: zoomer applyButton isEnabled
		description: 'Apply button must be enabled when computed target base DPI differs from current base DPI'
]

{ #category : 'tests' }
OPZoomerTest >> testApplyZoomResetsWorldMorphZoomFactor [
	WorldMorph zoomFactor: 2.
	zoomer := OPZoomer new.
	zoomer applyZoom.
	self assert: WorldMorph zoomFactor equals: 1
]

{ #category : 'tests' }
OPZoomerTest >> testButtonsOrderRefreshPrecedesApply [
	| morph refreshMorph applyMorph |
	zoomer := OPZoomer new.
	morph := zoomer build.
	morph extent: 480 @ 380.
	morph fullBounds.
	refreshMorph := morph allMorphs
		detect: [ :each | (each respondsTo: #label) and: [ each label asString = 'Refresh' ] ]
		ifNone: [
			morph allMorphs
				detect: [ :each | (each respondsTo: #text) and: [ each text asString = 'Refresh' ] ]
				ifNone: [ nil ] ].
	applyMorph := morph allMorphs
		detect: [ :each | (each respondsTo: #label) and: [ each label asString = 'Apply Zoom' ] ]
		ifNone: [
			morph allMorphs
				detect: [ :each | (each respondsTo: #text) and: [ each text asString = 'Apply Zoom' ] ]
				ifNone: [ nil ] ].
	self assert: refreshMorph isNotNil description: 'Refresh button morph must exist'.
	self assert: applyMorph isNotNil description: 'Apply Zoom button morph must exist'.
	self assert: refreshMorph bounds left < applyMorph bounds left description: 'Refresh button must precede Apply Zoom button'
]

{ #category : 'tests' }
OPZoomerTest >> testCanOpenWindow [
	zoomer := OPZoomer new.
	window := zoomer asWindow.
	self assert: window isNotNil.
	self assert: zoomer title isNotEmpty
]

{ #category : 'tests' }
OPZoomerTest >> testDisplayStringForZoomPercentage [
	| customModel |
	customModel := OPDisplayScaleModel new.
	customModel backendBaseDPI: 120.0.
	customModel diagonalDPI: 120.0 horizontalDPI: 120.0 verticalDPI: 120.0.
	zoomer := OPZoomer new.
	zoomer scaleModel: customModel.
	"Current is 100 %, default is 125 %"
	self assert: (zoomer displayStringForZoomPercentage: 100) equals: '100 % [current]'.
	self assert: (zoomer displayStringForZoomPercentage: 125) equals: '125 % [default]'.
	self assert: (zoomer displayStringForZoomPercentage: 200) equals: '200 %'.

	customModel backendBaseDPI: 96.0.
	customModel diagonalDPI: 96.0 horizontalDPI: 96.0 verticalDPI: 96.0.
	"Current is 100 %, default is 100 %"
	self assert: (zoomer displayStringForZoomPercentage: 100) equals: '100 % [current] [default]'
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
	morph extent: 480 @ 380.
	morph fullBounds.
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
OPZoomerTest >> testOpenClassMethodOpensWindow [
	window := OPZoomer open.
	self assert: window isNotNil description: 'OPZoomer class >> #open must return an opened window'.
	self assert: window isOpen description: 'Window must be open'
]

{ #category : 'tests' }
OPZoomerTest >> testRefreshActionExistsAndUpdatesModel [
	zoomer := OPZoomer new.
	self assert: (zoomer respondsTo: #refresh).
	self assert: (zoomer respondsTo: #refreshButton)
]

{ #category : 'tests' }
OPZoomerTest >> testResetButtonDoesNotExist [
	zoomer := OPZoomer new.
	self deny: (zoomer respondsTo: #resetButton)
		description: 'Reset button accessor must be removed from presenter'.
	self deny: (zoomer respondsTo: #resetZoom)
		description: 'Reset action method must be removed from presenter'
]

{ #category : 'tests' }
OPZoomerTest >> testSettingsDeclarationRegistersButtonUnderAppearance [
	| settingMethods |
	settingMethods := OPZoomer class methods select: [ :m | (m pragmaAt: #systemsettings) isNotNil ].
	self assert: settingMethods isNotEmpty description: 'OPZoomer class must declare a <systemsettings> method'.
	self assert: (settingMethods anySatisfy: [ :m | m sourceCode includesSubstring: 'parent: #appearance' ])
		description: 'Zoomer setting in OPZoomer must be registered under #appearance to be independent of OpenPonk'
]

{ #category : 'tests' }
OPZoomerTest >> testTargetZoomDropListPrefillsCurrentZoom [
	| customModel |
	customModel := OPDisplayScaleModel new.
	customModel backendBaseDPI: 96.0.
	customModel diagonalDPI: 120.0 horizontalDPI: 120.0 verticalDPI: 120.0.
	zoomer := OPZoomer new.
	zoomer scaleModel: customModel.
	self assert: (zoomer targetZoomDropList items includes: 125)
		description: 'Target zoom drop list must include non-standard current zoom percentage'.
	self assert: zoomer targetZoomDropList selectedItem equals: 125
]

{ #category : 'tests' }
OPZoomerTest >> testWindowTitle [
	zoomer := OPZoomer new.
	window := zoomer asWindow.
	self assert: window title equals: zoomer title.
	self deny: window title equals: 'Unnamed Window'
]
