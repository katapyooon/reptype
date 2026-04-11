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

## RAG構成図（reptype-chat）

S3に保存された爬虫類に関する文書をもとに、RAGを用いてユーザーの質問に回答するチャット機能の概要です。

```mermaid
flowchart TD
    subgraph 事前処理
        S3[(S3\n文書ストレージ)] --> Loader[文書の読み込み]
        Loader --> Chunker[チャンキング]
        Chunker --> Embedder[Embedding 生成]
        Embedder --> VectorDB[(ベクトルDB)]
    end

    subgraph 回答生成
        User([ユーザー]) --> Query[質問入力]
        Query --> QueryEmbed[Embedding 生成]
        QueryEmbed --> Search[類似検索]
        VectorDB --> Search
        Search --> Context[関連文書の取得]
        Context --> LLM[LLM]
        Query --> LLM
        LLM --> Answer[回答]
        Answer --> User
    end
```

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

    questions ||--o{ answers : "has many"
    types ||--o{ results : "has many"
```
