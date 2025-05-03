# 📘 README.md – Unity UPM 自動公開テンプレート (`npm-publish.yml`)

## 🚀 概要

このテンプレートは、**Unity カスタムパッケージ (UPM形式)** を  
**GitLab の npm Registry** に自動で publish するための GitLab CI/CD ワークフローです。

---

## 🛠️ 主な機能

- 🔄 Unityパッケージ (`Assets/<name>`) を `dist/` に自動整形
- 🧠 `package.json` の `versionBumpHint` に基づき、自動でバージョンを更新
- 🚫 Registry上のバージョンと競合がある場合は、自動でCIを中断
- 📤 GitLab npm Registry への publish を自動実行
- 🏷️ 成功時には `git tag vX.Y.Z` を自動作成・Push
- 🔐 `.npmrc` をCI内で一時生成・削除、安全にトークン管理
- ✅ すべて main ブランチへの Push をトリガーに自動化

---

## 🧠 導入メリット

| 視点 | メリット例                                                                                         |
| ---- | -------------------------------------------------------------------------------------------------- |
| 設計 | **リリース手順の標準化と共通化**ができる。誰が導入しても同じ運用ができ、設計上の一貫性が保たれる。 |
| 品質 | **誤ったリリースや上書きのリスクを防止**する。タグ付きの履歴管理でトレーサビリティも明確になる。   |
| 工数 | CI/CDの自動化により、手動での**リリース作業工数を削減**。開発者の負担を極小化できる。              |

---

## 🧩 ステージ構成

| ステージ  | 説明                                                                       |
| --------- | -------------------------------------------------------------------------- |
| `fetch`   | 最新のGitLab CI設定を読み込み、`.gitlab`に格納する                         |
| `prepare` | パッケージファイル（Runtime, Editor等）を `dist/` に整形して配置           |
| `prepare` | publish済みの最新バージョンと比較し、必要に応じて自動で `patch`以上を bump |
| `update`  | CHANGELOGを最新バージョンで更新し、`main`ブランチへにコミット、push        |
| `release` | 認証、`npm publish` 実行、`git tag`の自動追加、`.npmrc` の安全な削除       |

---

## 📁 プロジェクト構成例

```text
<project-root>/
├─ .gitlab/
│   └─ ci/
│        ├─ scripts/
|        |   └─ npm/
│        │       └─ manage_package_version.sh
│        └─ templates/
│            └─ mpm/
│                └─ npm-publish.yml
├─ Assets/
│   └─ my-package-name/
|        ├─ Runtime/
|        ├─ Editor/
|        ├─ Tests/
|        └─ package.json
├─ .gitlab-ci.yml
├─ README.md
└─ CHANGELOG.md
```

---

## 🔐 必要な CI/CD 変数

GitLab の `Settings > CI/CD > Variables` に以下を登録してください：

| 変数名            | 内容                             | 備考                                                 |
| ----------------- | -------------------------------- | ---------------------------------------------------- |
| `NPM_TOKEN`       | npm publish 用のアクセストークン | 🔒 Masked ✅ 必須<br>🔑 write_package_registry 権限必須 |
| `CI_PACKAGE_NAME` | npm パッケージ名称               |                                                      |

---

## ✅ 導入手順（プロジェクトに組み込む）

1. `.gitlab-ci.yml` をプロジェクトルートに追加してください。
2. `PACKAGE_NAME`, `PUBLISH_SOURCE_DIR`, `DIST_DIR` など必要に応じて変更してください。
3. 必要な CI/CD 変数を設定してください。
4. `main` ブランチへの push をトリガーにCIが実行されます。
5. CIが成功すると、GitLabのnpm Registryに自動でパッケージが公開されます。

---

## 🔁 Version管理ロジック

| 条件                   | 処理内容                                                                                                                    |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| npm Registry 未登録    | `package.json` の `version` をそのまま使用する。                                                                            |
| Local Version が新しい | `package.json` の `version` をそのまま使用する。                                                                            |
| Local Version が同じ   | `versionBumpHint` に従い、`patch/minor/major` を自動インクリメントする。指定がない場合は、`patch`を自動インクリメントする。 |
| Local Version が古い   | エラー終了（Version 競合と判断）                                                                                            |

### `versionBumpHint` の使用例

```json
{
   "name": "my-package-name",
   "version": "1.2.3",
   "versionBumpHint": "minor" // patch / minor / major
}
```

> [!NOTE]:  
> ⚙️ ヒントが未指定の場合、`patch` がデフォルトで適用されます。

---

## 🏷️ Gitタグ管理

publish 成功時には、自動的に以下を実行：

- `git tag vX.Y.Z`
- `git push -o ci.skip origin vX.Y.Z`
- `-o ci.skip` オプション付きでプッシュし、CI のループを防止  

これにより、**パッケージのバージョンとGitの履歴が一致**します。

---

## 📎 関連ファイル

- `.gitlab-ci.yml`
- `.gitlab/ci/templates/npm/npm-publish.yml`
- `.gitlab/ci/scripts/npm/manage_package_version.sh`

---

## 💬 補足・運用Tips

- `.npmrc` は CI内で一時的に作成＆削除されるため、Access Tokenの漏洩の心配はありません。
- もし複数パッケージに対応する場合、各 `Assets/<package>` ごとにCI分割構成がおすすめです。
- `CHANGELOG.md` なども git-cliff などで自動生成連携可能です（オプション構成あり）

---
