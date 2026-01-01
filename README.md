# Password Manager

A modern password management application built with Rails 8, Vue 3, and Materialize CSS.

## Tech Stack

- **Rails 8.1.1** - Backend framework
- **Vue 3** - Frontend framework with Composition API
- **Materialize CSS** - Material Design UI framework
- **PostgreSQL** - Database
- **Vite** - Fast build tool and dev server
- **Hotwire** - Turbo & Stimulus for reactive features

## Prerequisites

- Ruby 3.3.5 or higher
- Node.js 22.1.0 or higher
- PostgreSQL 9.3 or higher
- Foreman (for running dev server)

## Getting Started

### Installation

1. Install dependencies:
```bash
bundle install
npm install
```

2. Create and setup the database:
```bash
rails db:create
rails db:migrate
```

### Development

Start the development server:
```bash
bin/dev
```

This will start both the Rails server (port 3000) and Vite dev server.

Visit [http://localhost:3000](http://localhost:3000) to see the application.

### Project Structure

- `app/javascript/entrypoints/` - Vite entry points
- `app/javascript/components/` - Vue 3 components (.vue files)
- `app/javascript/controllers/` - Stimulus controllers
- `config/database.yml` - PostgreSQL configuration
- `vite.config.mts` - Vite configuration

### Vue Components

Vue components are automatically registered from `app/javascript/components/`. To create a new component:

1. Create a `.vue` file in `app/javascript/components/`
2. Use it in your ERB views with `<ComponentName />`

### Materialize CSS

Materialize CSS is globally available. The framework is auto-initialized on page load. You can access it in Vue components via `this.$M`.

## Running Tests

```bash
rails test
rails test:system
```

## Deployment

This app is configured with Kamal for deployment. See `config/deploy.yml` for deployment configuration.
