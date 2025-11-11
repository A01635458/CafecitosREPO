-- ============================================
-- Script para REACTIVAR RLS después de pruebas
-- ⚠️  EJECUTAR DESPUÉS DE TERMINAR LAS PRUEBAS
-- ============================================

-- Reactivar RLS en todas las tablas
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_lesson_progress ENABLE ROW LEVEL SECURITY;

-- Recrear políticas básicas de lectura pública
CREATE POLICY "Allow public read access on modules" ON public.modules
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access on lessons" ON public.lessons
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access on users" ON public.users
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access on photos" ON public.photos
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access on notes" ON public.notes
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access on progress" ON public.user_lesson_progress
    FOR SELECT USING (true);

-- Verificar el estado de RLS
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Mensaje de confirmación
SELECT '✅ RLS reactivado con políticas de lectura pública.' as status;
