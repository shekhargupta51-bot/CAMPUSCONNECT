-- ==============================================================================
-- CAMPUSCONNECT ACADEMIC PORTAL — SUPABASE POSTGRESQL SCHEMA & SECURITY POLICIES
-- Copy and paste this script into your Supabase Dashboard -> SQL Editor -> Run
-- ==============================================================================

-- 1. USERS & PROFILES TABLE
create table if not exists public.users (
  id text primary key,
  name text not null,
  email text not null,
  role text not null default 'student' check (role in ('admin', 'professor', 'student')),
  department text default 'Computer Science & Engineering',
  designation text default '',
  roll_number text default '',
  semester int default 6,
  cgpa text default '3.80',
  office text default '',
  office_hours text default '',
  avatar text default 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
  created_at timestamptz default now()
);

-- 2. SUBJECTS & CURRICULUM TABLE
create table if not exists public.subjects (
  id text primary key,
  code text not null,
  title text not null,
  professor_id text references public.users(id) on delete set null,
  credits int default 4,
  schedule text default 'Mon & Wed • 10:00 AM - 11:30 AM',
  room text default 'Hall 304',
  description text default '',
  enrolled_student_ids jsonb default '[]'::jsonb,
  created_by text,
  created_at timestamptz default now()
);

-- 3. NOTES & LEARNING RESOURCES TABLE
create table if not exists public.resources (
  id text primary key,
  subject_id text not null,
  title text not null,
  category text default 'Lecture Slides',
  description text default '',
  uploaded_by text,
  uploaded_at timestamptz default now(),
  file_type text default 'PDF',
  file_size text default '2.4 MB',
  download_url text default '',
  storage_path text default '',
  external_link text default ''
);

-- 4. ASSIGNMENTS & TERM PROJECTS TABLE
create table if not exists public.assignments (
  id text primary key,
  subject_id text not null,
  title text not null,
  description text default '',
  due_date timestamptz not null,
  max_marks numeric default 100,
  weightage text default '15%',
  created_by text,
  created_at timestamptz default now(),
  attachment_name text default '',
  attachment_size text default '',
  attachment_url text default ''
);

-- 5. SUBMISSIONS TABLE
create table if not exists public.submissions (
  id text primary key,
  assignment_id text not null,
  student_id text not null,
  submission_type text default 'link',
  submission_url text default '',
  file_name text default '',
  file_size text default '',
  storage_path text default '',
  download_url text default '',
  comments text default '',
  submitted_at timestamptz default now(),
  status text default 'submitted' check (status in ('submitted', 'graded', 'late')),
  marks numeric,
  max_marks numeric default 100,
  feedback text default '',
  graded_by text,
  graded_at timestamptz
);

-- 6. ATTENDANCE SESSIONS TABLE
create table if not exists public.attendance_sessions (
  id text primary key,
  subject_id text not null,
  date text not null,
  topic text default 'General Lecture Session',
  conducted_by text,
  records jsonb default '{}'::jsonb,
  updated_at timestamptz default now()
);

-- 7. MARKS & EVALUATIONS TABLE
create table if not exists public.marks (
  id text primary key,
  subject_id text not null,
  student_id text not null,
  assessment_name text not null,
  category text default 'Assignment',
  scored_marks numeric not null,
  max_marks numeric default 100,
  weightage text default '15%',
  date text not null,
  feedback text default '',
  published_by text,
  published_at timestamptz default now()
);

-- 8. ANNOUNCEMENTS & BULLETINS TABLE
create table if not exists public.announcements (
  id text primary key,
  title text not null,
  subject_id text default 'all',
  author_id text,
  author_name text,
  author_role text,
  priority text default 'normal' check (priority in ('normal', 'medium', 'high')),
  pinned boolean default false,
  published_at timestamptz default now(),
  content text not null
);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

alter table public.users enable row level security;
alter table public.subjects enable row level security;
alter table public.resources enable row level security;
alter table public.assignments enable row level security;
alter table public.submissions enable row level security;
alter table public.attendance_sessions enable row level security;
alter table public.marks enable row level security;
alter table public.announcements enable row level security;

-- General access policies allowing authenticated users & anon demo access
create policy "Allow all operations for authenticated & public demo users on users" on public.users for all using (true) with check (true);
create policy "Allow all operations on subjects" on public.subjects for all using (true) with check (true);
create policy "Allow all operations on resources" on public.resources for all using (true) with check (true);
create policy "Allow all operations on assignments" on public.assignments for all using (true) with check (true);
create policy "Allow all operations on submissions" on public.submissions for all using (true) with check (true);
create policy "Allow all operations on attendance_sessions" on public.attendance_sessions for all using (true) with check (true);
create policy "Allow all operations on marks" on public.marks for all using (true) with check (true);
create policy "Allow all operations on announcements" on public.announcements for all using (true) with check (true);

-- Enable real-time replication on tables for live multi-device synchronization
alter publication supabase_realtime add table public.users;
alter publication supabase_realtime add table public.subjects;
alter publication supabase_realtime add table public.resources;
alter publication supabase_realtime add table public.assignments;
alter publication supabase_realtime add table public.submissions;
alter publication supabase_realtime add table public.attendance_sessions;
alter publication supabase_realtime add table public.marks;
alter publication supabase_realtime add table public.announcements;

-- ==============================================================================
-- STORAGE BUCKET CREATION (FOR NOTES & SUBMISSION ATTACHMENTS)
-- ==============================================================================
insert into storage.buckets (id, name, public)
values ('academic_files', 'academic_files', true)
on conflict (id) do nothing;

create policy "Allow public uploads to academic_files" on storage.objects
  for all using (bucket_id = 'academic_files') with check (bucket_id = 'academic_files');
