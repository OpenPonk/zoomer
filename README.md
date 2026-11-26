# Zoomer

[![Nightly](https://github.com/OpenPonk/zoomer/actions/workflows/nightly.yml/badge.svg)](https://github.com/OpenPonk/zoomer/actions/workflows/nightly.yml) [![Coverage Status](https://coveralls.io/repos/github/OpenPonk/zoomer/badge.svg?branch=main)](https://coveralls.io/github/OpenPonk/zoomer?branch=main)

Tool for selecting sharp UI zoom levels in Pharo when the operating system uses non-integer display scaling (such as 150%).

## Installation

See [openponk.org/#direct-installation](https://openponk.org/#direct-installation) for the supported Pharo version.

```smalltalk
Metacello new
	baseline: 'OpenPonkZoomer';
	repository: 'github://OpenPonk/zoomer:main';
	load.
```

## Usage

```smalltalk
OPZoomer open
```

## Documentation

Part of the [OpenPonk](https://openponk.org) platform. For architecture, the repository catalog, and contributing guidelines, see [`OpenPonk/.github`](https://github.com/OpenPonk/.github/blob/main/profile/README.md).
