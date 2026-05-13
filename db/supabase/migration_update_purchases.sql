-- =====================================================
-- Migration Script for Purchases Table Updates
-- Run this script in your Supabase SQL Editor
-- =====================================================

-- STEP 1: Backup existing purchases table (optional but recommended)
-- CREATE TABLE IF NOT EXISTS purchases_backup AS SELECT * FROM purchases;

-- STEP 2: Drop the existing purchases table if it exists
DROP TABLE IF EXISTS public.purchases CASCADE;

-- STEP 3: Create the new improved purchases table
CREATE TABLE IF NOT EXISTS public.purchases (
  id uuid primary key default gen_random_uuid(),
  video_id uuid references public.videos(id) on delete set null,
  buyer_email text not null,
  buyer_name text,
  transaction_id text not null unique,
  payment_method text not null check (payment_method in ('paypal','stripe','crypto','who')),
  amount numeric(10,2) not null,
  currency text not null default 'eur',
  status text not null default 'completed' check (status in ('pending','completed','failed','refunded')),
  video_title text,
  product_link text,
  metadata jsonb,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- STEP 4: Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_purchases_email ON public.purchases(buyer_email);
CREATE INDEX IF NOT EXISTS idx_purchases_transaction_id ON public.purchases(transaction_id);
CREATE INDEX IF NOT EXISTS idx_purchases_created_at ON public.purchases(created_at desc);

-- STEP 5: Disable RLS on purchases table (if you don't need row-level security)
ALTER TABLE public.purchases DISABLE ROW LEVEL SECURITY;

-- STEP 6: Drop existing policies (if any)
DROP POLICY IF EXISTS purchases_read_public ON public.purchases;
DROP POLICY IF EXISTS purchases_insert_any ON public.purchases;
DROP POLICY IF EXISTS purchases_update_any ON public.purchases;
DROP POLICY IF EXISTS purchases_delete_any ON public.purchases;

-- =====================================================
-- VERIFICATION QUERIES
-- Run these to verify the table was created correctly
-- =====================================================

-- Check table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'purchases'
ORDER BY ordinal_position;

-- Check indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'purchases';

-- Check constraints
SELECT 
  conname as constraint_name,
  contype as constraint_type,
  CASE contype
    WHEN 'c' THEN 'CHECK'
    WHEN 'f' THEN 'FOREIGN KEY'
    WHEN 'p' THEN 'PRIMARY KEY'
    WHEN 'u' THEN 'UNIQUE'
    WHEN 't' THEN 'TRIGGER'
    WHEN 'x' THEN 'EXCLUSION'
    ELSE contype::text
  END as constraint_type_name
FROM pg_constraint
WHERE conrelid = 'public.purchases'::regclass;

-- =====================================================
-- ROLLBACK SCRIPT (if needed)
-- If something goes wrong, you can restore from backup
-- =====================================================

-- DROP TABLE IF EXISTS public.purchases;
-- ALTER TABLE purchases_backup RENAME TO purchases;

