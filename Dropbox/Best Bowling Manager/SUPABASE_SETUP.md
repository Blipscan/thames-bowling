# Supabase Setup Guide for Thames Bowling Manager

This guide will help you set up the Supabase database tables and Row Level Security (RLS) policies for the Thames Bowling Manager app.

## Prerequisites

1. A Supabase account (sign up at https://supabase.com)
2. A Supabase project created
3. Your Supabase project URL and anon key (found in Project Settings > API)

## Step 1: Create Tables and RLS Policies

1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor** (left sidebar)
3. Click **"New query"**
4. Copy and paste the entire contents of `supabase_setup.sql`
5. Click **"Run"** (or press Ctrl+Enter)

This will create:
- `league_data` table - stores the main league data
- `league_versions` table - stores version history for recovery
- Row Level Security policies (public read/write for now)
- Auto-update triggers for timestamps

## Step 2: Verify Tables Were Created

1. Go to **Table Editor** in Supabase Dashboard
2. You should see two tables:
   - `league_data`
   - `league_versions`

## Step 3: Update Your HTML File

Make sure your `index.html` (or `Thames Bowling.html`) has the correct Supabase credentials:

```javascript
const SUPABASE_URL = 'https://your-project-id.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key-here';
```

## Step 4: Test the Connection

1. Open your app (locally or on Render)
2. The app should connect to Supabase automatically
3. Check the browser console for any errors
4. Try creating some test data

## Security Considerations

### Current Setup (Public Access)
The current RLS policies allow **public read and write access**. This is fine for:
- Development/testing
- Internal club use
- Low-risk data

### For Production/Enhanced Security

If you want to restrict access, you can modify the RLS policies in Supabase:

1. Go to **Authentication** > **Policies** in Supabase Dashboard
2. Modify the policies to require authentication:

```sql
-- Example: Require authentication for writes
CREATE POLICY "Allow authenticated write access to league_data"
  ON league_data
  FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');
```

Or use service role key for server-side operations.

## Troubleshooting

### Error: "relation does not exist"
- Make sure you ran the SQL setup script completely
- Check that you're in the correct Supabase project

### Error: "permission denied"
- Check RLS policies are enabled and configured correctly
- Verify your anon key is correct

### Error: "PGRST116" (no rows)
- This is normal for a new database - the app will create the first entry automatically

## Table Schema

### league_data
- `league_id` (TEXT, PRIMARY KEY) - e.g., 'thames_2025'
- `data` (JSONB) - Contains: players, teams, schedule, results
- `updated_at` (TIMESTAMPTZ) - Auto-updated on changes

### league_versions
- `id` (UUID, PRIMARY KEY) - Auto-generated
- `league_id` (TEXT) - Links to league_data
- `data` (JSONB) - Snapshot of league data
- `created_at` (TIMESTAMPTZ) - When version was created

## Support

If you encounter issues:
1. Check Supabase Dashboard logs
2. Check browser console for JavaScript errors
3. Verify your Supabase URL and keys are correct
