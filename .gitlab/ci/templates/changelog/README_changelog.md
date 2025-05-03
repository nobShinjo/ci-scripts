# 📘 README.md – CHANGELOG自動生成テンプレート (`changelog/draft-changelog.yml`, `changelog/release-changelog.yml`)

## 🚀 概要

このテンプレート群は、`git-cliff` を使って `CHANGELOG.md` のDraftおよび最終版を自動生成・管理する GitLab CI/CD ワークフローです。  

- **Draft生成**: MR や `feature/*` ブランチ向けに未リリース分をプレビューとして生成
- **最終生成**: リリース前に全履歴をもとに最終的な CHANGELOG を出力  

---

## 🛠️ 主な機能

- **共通設定**: Alpine イメージで `git`, `git-cliff`, `bash` をインストールし、CI 用の Git 設定や変数を注入  
- **Draft**:  
  - `--unreleased` オプションで未リリース分の変更履歴を `CHANGELOG.md` に 前方挿入する。
  - マージリクエスト MR かつ、`feature/*` ブランチで自動実行する。
  - `CHANGELOG.md`に差分があればコミット＆プッシュする。
- **Release**:  
  - リモートの `main` ブランチ履歴を元に完全な `CHANGELOG.md` を出力する。  
　- `CHANGELOG.md`に差分があればコミット＆プッシュする。
  - 手動トリガー運用推奨  

---

## 🧩 テンプレート一覧 & ステージ構成

### `changelog/draft-changelog.yml`

| ステージ | 説明                                                                                |
| -------- | ----------------------------------------------------------------------------------- |
| `fetch`  | 最新のGitLab CI設定を読み込み、`.gitlab`に格納する                                  |
| `draft`  | MR または `feature/*` ブランチ向けドラフト生成 (`git-cliff --unreleased --prepend`) |

### `changelog/release-changelog.yml`

| ステージ  | 説明                                                   |
| --------- | ------------------------------------------------------ |
| `fetch`   | 最新のGitLab CI設定を読み込み、`.gitlab`に格納する     |
| `release` | 最終 CHANGELOG 出力 (`git-cliff` 上書き)／手動実行推奨 |

---

## 🔐 必要な CI/CD 変数

| 変数名              | 説明                                                                 | 定義元     |
| ------------------- | -------------------------------------------------------------------- | ---------- |
| `CLIFF_CONFIG_PATH` | `git-cliff` 設定ファイルのパス (例: `.gitlab/ci/config/.cliff.toml`) | common.yml |
| `CHANGELOG_FILE`    | `CHANGELOG.md` のファイル名                                          | common.yml |
| `GIT_AUTHOR_NAME`   | CI 実行ユーザー名                                                    | common.yml |
| `GIT_AUTHOR_EMAIL`  | CI 実行ユーザーメール                                                | common.yml |
| `GIT_DEPTH`         | `0` (全履歴取得)                                                     | common.yml |

---

## 📁 プロジェクト構成例

```text
<project-root>/
├─ .gitlab/
│    └─ ci/
│         ├─ config/
│         │    └─ .cliff.toml
│         ├─ scripts/
│         │    └─ changelog/
│         │         ├─ update_for_release.sh
│         │         └─ generate_release_note.sh
│         └─ templates/
│              └─ changelog/
│                   ├─ draft-changelog.yml
│                   └─ release-changelog.yml
├─ CHANGELOG.md
└─ .gitlab-ci.yml
```

---

## ⚙️ 利用方法

1. `.gitlab/ci/templates/changelog` 以下に `draft-changelog.yml`, `release-changelog.yml` を配置する。
2. プロジェクトのルート `.gitlab-ci.yml` で以下のようにinclude する。

   ```yaml
   include:
     - local: ".gitlab/ci/templates/changelog/common.yml"
     - local: ".gitlab/ci/templates/changelog/draft-changelog.yml"
     - local: ".gitlab/ci/templates/changelog/release-changelog.yml"
   ```  

3. **Draft**: マージリクエスト MR 作成時、かつ `feature/*` ブランチ push で自動実行する。
4. **Release**: 手動トリガーで最終版を生成する。

---

## 💡 運用 Tips

- **Draft** は自動で生成されレビューしやすく、差分がない場合はコミットをスキップ
- **Release** ジョブは手動トリガーを推奨し、不意の上書きを防止  
- `git-cliff` のバージョンや `bash` のログを出力し、CI 環境を可視化  
- `.cliff.toml` のテンプレートはプロジェクト要件に合わせてカスタマイズ可能  

---
