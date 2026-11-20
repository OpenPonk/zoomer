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
	#classVars : [
		'PausedOwnerProcess'
	],
	#category : 'OpenPonk-Zoomer-Tests-UI',
	#package : 'OpenPonk-Zoomer-Tests',
	#tag : 'UI'
}

{ #category : 'running' }
OPZoomerTest >> canPauseMorphicUIProcess [

	| uiProcess |
	PausedOwnerProcess == Processor activeProcess ifTrue: [ ^ false ].
	self currentWorld ifNil: [ ^ false ].
	uiProcess := MorphicUIManager uiProcess.
	uiProcess ifNil: [ ^ false ].
	uiProcess == Processor activeProcess ifTrue: [ ^ false ].
	^ uiProcess isTerminated not and: [ uiProcess isSuspended not ]
]

{ #category : 'running' }
OPZoomerTest >> runCase [

	^ self withMorphicUIProcessPausedDo: [ super runCase ]
]

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
	self assert: refreshMorph class identicalTo: TextMorph.
	self assert: applyMorph class identicalTo: TextMorph.
	self assert: refreshMorph bounds left < applyMorph bounds left description: 'Refresh button must precede Apply Zoom button'
]

{ #category : 'tests' }
OPZoomerTest >> testCanOpenWindow [

	zoomer := OPZoomer new.
	window := zoomer asWindow.
	self assert: window class identicalTo: SpWindowPresenter.
	self assert: window presenter identicalTo: zoomer.
	self denyEmpty: zoomer title
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
	self assert: zoomer scaleModel class identicalTo: OPDisplayScaleModel
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
		                           detect: [ :each |
		                           (each isKindOf: LabelMorph) and: [ each contents asString beginsWith: 'Target Configuration:' ] ]
		                           ifNone: [ nil ].
	self assert: verticalLabelMorph class identicalTo: LabelMorph.
	self assert: targetConfigHeaderMorph class identicalTo: LabelMorph.
	self
		assert: verticalLabelMorph bounds bottom <= targetConfigHeaderMorph bounds top
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
	self assert: assumedLabelMorph class identicalTo: LabelMorph.
	self
		assert: (morph bounds containsRect: assumedLabelMorph bounds)
		description: 'Assumed label must be positioned within main morph bounds'.
	self
		assert: assumedLabelMorph bounds bottom <= morph bounds bottom
		description: 'Assumed label must not be clipped out of morph bounds'
]

{ #category : 'tests' }
OPZoomerTest >> testOpenClassMethodOpensWindow [

	window := OPZoomer open.
	self assert: window class identicalTo: SpWindowPresenter.
	self assert: window presenter class identicalTo: OPZoomer.
	self assert: window isOpen description: 'Window must be open'
]

{ #category : 'tests' }
OPZoomerTest >> testRefreshActionExistsAndUpdatesModel [

	| expectedDpiString |
	zoomer := OPZoomer new.
	self assert: zoomer refreshButton class identicalTo: SpButtonPresenter.
	self assert: zoomer refreshButton label equals: 'Refresh'.
	(zoomer instVarNamed: #assumedDpiLabel) label: 'STALE'.
	(zoomer instVarNamed: #assumedZoomLabel) label: 'STALE'.
	zoomer targetZoomDropList items: #( 999 ).
	zoomer refreshButton click.
	expectedDpiString := zoomer scaleModel assumedDPI printShowingDecimalPlaces: 1.
	self assert: (zoomer instVarNamed: #assumedDpiLabel) label equals: expectedDpiString.
	self
		assert: (zoomer instVarNamed: #assumedZoomLabel) label
		equals: (zoomer scaleModel estimatedOSZoomFor: zoomer scaleModel assumedDPI) asString , ' %'.
	self assert: zoomer targetZoomDropList items equals: zoomer scaleModel availableTargetZoomPercentages.
	self assert: zoomer targetZoomDropList selectedItem equals: zoomer scaleModel currentEffectiveZoomPercentage
]

{ #category : 'tests' }
OPZoomerTest >> testResetButtonDoesNotExist [

	self denyCollection: OPZoomer allSelectors includesAny: #( #resetButton #resetZoom )
]

{ #category : 'tests' }
OPZoomerTest >> testSettingsDeclarationRegistersButtonUnderAppearance [

	| settingMethods builder settingNode |
	settingMethods := OPZoomer class methods select: [ :eachMethod | (eachMethod pragmaAt: #systemsettings) isNotNil ].
	self assert: settingMethods size equals: 1.
	builder := SettingTreeBuilder new.
	OPZoomer settingsOn: builder.
	self assert: builder nodeList size equals: 1.
	settingNode := builder nodeList first.
	self assert: settingNode parentName equals: #appearance.
	self assert: settingNode item name equals: #open.
	self assert: settingNode item target identicalTo: OPZoomer
]

{ #category : 'tests' }
OPZoomerTest >> testTargetZoomDropListPrefillsCurrentZoom [

	| customModel |
	customModel := OPDisplayScaleModel new.
	customModel backendBaseDPI: 96.0.
	customModel diagonalDPI: 120.0 horizontalDPI: 120.0 verticalDPI: 120.0.
	zoomer := OPZoomer new.
	zoomer scaleModel: customModel.
	self assertCollection: zoomer targetZoomDropList items includesAll: #( 125 ).
	self assert: zoomer targetZoomDropList selectedItem equals: 125
]

{ #category : 'tests' }
OPZoomerTest >> testWindowTitle [
	zoomer := OPZoomer new.
	window := zoomer asWindow.
	self assert: window title equals: zoomer title.
	self deny: window title equals: 'Unnamed Window'
]

{ #category : 'running' }
OPZoomerTest >> withMorphicUIProcessPausedDo: aBlock [

	| enteredSemaphore releaseSemaphore isCancelled |
	self canPauseMorphicUIProcess ifFalse: [ ^ aBlock value ].
	enteredSemaphore := Semaphore new.
	releaseSemaphore := Semaphore new.
	isCancelled := false.
	self currentWorld defer: [
			isCancelled ifFalse: [
					enteredSemaphore signal.
					releaseSemaphore wait ] ].
	(enteredSemaphore waitTimeoutSeconds: 2) ifTrue: [
			isCancelled := true.
			releaseSemaphore signal.
			^ aBlock value ].
	^ [
		  PausedOwnerProcess := Processor activeProcess.
		  aBlock value ] ensure: [
			  PausedOwnerProcess == Processor activeProcess ifTrue: [ PausedOwnerProcess := nil ].
			  releaseSemaphore signal ]
]
