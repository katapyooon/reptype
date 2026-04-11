# reptype

**URL:** https://16reptype.com

## サービス概要

質問に答えるだけで、自分の性格タイプを診断できるWebサービスです。

複数のカテゴリにわたる設問に回答すると、スコアに基づいて、16種類の中からあなたの性格に合った爬虫類タイプを診断します。診断結果ではタイプの特徴や説明を確認できます。

## 使用技術

- **バックエンド:** Ruby on Rails
- **データベース:** PostgreSQL（Amazon RDS）
- **インフラ:** AWS（ECS Fargate / RDS / Route53）
- **IaC:** Terraform

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
