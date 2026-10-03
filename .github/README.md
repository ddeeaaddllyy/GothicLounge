## Noctis

This build is for **iOS Simulator**. It is not a signed IPA and cannot be installed on a physical iPhone or uploaded to TestFlight.

Extract `Noctis-Simulator.zip`, boot an iOS Simulator, then run:

```sh
xcrun simctl install booted GothicLounge.app
xcrun simctl launch booted ddeeaaddllyy.GothicLounge
```

Domain tests, UI tests and a Release build must succeed before this draft is created. Review the generated changelog before publishing.
