# Node.js Enterprise Architecture

## Preferred Stack

- Node.js 20+
- TypeScript
- Express or Fastify
- ts-node
- ES Modules
- dotenv
- OpenAPI

## Avoid

- monolithic server files
- callbacks instead of async/await
- mutable global state
- business logic in route handlers
- hardcoded configuration

## Recommended Structure

```
src/
  api/
    routes/
    controllers/
  services/
  repositories/
  models/
  middleware/
  config/
  utils/
  types/
  index.ts
```

### Why this structure?

- Keeps domain features isolated
- Makes reusable behavior easy to share
- Separates infrastructure from presentation
- Enables lazy loading and modular growth

## Scaling Advice

- Use feature modules so new domains can be added without broad refactors
- Keep service boundaries small and focused
- Use lazy loading for large modules
- Prefer encapsulated feature contracts over shared global state

## Production Deployment

- Build artifacts with optimization enabled
- Use environment-specific configuration for API endpoints and credentials
- Serve production assets from CDN or edge locations when appropriate
- Add health and metrics endpoints for observability
- Protect secrets and avoid exposing runtime internals

## Code Examples

### Node.js route module
```ts
// src/api/routes/userRoutes.ts
import { Router } from "express"
import { UserController } from "../controllers/userController"
const router = Router()
router.get("/users", UserController.getUsers)
export default router
```

### Service layer example
```ts
// src/services/userService.ts
import { UserRepository } from "../repositories/userRepository"

export class UserService {
  constructor(private repo: UserRepository) {}
  async listUsers() {
    return this.repo.findAll()
  }
}
```

### Central configuration
```ts
// src/config/index.ts
import dotenv from "dotenv"
dotenv.config()
export const config = {
  port: Number(process.env.PORT ?? 3000),
  databaseUrl: process.env.DATABASE_URL ?? ""
}
```

## AI Prompting Examples

- "Generate a Node.js enterprise project architecture with service and repository separation."
- "Recommend a Node.js API folder structure for scalable Express applications."
- "Create Node.js production deployment guidance for containerized services."
