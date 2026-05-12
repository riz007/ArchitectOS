# Node.js Enterprise API Layer

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

## Recommended Pattern

- Centralize HTTP and API clients in shared services
- Use typed request/response models
- Keep components/controllers thin and delegate work to services
- Handle errors and validation at the boundary

## Scaling Advice

- Version API contracts where needed
- Keep feature APIs small and composable
- Use pagination and filtering for large datasets
- Cache repeated reads with consistent invalidation

## Production Deployment

- Enforce HTTPS and auth on all endpoints
- Use centralized logging and tracing for API requests
- Validate and sanitize all external input
- Use rate limiting and circuit breakers when needed

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
