# Baby Care Card (Android and iOS)

The mobile app for [Baby Care Cards](https://babycarecards.com). A parent builds one care card for a babysitter, nanny, grandparent or daycare: feeding, naps and bedtime, medication, allergies, emergency contacts and the pediatrician. They can share it, print it as a PDF, or show a QR code at the door.

It's built in Flutter, modelled on the Pet Care Card app.

- Voice fill (`lib/features/voice/`): the phone turns speech into text on the device and posts only the transcript to `https://babycarecards.com/api/public/voice/parse`. The website parses it with the same AI parser it uses itself, so the AI key stays on the server. The parent reviews every field before anything is saved. Parents get 2 free voice fills, then the lifetime unlock. If the server can't be reached, a basic offline parser fills in the name, age group, allergies and personality.
- Premium: a one-off lifetime in-app purchase, `baby_care_card_lifetime`. It unlocks unlimited children, PDF export and unlimited voice fill.
- Data stays on the device (sqflite).

IDs: Android `com.techfaculty.babycarecard`, iOS `com.techfaculty.babycarecard`. There's no underscore because Apple rejects underscores in bundle IDs.

```
flutter pub get
flutter test
flutter build appbundle   # needs android/key.properties for release signing
flutter build ipa
```
