This document outlines the versioning strategy for major, minor, and patch releases of the chart and Lightrun, detailing how and when version numbers should be updated.

## Major Releases

Major releases indicate significant changes that can impact functionality or require users to take action for upgrades. We update the major version number for the following:

- The introduction of new features or large-scale modifications (e.g., introduce Lightrun Router).
- Breaking changes in the chart or Lightrun that necessitate manual intervention for upgrading existing installations.
- Major Lightrun image updates, such as the release of a new major version (e.g., Lightrun 2.0.0).

## Minor Releases

Minor releases typically align with minor version updates of the Lightrun image, as well as updates made to the chart. These releases are triggered by:

- Updates to Lightrun’s minor version.
- Changes to default values in the chart that may result in higher resource consumption (e.g., additional pods or services).
- Functional improvements or additions that warrant greater visibility but don't require a major version bump.

## Patch Releases

Patch releases consist of stable fixes or small improvements to previous versions. These updates should not cause disruption and are typically related to:

- Patch updates to the Lightrun image.
- Any minor changes or fixes that don't necessitate a major or minor version update.