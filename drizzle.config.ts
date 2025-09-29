import type { Config } from 'drizzle-kit';

export default {
  schema: './app/db/schema.ts',
  out: './app/db/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.TOI_DATABASE_URL_EXTERNAL!,
  },
} satisfies Config;
