# 📘README – GitLab Release 自動化テンプレート** (`project-release.yml`)

## 🚀 概要

このテンプレートは、`VERSION.yml` を元にプロジェクトのバージョンを自動 bump し、`CHANGELOG.md` を更新、さらに GitLab Releases を作成する GitLab CI/CD ワークフローです。  
各ステージを連携させることで、リリース作業を完全自動化します。

---

## 🛠️ 主な機能

- 🔄 `VERSION.yml` の内容に応じたバージョン bump と `.next_version` ファイル生成  
- 📝 `CHANGELOG.md` の自動更新＆コミット・プッシュ  
- 🏷️ 新バージョンへの Git タグ作成＆プッシュ  
- 🚀 GitLab Release の自動生成（Tag と CHANGELOG を説明文に利用）  
- 🔒 `release-cli` による安全なリリース作成 citeturn0file0

---

## 🧩 ステージ構成

| ステージ  | 説明                                               |
| --------- | -------------------------------------------------- |
| `fetch`   | 最新のGitLab CI設定を読み込み、`.gitlab`に格納する |
| `prepare` | `VERSION.yml` を読み込み、バージョンを計算・更新   |
| `update`  | `.next_version` を参照して `CHANGELOG.md` を更新   |
| `release` | タグ作成後、`release-cli` で GitLab Release を生成 |

---

## 📁 プロジェクト構成例

```text
<project-root>/
├─ .gitlab/
│   └─ ci/
│        ├─ scripts/
│        │    ├─ changelog/
│        │    |    └─ update_for_release.sh
│        │    └─ release/
│        │         ├─ generate_release_note.sh
│        │         └─ manage_version.sh
│        └─ templates/
│            └─ release/
│                └─ project-release.yml
├─ VERSION.yml
├─ CHANGELOG.md
└─ .gitlab-ci.yml
```

---

## 🔐 必要な CI/CD 変数

GitLab の **Settings > CI/CD > Variables** に以下を登録してください：

| 変数名         | 内容                                    | 備考                              |
| -------------- | --------------------------------------- | --------------------------------- |
| `GITLAB_TOKEN` | Personal Access Token（`api` スコープ） | `CI_JOB_TOKEN` 権限不足時に使用   |
| `CI_JOB_TOKEN` | GitLab が自動で提供するトークン         | デフォルトで `release-cli` が利用 |

---

## ⚙️ 導入手順

1. `.gitlab-ci.yml` をプロジェクトルートに追加してください。
2. 必要に応じて変数（`VERSION_FILE`, `CHANGELOG_FILE` など）を調整  
3. 上記 CI/CD 変数を設定  
4. `main` ブランチへの Push で自動実行  
5. 成功すると、GitLab Release と Git タグが作成されます 🎉

---

## 🔁 バージョン管理ロジック

| 条件                               | 処理内容                                                            |
| ---------------------------------- | ------------------------------------------------------------------- |
| 既存の Release タグが存在しない    | `VERSION.yml` の `version` をそのまま使用                           |
| ローカル `version` が最新          | `VERSION.yml` の `version` をそのまま使用                           |
| ローカル `version` == Release タグ | デフォルトで `patch` を自動インクリメント（`major`/`minor` 指定可） |
| ローカル `version` が古い          | エラー終了（Version 競合と判断）                                    |

### `VERSION.yml` の使用例

```yaml
version: 1.2.3
version_bump_hint: patch # patch, minor, major のいずれかを指定
```

>[!NOTE]:
> `version_bump_hint` を指定しない場合、デフォルトで `patch` が使用されます。

---

## 🏷️ Git タグ管理

- 成功時に `git tag vX.Y.Z` を実行  
- `-o ci.skip` オプション付きでプッシュし、CI のループを防止  

---

## 📎 関連ファイル

- `.gitlab-ci.yml`
- `.gitlab/ci/templates/fetch/fetch-ci.yml`
- `.gitlab/ci/templates/project-release.yml`  
- `.gitlab/ci/scripts/changelog/update_for_release.sh`  
- `.gitlab/ci/scripts/release/manage_version.sh`  
- `.gitlab/ci/scripts/release/generate_release_note.sh`  

---

## 💡 運用 Tips

- `CHANGELOG_FILE` がデフォルトと異なる場合は、変数 `CHANGELOG_FILE` を追加設定  
- 手動実行を許可したいジョブには `.default_rules` をカスタマイズ  
- リリースノート生成は `git-cliff` 等と組み合わせるとさらなる自動化が可能  

---
