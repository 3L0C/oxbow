# Changelog

All notable changes to this project will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-08-27

### Fixed

- Ambiguous arguments for seemingly valid commands like
  `oxctl bind layout tiling mfact -0.05 to Super+Control+h`
  failed as `-0.05` was interpreted as an option.
- Missing commands in the `oxctl` man page.

### Changed

- Nix packaging to allow for non-flake installs.
- Clarify and correct each Nix based installation method.

## [0.1.0] - 2026-08-19

Initial documented release.

[0.1.1]: https://github.com/3L0C/oxbow/compare/v0.1.0...v0.1.1
