# Arquitetura — Resolve Aí

Monólito **Rails 8** (HTML Phlex/RubyUI + JSON na mesma app). Sem SPA, sem Redis/Sidekiq, sem tenancy. PostgreSQL 16 no Docker; uploads no disco via Active Storage.

```mermaid
flowchart TB
  subgraph clients [Clientes]
    Browser[Browser HTML]
    ApiClient[Cliente API JSON]
  end

  subgraph rails [Rails 8 monólito]
    Router[config/routes.rb]

    subgraph http [Camada HTTP]
      HtmlCtrl["Controllers HTML\nOccurrences Dashboard Comments"]
      ApiCtrl["API v1 JSON\nSessions Occurrences Dashboard"]
      DeviseCtrl[Devise Sessions Registrations]
    end

    subgraph security [Auth e autorização]
      Warden[Warden Devise]
      CurrentUser[current_user + role]
      Pundit[Pundit Policies]
    end

    subgraph app [Regras de negócio]
      Transition["Occurrences::TransitionStatus"]
      Assign["Occurrences::AssignResponsible"]
      Rate["Occurrences::SubmitRating"]
    end

    subgraph models [ActiveRecord]
      User[User]
      Occurrence[Occurrence]
      Comment[Comment]
      Event[OccurrenceEvent]
      Attachment[ActiveStorage Attachment]
    end
  end

  subgraph persist [Persistência local]
    PG[(PostgreSQL 16 Docker)]
    Disk[Disco local uploads]
  end

  Browser --> Router
  ApiClient --> Router
  Router --> HtmlCtrl
  Router --> ApiCtrl
  Router --> DeviseCtrl
  DeviseCtrl --> Warden
  HtmlCtrl --> Warden
  ApiCtrl --> Warden
  Warden --> CurrentUser
  HtmlCtrl --> Pundit
  ApiCtrl --> Pundit
  Pundit --> CurrentUser
  HtmlCtrl --> Transition
  HtmlCtrl --> Assign
  HtmlCtrl --> Rate
  ApiCtrl --> Transition
  ApiCtrl --> Assign
  ApiCtrl --> Rate
  Transition --> Occurrence
  Transition --> Event
  Assign --> Occurrence
  Assign --> Event
  Rate --> Occurrence
  HtmlCtrl --> Comment
  ApiCtrl --> Comment
  Occurrence --> User
  Occurrence --> Attachment
  Comment --> User
  Event --> User
  User --> PG
  Occurrence --> PG
  Comment --> PG
  Event --> PG
  Attachment --> PG
  Attachment --> Disk
```

## Papéis

| Papel no código | Perfil | Como nasce |
| --------------- | ------ | ---------- |
| `requester` | Solicitante | Cadastro público (tela `GET /users/sign_up`, envio `POST /users`) sempre força esse papel |
| `manager` | Gestor | Seed (`manager@resolve.ai`) ou console |

## Enums (código / interface)

O domínio usa chaves em inglês no banco; a UI pt-BR traduz.

| Campo | Valores |
| ----- | ------- |
| Status | `open` (aberta), `in_analysis` (em análise), `in_progress` (em atendimento), `resolved` (resolvida), `cancel` (cancelada) |
| Prioridade | `low`, `medium` (padrão), `high`, `urgent` — só gestor altera |
| Categoria | `lighting`, `equipment`, `accessibility`, `cleaning`, `leakage`, `security`, `maintenance`, `other` |

## Testes

- **RSpec** + FactoryBot (modelos, policies, serviços, requests HTML/JSON, componentes): `bundle exec rspec`
