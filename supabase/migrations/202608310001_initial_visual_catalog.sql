-- ShadeMatch Global: visual-evidence-aware catalogue schema.
-- Apply first in staging. The paired rollback is for empty/non-production
-- environments only; production changes must use forward-only expand/contract.

create extension if not exists pgcrypto;
create extension if not exists citext;

create table public.dataset_releases (
  id uuid primary key default gen_random_uuid(),
  version text not null unique,
  title text not null,
  source_verified_through date,
  publication_status text not null default 'draft'
    check (publication_status in ('draft', 'review', 'published', 'withdrawn')),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id),
  constraint published_release_has_timestamp check (
    publication_status <> 'published' or published_at is not null
  )
);

create table public.brands (
  id uuid primary key default gen_random_uuid(),
  name citext not null unique,
  display_name text not null,
  origin_country text,
  primary_region text,
  official_website_url text,
  data_status text not null default 'queued'
    check (data_status in ('queued', 'in_review', 'verified', 'retired')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.brand_aliases (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete cascade,
  alias citext not null unique,
  market text,
  created_at timestamptz not null default now()
);

create table public.undertone_profiles (
  code text primary key,
  display_name text not null,
  warmth_axis numeric(5, 3),
  red_olive_axis numeric(5, 3),
  description text,
  is_unknown boolean not null default false,
  sort_order smallint not null default 0,
  created_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id),
  name text not null,
  product_type text not null,
  finish text,
  coverage text,
  form_factor text,
  official_product_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (brand_id, name)
);

create table public.product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id),
  formula_version text not null default 'unspecified',
  market_code text not null default 'GLOBAL',
  market_scope text,
  region text,
  currency_code text,
  status text not null default 'current'
    check (status in ('current', 'retiring', 'discontinued', 'unknown')),
  available_from date,
  available_until date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (product_id, formula_version, market_code),
  check (available_until is null or available_from is null or available_until >= available_from)
);

create table public.shades (
  id uuid primary key default gen_random_uuid(),
  product_variant_id uuid not null references public.product_variants(id),
  shade_code text not null,
  shade_name text,
  manufacturer_depth text,
  manufacturer_undertone text,
  universal_depth smallint not null check (universal_depth between 1 and 30),
  depth_continuous numeric(6, 3) check (depth_continuous between 1 and 30),
  depth_family text not null,
  undertone_code text not null references public.undertone_profiles(code),
  normalization_basis text not null,
  normalization_confidence numeric(4, 3)
    check (normalization_confidence between 0 and 1),
  lifecycle_status text not null default 'current'
    check (lifecycle_status in ('current', 'retiring', 'discontinued', 'unknown')),
  publication_status text not null default 'draft'
    check (publication_status in ('draft', 'review', 'published', 'withdrawn')),
  verified_at timestamptz,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (product_variant_id, shade_code),
  constraint published_shade_has_verification check (
    publication_status <> 'published' or (verified_at is not null and published_at is not null)
  )
);

create table public.shade_aliases (
  id uuid primary key default gen_random_uuid(),
  shade_id uuid not null references public.shades(id) on delete cascade,
  alias citext not null,
  market_code text,
  alias_type text not null default 'search'
    check (alias_type in ('search', 'legacy_code', 'regional_name', 'misspelling')),
  unique (shade_id, alias, market_code)
);

create table public.source_evidence (
  id uuid primary key default gen_random_uuid(),
  shade_id uuid references public.shades(id) on delete cascade,
  product_variant_id uuid references public.product_variants(id) on delete cascade,
  source_type text not null
    check (source_type in ('official_manufacturer', 'authorized_retailer', 'laboratory', 'editorial', 'community')),
  source_url text not null,
  source_title text,
  market_code text,
  retrieved_at timestamptz not null,
  verified_at timestamptz,
  content_hash text,
  archived_snapshot_path text,
  reviewer_notes text,
  created_at timestamptz not null default now(),
  check (shade_id is not null or product_variant_id is not null),
  check (source_url ~* '^https://')
);

create table public.capture_protocols (
  id uuid primary key default gen_random_uuid(),
  version text not null unique,
  title text not null,
  illuminant text,
  observer_angle text,
  background_standard text,
  white_balance_method text,
  colour_checker_required boolean not null default false,
  application_thickness text,
  oxidation_minutes integer[] not null default '{}',
  instructions text not null,
  created_at timestamptz not null default now()
);

create table public.visual_assets (
  id uuid primary key default gen_random_uuid(),
  shade_id uuid not null references public.shades(id) on delete cascade,
  source_evidence_id uuid references public.source_evidence(id),
  capture_protocol_id uuid references public.capture_protocols(id),
  kind text not null check (kind in (
    'spectrophotometer_measurement',
    'calibrated_standardized_swatch',
    'official_digital_swatch',
    'official_product_image',
    'model_wear_image',
    'arm_swatch_image',
    'community_image',
    'universal_profile_estimate'
  )),
  label text not null,
  storage_path text,
  external_url text,
  thumbnail_storage_path text,
  display_hex text check (display_hex ~ '^#[0-9A-Fa-f]{6}$'),
  width_px integer check (width_px is null or width_px > 0),
  height_px integer check (height_px is null or height_px > 0),
  colour_profile text,
  focal_point_x numeric(5, 4) check (focal_point_x between 0 and 1),
  focal_point_y numeric(5, 4) check (focal_point_y between 0 and 1),
  dominant_hex text check (dominant_hex ~ '^#[0-9A-Fa-f]{6}$'),
  image_hash text,
  blur_hash text,
  alt_text text not null,
  rights_status text not null check (rights_status in (
    'owned', 'licensed', 'manufacturer_permission', 'link_only',
    'community_consent', 'generated_in_app', 'unknown', 'restricted'
  )),
  license_reference text,
  attribution_text text,
  verification_status text not null default 'unverified'
    check (verification_status in ('unverified', 'in_review', 'verified', 'rejected', 'expired')),
  evidence_tier smallint not null default 0 check (evidence_tier between 0 and 5),
  match_eligible boolean not null default false,
  is_primary boolean not null default false,
  sort_order smallint not null default 0,
  publication_status text not null default 'draft'
    check (publication_status in ('draft', 'review', 'published', 'withdrawn')),
  disclaimer text,
  verified_at timestamptz,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (num_nonnulls(storage_path, external_url, display_hex) >= 1),
  check (external_url is null or external_url ~* '^https://'),
  check (kind <> 'universal_profile_estimate' or match_eligible = false),
  check (match_eligible = false or verification_status = 'verified'),
  check (publication_status <> 'published' or rights_status <> 'unknown')
);

create unique index one_primary_visual_per_shade
  on public.visual_assets (shade_id)
  where is_primary and publication_status <> 'withdrawn';
create index visual_assets_shade_sort_idx
  on public.visual_assets (shade_id, sort_order);

create table public.visual_asset_contexts (
  visual_asset_id uuid primary key references public.visual_assets(id) on delete cascade,
  application_area text check (application_area in (
    'product_only', 'flat_swatch', 'arm', 'face', 'jawline', 'neck', 'other'
  )),
  application_method text,
  base_skin_depth smallint check (base_skin_depth between 1 and 30),
  base_skin_undertone_code text references public.undertone_profiles(code),
  lighting_description text,
  background_description text,
  wet_dry_state text check (wet_dry_state in ('wet', 'set', 'dry', 'unknown')),
  oxidation_minutes integer check (oxidation_minutes is null or oxidation_minutes >= 0),
  model_release_reference text,
  context_notes text,
  created_at timestamptz not null default now()
);

create table public.colour_measurements (
  id uuid primary key default gen_random_uuid(),
  shade_id uuid not null references public.shades(id) on delete cascade,
  visual_asset_id uuid references public.visual_assets(id) on delete set null,
  capture_protocol_id uuid references public.capture_protocols(id),
  method text not null check (method in (
    'spectrophotometer', 'colorimeter', 'calibrated_photo',
    'official_digital_value', 'profile_estimate'
  )),
  colour_space text not null default 'CIELAB',
  illuminant text not null default 'D65',
  observer_angle text not null default '2deg',
  lab_l numeric(7, 4) not null check (lab_l between 0 and 100),
  lab_a numeric(8, 4) not null check (lab_a between -128 and 127),
  lab_b numeric(8, 4) not null check (lab_b between -128 and 127),
  srgb_hex text check (srgb_hex ~ '^#[0-9A-Fa-f]{6}$'),
  oxidation_minutes integer not null default 0 check (oxidation_minutes >= 0),
  wet_dry_state text check (wet_dry_state in ('wet', 'set', 'dry', 'unknown')),
  device_name text,
  device_serial_hash text,
  calibration_reference text,
  sample_batch_code text,
  uncertainty_delta_e numeric(7, 4) check (uncertainty_delta_e >= 0),
  quality_score numeric(4, 3) check (quality_score between 0 and 1),
  match_eligible boolean not null default false,
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  check (method <> 'profile_estimate' or match_eligible = false),
  check (match_eligible = false or verified_at is not null)
);

create index colour_measurements_match_idx
  on public.colour_measurements (shade_id, match_eligible, oxidation_minutes);

create table public.release_shades (
  release_id uuid not null references public.dataset_releases(id) on delete cascade,
  shade_id uuid not null references public.shades(id),
  record_hash text not null,
  primary key (release_id, shade_id)
);

create table public.match_engine_versions (
  id uuid primary key default gen_random_uuid(),
  version text not null unique,
  method text not null,
  configuration jsonb not null,
  validation_report_path text,
  status text not null default 'draft'
    check (status in ('draft', 'validated', 'active', 'retired')),
  activated_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.precomputed_matches (
  id uuid primary key default gen_random_uuid(),
  source_shade_id uuid not null references public.shades(id) on delete cascade,
  candidate_shade_id uuid not null references public.shades(id) on delete cascade,
  match_engine_version_id uuid not null references public.match_engine_versions(id),
  total_score numeric(9, 4) not null,
  delta_e_2000 numeric(9, 4),
  depth_delta numeric(7, 4) not null,
  undertone_distance numeric(7, 4),
  formula_distance numeric(7, 4),
  evidence_confidence numeric(4, 3) not null check (evidence_confidence between 0 and 1),
  grade text not null,
  explanation jsonb not null,
  computed_at timestamptz not null default now(),
  unique (source_shade_id, candidate_shade_id, match_engine_version_id),
  check (source_shade_id <> candidate_shade_id)
);

create index precomputed_matches_source_rank_idx
  on public.precomputed_matches (source_shade_id, match_engine_version_id, total_score);

create table public.saved_shades (
  user_id uuid not null references auth.users(id) on delete cascade,
  shade_id uuid not null references public.shades(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, shade_id)
);

create table public.match_feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  source_shade_id uuid references public.shades(id) on delete set null,
  candidate_shade_id uuid references public.shades(id) on delete set null,
  match_engine_version_id uuid references public.match_engine_versions(id),
  outcome text not null check (outcome in ('good', 'too_light', 'too_dark', 'too_warm', 'too_cool', 'too_olive', 'other')),
  notes text,
  consent_for_aggregate_improvement boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.user_captures (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  storage_path text not null,
  capture_purpose text not null default 'shade_assistance',
  consent_version text not null,
  on_device_processed boolean not null default true,
  device_metadata jsonb not null default '{}',
  lighting_assessment jsonb not null default '{}',
  retention_expires_at timestamptz not null,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  check (retention_expires_at > created_at)
);

alter table public.dataset_releases enable row level security;
alter table public.brands enable row level security;
alter table public.brand_aliases enable row level security;
alter table public.undertone_profiles enable row level security;
alter table public.products enable row level security;
alter table public.product_variants enable row level security;
alter table public.shades enable row level security;
alter table public.shade_aliases enable row level security;
alter table public.source_evidence enable row level security;
alter table public.capture_protocols enable row level security;
alter table public.visual_assets enable row level security;
alter table public.visual_asset_contexts enable row level security;
alter table public.colour_measurements enable row level security;
alter table public.release_shades enable row level security;
alter table public.match_engine_versions enable row level security;
alter table public.precomputed_matches enable row level security;
alter table public.saved_shades enable row level security;
alter table public.match_feedback enable row level security;
alter table public.user_captures enable row level security;

create policy "public reads published releases"
  on public.dataset_releases for select
  using (publication_status = 'published');
create policy "public reads brand directory"
  on public.brands for select using (true);
create policy "public reads brand aliases"
  on public.brand_aliases for select using (true);
create policy "public reads undertone profiles"
  on public.undertone_profiles for select using (true);
create policy "public reads products with published shades"
  on public.products for select using (
    exists (
      select 1 from public.product_variants variant
      join public.shades shade on shade.product_variant_id = variant.id
      where variant.product_id = products.id
        and shade.publication_status = 'published'
    )
  );
create policy "public reads variants with published shades"
  on public.product_variants for select using (
    exists (
      select 1 from public.shades shade
      where shade.product_variant_id = product_variants.id
        and shade.publication_status = 'published'
    )
  );
create policy "public reads published shades"
  on public.shades for select using (publication_status = 'published');
create policy "public reads published shade aliases"
  on public.shade_aliases for select using (
    exists (
      select 1 from public.shades shade
      where shade.id = shade_aliases.shade_id
        and shade.publication_status = 'published'
    )
  );
create policy "public reads verified source evidence"
  on public.source_evidence for select using (verified_at is not null);
create policy "public reads published capture protocols"
  on public.capture_protocols for select using (
    exists (
      select 1 from public.visual_assets asset
      where asset.capture_protocol_id = capture_protocols.id
        and asset.publication_status = 'published'
    ) or exists (
      select 1 from public.colour_measurements measurement
      where measurement.capture_protocol_id = capture_protocols.id
        and measurement.verified_at is not null
    )
  );
create policy "public reads published visual assets"
  on public.visual_assets for select using (publication_status = 'published');
create policy "public reads contexts for published visuals"
  on public.visual_asset_contexts for select using (
    exists (
      select 1 from public.visual_assets asset
      where asset.id = visual_asset_contexts.visual_asset_id
        and asset.publication_status = 'published'
    )
  );
create policy "public reads verified measurements"
  on public.colour_measurements for select using (verified_at is not null);
create policy "public reads published release membership"
  on public.release_shades for select using (
    exists (
      select 1 from public.dataset_releases release
      where release.id = release_shades.release_id
        and release.publication_status = 'published'
    )
  );
create policy "public reads active match engines"
  on public.match_engine_versions for select using (status = 'active');
create policy "public reads active precomputed matches"
  on public.precomputed_matches for select using (
    exists (
      select 1 from public.match_engine_versions engine
      where engine.id = precomputed_matches.match_engine_version_id
        and engine.status = 'active'
    )
  );

create policy "users read own saved shades"
  on public.saved_shades for select using (auth.uid() = user_id);
create policy "users add own saved shades"
  on public.saved_shades for insert with check (auth.uid() = user_id);
create policy "users delete own saved shades"
  on public.saved_shades for delete using (auth.uid() = user_id);

create policy "users manage own match feedback"
  on public.match_feedback for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "users manage own captures"
  on public.user_captures for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Seed all codes currently present in the 1,578-row source dataset. The old
-- workbook guide omitted G, PCH, WN, CN, NR and CB even though rows used them.
insert into public.undertone_profiles
  (code, display_name, warmth_axis, red_olive_axis, is_unknown, sort_order)
values
  ('N', 'True Neutral', 0.0, 0.0, false, 10),
  ('C', 'Cool', -1.0, 0.4, false, 20),
  ('W', 'Warm', 1.0, 0.0, false, 30),
  ('G', 'Golden', 1.1, -0.1, false, 40),
  ('CP', 'Cool Pink / Rosy', -1.0, 1.0, false, 50),
  ('CR', 'Cool Red / Reddish', -0.6, 1.2, false, 60),
  ('CB', 'Cool Blue', -1.2, -0.2, false, 70),
  ('WY', 'Warm Yellow', 1.3, -0.2, false, 80),
  ('WG', 'Warm Golden', 1.2, -0.1, false, 90),
  ('WP', 'Warm Peach', 0.8, 0.8, false, 100),
  ('PCH', 'Peach', 0.5, 1.0, false, 110),
  ('NP', 'Neutral Peach', 0.2, 0.7, false, 120),
  ('NG', 'Neutral Golden', 0.4, -0.1, false, 130),
  ('NR', 'Neutral Red', 0.1, 0.9, false, 140),
  ('WN', 'Warm Neutral', 0.5, 0.0, false, 150),
  ('CN', 'Cool Neutral', -0.5, 0.2, false, 160),
  ('O', 'Olive', 0.0, -1.0, false, 170),
  ('ON', 'Neutral Olive', 0.0, -0.7, false, 180),
  ('OY', 'Warm / Yellow Olive', 0.6, -0.8, false, 190),
  ('OG', 'Golden Olive', 0.4, -1.0, false, 200),
  ('U', 'Undertone Unmapped', null, null, true, 999);
