# fdroiddata App inclusion — 最终 MR（按官方模板）

## Title

```
New app: LedgerLearn
```

## Description

```markdown
## Checklist

### Policy

* [x] The app complies with the [inclusion criteria](https://f-droid.org/docs/Inclusion_Policy).
* [x] The original app author has been notified (and does not oppose the inclusion). If you are not the author, please paste the link of the reply from the author.
      I am the upstream author (GitHub: Maicarons).
* [x] The upstream app source code repo contains the app metadata in a [Fastlane](https://gitlab.com/snippets/1895688) folder structure. The summary and description must be included and images, icon, and changelog should also be provided for better user experience. The `en-US` locale must be included.
      See `fastlane/metadata/android/en-US/` and `zh-CN/` in the upstream repo (title, short/full description, icon 512x512, phoneScreenshots, changelogs/4.txt).

### Docs

* [x] Please read [the guide](https://gitlab.com/fdroid/fdroiddata/-/blob/master/CONTRIBUTING.md) first if this is your first contribution.
* [x] Please make sure your metadata follows the best practice in [our templates](https://gitlab.com/fdroid/fdroiddata/tree/master/templates).
      Based on `templates/build-flutter.yml` (Flutter srclib).
* [x] Please read the [Build Metadata Reference](https://f-droid.org/docs/Build_Metadata_Reference/) and make sure your metadata is valid.
* [x] Please read the [Quick Start Guide](https://f-droid.org/en/docs/Submitting_to_F-Droid_Quick_Start_Guide/).

### Merge Request Setup

* [x] The title of this merge request should follow "New app: app name" format.
* [x] Please make sure your fdroiddata fork is public and your branch is not protected.
* [x] Please read [our Git guide](https://gitlab.com/fdroid/wiki/-/wikis/Tips-for-fdroiddata-contributors/Git-Usage) if you don't know how to rebase your branch. Don't rebase your branch if there is no conflict.
* [x] All related [fdroiddata](https://gitlab.com/fdroid/fdroiddata/issues) and [RFP issues](https://gitlab.com/fdroid/rfp/issues) have been referenced in this merge request
      No pre-existing RFP/issue for this app. Related previous MR !50014 was closed for not following the template; this MR replaces it and follows the App inclusion template.
* [x] Please only submit one app in one MR.

### Metadata

* [x] Metadata must be put in `metadata/<applicationId>.yml`.
      File: `metadata/cn.yosvu.ledgerlearn.yml`
* [x] Metadata must be a valid YAML file.
* [x] Metadata must use LF as line ending.
* [x] Don't add summary/description/changelog/images or anything that should be provided in upstream repo. Please check the Changes tab to make sure there is no other unrelated files added in the MR.
      Only `metadata/cn.yosvu.ledgerlearn.yml` is added.
* [x] Releases are tagged and auto update is enabled unless there is a special reason.
      Tagged releases on GitHub (latest `v0.3.0`); `UpdateCheckMode: Tags` / `AutoUpdateMode: Version`.
* [x] There is an issue tracker and contact info of the author so that we can report bugs and contact the author.
      IssueTracker: https://github.com/Maicarons/ledgerlearn/issues · AuthorName: Maicarons
* [x] An AuthorName must be added. It doesn't need to be the real name.
* [x] External repos are added as git submodules instead of srclibs. You can update git submodules without opening an MR in this repo and the submodule is covered by our scanner.
      No external repos. Flutter is provided via srclib `flutter@stable` per `templates/build-flutter.yml`.
* [ ] Enable [Reproducible Builds](https://f-droid.org/docs/Reproducible_Builds). We'll use your signature for improved security/reliability, also allowing users to switch between different channels. Do note that if you don't enable reproducible build then the apk will be signed with our key so you can't enable it later. If you can't enable this, please add the reasons here.
      Not enabled for this first release: Flutter/Pub toolchains still produce non-bit-identical artifacts across hosts; I can work with packagers on reproducible setup in a follow-up if desired.
* [ ] Setup abi split if the APK is large and the splitted ones can be much smaller.
      Single universal APK for first release; can add `--split-per-abi` blocks if size is a concern.
* [x] Only the latest versions should be kept in the metadata before it's merged. If you update the metadata, please replace the old versions with the new ones.
* [x] Don't add any disabled versions in the metadata.
* [x] The `commit` field should be the full hash. Please don't use tag or branch in commit.
      `commit: e848fec9639870a602a275b28479e8f4fbf2d37a` (tag `v0.3.0`)

### Pipeline

* [ ] All pipelines should pass.
* [ ] All warnings and errors in the Reports tab should be fixed or explained.
* [ ] F-Droid CI runners are under GitLab's FOSS program, so there's no need for you to pay for any CI time. If Gitlab starts asking for phone numbers or credit cards don't submit anything, just leave a note in the MR so we know we need to trigger the CI.

---

### App info (quick reference)

| Field | Value |
|---|---|
| Name | LedgerLearn |
| Application ID | `cn.yosvu.ledgerlearn` |
| Source | https://github.com/Maicarons/ledgerlearn |
| License | GPL-3.0-only |
| Category | Education |
| Version | 0.3.0 (versionCode 4) |
| Toolchain | Flutter 3.x (`flutter@stable`, checkout `3.41.9`) |
| Output | `build/app/outputs/flutter-apk/app-release.apk` |
```
