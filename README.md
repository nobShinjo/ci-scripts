# 🚀 CI-Scripts: GitLab CI

## 📖 概要 Summary

 `.gitlab-ci-sample.yml` を `.gitlab-ci.yml` として登録することで、常に GitLab CI の最新スクリプト、最新テンプレートを簡単にインポートできるようにするためのリポジトリです。

## ✨ 機能 Features

* 🚀 最新の GitLab CI 設定をワンクリックでインポート
* 📂 ステージごとに分割されたテンプレート（fetch／bump／release／changelog）
* 🔄 テンプレートの再利用性・可読性を向上
* 🛠 必要に応じてカスタマイズ可能なサンプル CI 定義

## 🛠 使用方法 Usage

1. 📥 レポジトリをクローン

   ```bash
   git clone -b feature/add-ci-templates https://github.com/nobShinjo/ci-scripts.git
   ```

2. 🔄 プロジェクトのルートに移動し、
   `.gitlab-ci-sample.yml` を `.gitlab-ci.yml` にコピー

   ```bash
   cp .gitlab-ci-sample.yml your-project/.gitlab-ci.yml
   ```

3. ⚙️ GitLab の **CI/CD > Variables** に必要な環境変数／トークンを登録
4. ✅ コミット＆プッシュして、CI パイプラインが正常に動作することを確認

## 📁 ディレクトリ構成 Directories

```plane
.
├── .gitlab-ci-sample.yml       # サンプル CI 定義
├── .gitlab
│   └── ci
│       └── templates
│           ├── fetch          # 初期フェッチ用テンプレート
│           ├── bump           # バージョンバンプ用テンプレート
│           ├── release        # リリース用テンプレート
│           └── changelog      # Changelog 生成テンプレート
└── README.md                   # この README
```

## 🔧 必要要件 Required

* GitLab CI/CD が有効なプロジェクト
* Node.js（≥14）＆ npm
* Docker Engine
* Verdaccio（社内 npm レジストリ）
* GitLab Runner ※任意

### 🔑 GitLab CI変数

* 🌐 `NPM_REGISTRY_URL` : Verdaccio レジストリの URL
* 🔀 `CI_DEFAULT_BRANCH`: デフォルトブランチ名（例: `main`）

### 🛡 GitLab Access Token

* `GITLAB_ACCESS_TOKEN` : GitLab API（read\_api）にアクセスするためのパーソナルアクセストークン

### 🔑 Verdaccio Access Token

* `NPM_TOKEN` : Verdaccio レジストリへの publish 認証トークン

---
