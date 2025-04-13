# npm-publish-smart CI テンプレート（v2）

このテンプレートは、**Unityカスタムパッケージ（UPM形式）**を GitLab Package Registry に自動で `npm publish` するための **スマートCIテンプレート**です。

## ✅ 特徴

- `main` ブランチ更新時のみ動作
- `package.json.version` が既に公開済みなら `patch` バージョンを自動でインクリメント
- 開発者が `versionBumpHint` フィールドで `minor` / `major` 指定も可能
- `npm publish` → `git tag` → `package.json` 更新コミットまで一括自動化
- **publish 成功後は `versionBumpHint` を自動削除**（意図しない再バンプ防止）

---

## ✅ 使用方法

プロジェクトルートの `.gitlab-ci.yml` に以下を記述：

```yaml
include:
  - local: ".gitlab/ci/templates/npm-publish-smart.yml"
```

---

## ✅ 前提となるディレクトリ構成

```text
<project-root>/
├── Assets/
│   └── UIkit/               # Unity開発中のパッケージ実体
├── UIkit/
│   └── package.json         # UPM形式のpackage.json
├── README.md
├── CHANGELOG.md
└── .gitlab/
    └── ci/
        └── templates/
            └── npm-publish-smart.yml
```

---

## ✅ 利用できる変数（必要に応じて `.gitlab-ci.yml` で上書き可）

| 変数名               | 用途                                 | デフォルト値         |
| -------------------- | ------------------------------------ | -------------------- |
| `PACKAGE_JSON_PATH`  | publish対象のpackage.jsonパス        | `UIkit/package.json` |
| `PUBLISH_SOURCE_DIR` | コピー元のUnityパッケージフォルダ    | `Assets/UIkit`       |
| `DIST_DIR`           | 一時作業フォルダ                     | `dist`               |
| `NPM_REGISTRY_URL`   | GitLabのNPM Registryエンドポイント   | 要プロジェクトID指定 |
| `NPM_TOKEN`          | GitLabのAccess Token（CI変数で指定） | **必須**             |

---

## ✅ `versionBumpHint` の使い方

`package.json` に以下を追加すると、自動でバージョン種別を切り替えて bump できます：

```json
{
  "version": "1.2.3",
  "versionBumpHint": "minor"
}
```

| 値                  | 結果            |
| ------------------- | --------------- |
| `"patch"`（省略時） | `1.2.3 → 1.2.4` |
| `"minor"`           | `1.2.3 → 1.3.0` |
| `"major"`           | `1.2.3 → 2.0.0` |

**このフィールドは publish 後に自動削除されます。**

---

## ✅ 処理の流れ（ステージ構成）

| ステージ  | 処理内容                                                                |
| --------- | ----------------------------------------------------------------------- |
| `prepare` | package.json 存在確認、dist作成、必要ファイルコピー                     |
| `check`   | GitLab Registryに既存version照会、必要なら bump、`versionBumpHint` 削除 |
| `publish` | `npm publish`、`git tag`、package.json変更があれば commit & push        |

---

## ✅ 推奨 CI/CD 環境変数設定（GitLab）

| 変数名      | 用途                                                      | スコープ設定           |
| ----------- | --------------------------------------------------------- | ---------------------- |
| `NPM_TOKEN` | GitLabのPersonal Access Token（`write_package_registry`） | **Protected + Masked** |

---

## ⚠️ 注意点・運用補足

- `versionBumpHint` は **あくまで "ヒント"** であり、実行時のバージョンによっては意図通りにならないこともあります（特に publish 済verが更新されている場合）
- `CHANGELOG.md` や `README.md` の自動生成・同期は対応していません（将来対応可）
- 複数パッケージを同時に publish する構成には未対応です（必要なら分割導入）

---

## 📌 補足Tips

- Unityの `manifest.json` 側は `@scope/package` として利用してください
- 本テンプレートは Unity UPM + GitLab Private Registry に最適化されています

--

## 🛠️ 拡張したい場合の方向性

| 機能                     | 拡張方法例                                   |
| ------------------------ | -------------------------------------------- |
| `CHANGELOG.md` 自動生成  | `git cliff`, `git log` の組込                |
| スコープ切り替え運用     | `NPM_REGISTRY_URL` を変数で切替対応          |
| 複数パッケージの一括管理 | `.bump` ファイル or モノレポ対応CIに分岐設計 |

---
