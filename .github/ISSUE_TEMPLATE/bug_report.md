---
name: Bug report
about: Create a report to help us improve
title: "BUG : <Title>"
labels: bug, open source
assignees: pallabmaiti
---

**Describe the bug**
Please provide the following information:

1. A clear and concise description of what the bug is
2. Share the event payload
3. Offer a minimal viable example to reproduce the issue
4. Indicate if the SDK is being initialized or events are being created on a separate thread or coroutine apart from the main thread
5. Specify if the issue is specific to a particular device model or OS version
6. Include the error's stack trace
7. Mention the date when the issue began

**To Reproduce**
Steps to reproduce the behaviour:

1. Initialise iOS SDK
2. Make events '....'
3. See the error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Version of the _iOS_ SDK**
Please mention the version of the Rudder iOS SDK you are using (e.g., iOS SDK v1.0.0).

**Mobile device mode integration**
Please provide the following information:

1. `Name` and `version` of the mobile device mode integration (e.g., RudderAmplitude iOS v1.0.0 mobile device mode integration)
2. Indicate if you are using the native SDK directly and specify its version (e.g., Amplitude native iOS SDK v2.0.0)

**SDK initialisation snippet**
Please provide the following information:

1. Share the code snippet used for initializing the iOS SDK
2. Indicate if the SDK initialization depends on any specific condition or event (e.g., initialization of the iOS SDK after Firebase initialization or initialization in a callback)

**Check for Correct Usage of _writeKey_ and _dataPlaneUrl_**
Confirm that the correct `writeKey` and `dataPlaneUrl` are utilized during SDK initialization.
