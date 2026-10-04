"
Baseline for https://github.com/OpenPonk/zoomer
"
Class {
	#name : 'BaselineOfOpenPonkZoomer',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfOpenPonkZoomer-Baseline',
	#package : 'BaselineOfOpenPonkZoomer',
	#tag : 'Baseline'
}

{ #category : 'baselines' }
BaselineOfOpenPonkZoomer >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			spec package: 'OpenPonk-Zoomer'.
			spec group: 'default' with: #('OpenPonk-Zoomer') ]
]
