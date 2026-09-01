-- EMPTY STAGING / LOCAL DEVELOPMENT ONLY.
-- Do not use this destructive rollback after production data exists. For
-- production, repair forward with an expand/contract migration.

drop table if exists public.user_captures;
drop table if exists public.match_feedback;
drop table if exists public.saved_shades;
drop table if exists public.precomputed_matches;
drop table if exists public.match_engine_versions;
drop table if exists public.release_shades;
drop table if exists public.colour_measurements;
drop table if exists public.visual_asset_contexts;
drop table if exists public.visual_assets;
drop table if exists public.capture_protocols;
drop table if exists public.source_evidence;
drop table if exists public.shade_aliases;
drop table if exists public.shades;
drop table if exists public.product_variants;
drop table if exists public.products;
drop table if exists public.undertone_profiles;
drop table if exists public.brand_aliases;
drop table if exists public.brands;
drop table if exists public.dataset_releases;
