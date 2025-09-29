import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import dotenv from 'dotenv';

dotenv.config();

if (!process.env.TOI_DATABASE_URL) {
  throw new Error('TOI_DATABASE_URL environment variable is not set');
}

export const client = postgres(process.env.TOI_DATABASE_URL);
export const db = drizzle(client);
