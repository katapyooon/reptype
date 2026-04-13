# reptype

**URL:** https://16reptype.com

## サービス概要

「爬虫類を飼いたいけど、どの種類が自分に合っているかわからない」という初心者向けに、最適な爬虫類をレコメンドするWebサービスです。

いくつかの質問に答えるだけで、生活スタイルや好みに基づいて16種類の中から飼育に向いている爬虫類を提案します。診断結果では、その爬虫類の特徴や飼育のポイントも確認できます。

## 使用技術

- **バックエンド:** Ruby on Rails
- **データベース:** PostgreSQL（Amazon RDS）
- **インフラ:** AWS（ECS Fargate / RDS / Route53）
- **IaC:** Terraform

## チャット機能構成（reptype-chat）

S3に保存された爬虫類に関する文書をもとに、pgvector（PostgreSQL 拡張）と Amazon Bedrock を組み合わせたカスタム RAG でユーザーの質問に回答するチャット機能の概要です。

```mermaid
flowchart TD
    subgraph "事前処理（Ingestion）"
        Doc[爬虫類に関する文書\n.md ファイル] --> S3[(S3\nドキュメントバケット)]
        S3 --> Ingest[Rails\nIngestion サービス]
        Ingest --> Titan1[Bedrock InvokeModel\nTitan Embed Text v2\n埋め込み生成]
        Titan1 --> PG[(PostgreSQL\ndocument_chunks\npgvector)]
    end

    subgraph "回答生成（RAG Query）"
        User([ユーザー]) --> Query[質問入力]
        Query --> Titan2[Bedrock InvokeModel\nTitan Embed Text v2\nクエリ埋め込み生成]
        Titan2 --> Search[pgvector\nコサイン類似度検索]
        PG --> Search
        Search --> Context[関連チャンク取得]
        Context --> Claude[Bedrock InvokeModel\nClaude\n回答生成]
        Claude --> Answer[回答]
        Answer --> User
    end
```

### インフラ構成（Terraform）

| モジュール | リソース | 用途 |
|---|---|---|
| `modules/s3_storage` | S3 バケット | 爬虫類ドキュメントの保管 |
| `modules/iam_bedrock_invoke` | IAM ポリシー | Rails から Bedrock InvokeModel を呼び出す権限 |
| PostgreSQL (既存 RDS) | pgvector 拡張 | ベクトル検索（追加コストなし） |

## E-R図

```mermaid
erDiagram
    questions {
        bigint id PK
        string category
        string content
        integer position
        datetime created_at
        datetime updated_at
    }

    answers {
        bigint id PK
        bigint question_id FK
        integer score
        datetime created_at
        datetime updated_at
    }

    types {
        bigint id PK
        string name
        text description
        string code
        string image_path
        datetime created_at
        datetime updated_at
    }

    results {
        bigint id PK
        string code
        bigint type_id FK
        text summary
        text explanation
        datetime created_at
        datetime updated_at
    }

    document_chunks {
        bigint id PK
        integer reptile_type_id FK
        string source_file
        text content
        vector embedding
        datetime created_at
        datetime updated_at
    }

    questions ||--o{ answers : "has many"
    types ||--o{ results : "has many"
    types ||--o{ document_chunks : "has many"
```
