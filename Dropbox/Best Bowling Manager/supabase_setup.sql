-- ===========================================
-- SUPABASE DATABASE SETUP FOR THAMES BOWLING
-- ===========================================
-- Run this SQL in your Supabase SQL Editor
-- https://supabase.com/dashboard/project/_/sql

-- ===========================================
-- 1. CREATE LEAGUE_DATA TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS league_data (
  league_id TEXT PRIMARY KEY,
  data JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_league_data_updated_at ON league_data(updated_at DESC);

-- ===========================================
-- 2. CREATE LEAGUE_VERSIONS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS league_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  league_id TEXT NOT NULL,
  data JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_league_versions_league_id ON league_versions(league_id);
CREATE INDEX IF NOT EXISTS idx_league_versions_created_at ON league_versions(created_at DESC);

-- ===========================================
-- 3. ENABLE ROW LEVEL SECURITY (RLS)
-- ===========================================
ALTER TABLE league_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE league_versions ENABLE ROW LEVEL SECURITY;

-- ===========================================
-- 4. RLS POLICIES FOR LEAGUE_DATA
-- ===========================================
-- Allow anyone to read league data (public read)
CREATE POLICY "Allow public read access to league_data"
  ON league_data
  FOR SELECT
  USING (true);

-- Allow anyone to insert/update league data (public write)
-- NOTE: For production, you may want to restrict this with authentication
CREATE POLICY "Allow public write access to league_data"
  ON league_data
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- ===========================================
-- 5. RLS POLICIES FOR LEAGUE_VERSIONS
-- ===========================================
-- Allow anyone to read version history (public read)
CREATE POLICY "Allow public read access to league_versions"
  ON league_versions
  FOR SELECT
  USING (true);

-- Allow anyone to insert version history (public write)
-- NOTE: For production, you may want to restrict this with authentication
CREATE POLICY "Allow public insert access to league_versions"
  ON league_versions
  FOR INSERT
  WITH CHECK (true);

-- ===========================================
-- 6. FUNCTION TO AUTO-UPDATE updated_at TIMESTAMP
-- ===========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update updated_at on league_data
DROP TRIGGER IF EXISTS update_league_data_updated_at ON league_data;
CREATE TRIGGER update_league_data_updated_at
  BEFORE UPDATE ON league_data
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ===========================================
-- 7. VERIFY SETUP
-- ===========================================
-- Test insert (optional - remove after testing)
-- INSERT INTO league_data (league_id, data) 
-- VALUES ('thames_2025', '{"players": [], "teams": {"mens": [], "doubles": []}, "schedule": [], "results": []}'::jsonb)
-- ON CONFLICT (league_id) DO NOTHING;

-- ===========================================
-- SETUP COMPLETE
-- ===========================================
-- Your tables are now ready!
-- The app will automatically use these tables when connected to Supabase.
