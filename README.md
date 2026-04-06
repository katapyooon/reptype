# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

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
