# ci-scripts

## 概要

GitLab CI/CD 用の再利用可能なテンプレート＆スクリプト集。  
チームやプロジェクト共通のCI設定を簡単に導入できるよう、以下の機能を提供。

- **CHANGELOG 自動生成**（git-cliff 連携）
- **Unity UPM パッケージ自動公開**（npm Registry 連携）
- **プロジェクトリリース自動化**（VERSION.yml をベース）

---

## ディレクトリ構成

```plain
<project-root>/
├─ .gitlab/
│   └─ ci/
│       ├─ config/          ※ CI 設定ファイル (.cliff.toml 等)
│       ├─ templates/       ※ GitLab CI テンプレート
│       │    ├─ changelog/
│       │    ├─ npm/
│       │    └─ release/
│       └─ scripts/         ※ 補助スクリプト
│            ├─ changelog/
│            ├─ npm/
│            └─ release/
├─ .gitlab-ci.yml           ※ メイン CI 定義
└─ その他 (VERSION.yml, CHANGELOG.md など)
```

---

## テンプレート一覧

### CHANGELOG 自動生成

- `changelog/common.yml`  
- `changelog/draft.yml`  
- `changelog/release.yml`  
→ 詳細は各フォルダ内の `README.md` を参照。

### Unity UPM 自動公開

- `npm/npm-publish.yml`  
→ `README_npm-publish.md` を確認。

### プロジェクトリリース自動化

- `release/project-release.yml`  
→ `README_project-release.md` を確認。

---

## スクリプト

- `scripts/changelog/update_for_release.sh`
- `scripts/npm/manage_package_version.sh`
- `scripts/release/generate_release_note.sh`
- `scripts/release/manage_version.sh`

---

## 導入手順

1. プロジェクトのルートに `.gitlab-ci.yml` を作成し、必要なテンプレートを `include` する。
2. GitLab の **Settings > CI/CD > Variables** にて、以下の変数を登録：  
   - `CLIFF_CONFIG_PATH`, `CHANGELOG_FILE`, etc.  
   - `NPM_TOKEN`, `GITLAB_TOKEN`, `CI_JOB_TOKEN` 等
3. ブランチ戦略やジョブトリガーをプロジェクト要件に合わせて調整。
4. CI 実行 → 自動生成／自動公開／自動リリースを確認。

---

## 前提要件

- GitLab Runner (Shell または Docker Executor)
- Bash, `yq`, `jq`, `git`, `git-cliff`, `npm`, `curl` などのツール
- （オプション）`release-cli` for GitLab Release

---

## .gitlab-ci.yml サンプル

```yaml
stages:
  - fetch
  - changelog
  - build
  - test
  - release

variables:
  CLIFF_CONFIG_PATH: "${CI_PROJECT_DIR}/.gitlab/ci/config/.cliff.toml"
  CHANGELOG_FILE: "CHANGELOG.md"

include:
  - project: "LineSimulation/unity-npm/ci-scripts"
    ref: "feature/add-ci-templates"
    file: "/.gitlab/ci/templates/fetch/fetch-ci.yml"
  - project: LineSimulation/unity-npm/ci-scripts
    ref: feature/add-ci-templates
    file: /.gitlab/ci/templates/changelog/common.yml
  - project: LineSimulation/unity-npm/ci-scripts
    ref: feature/add-ci-templates
    file: /.gitlab/ci/templates/npm/npm-publish.yml
  - project: LineSimulation/unity-npm/ci-scripts
    ref: feature/add-ci-templates
    file: /.gitlab/ci/templates/release/project-release.yml

changelog:
  stage: changelog
  script:
    - scripts/changelog/update_for_release.sh
  only:
    refs:
      - main

build:
  stage: build
  script:
    - echo "Build step placeholder"

test:
  stage: test
  script:
    - echo "Test step placeholder"

release:
  stage: release
  script:
    - scripts/release/manage_version.sh
  only:
    refs:
      - tags
```
