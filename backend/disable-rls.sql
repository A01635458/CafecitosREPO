-- ============================================
-- Script para DESACTIVAR RLS temporalmente
-- ⚠️  SOLO PARA DESARROLLO/TESTING
-- ⚠️  NO USAR EN PRODUCCIÓN
-- ============================================

-- Desactivar RLS en todas las tablas
ALTER TABLE public.modules DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.photos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_lesson_progress DISABLE ROW LEVEL SECURITY;

-- Verificar el estado de RLS
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Mensaje de confirmación
SELECT '✅ RLS desactivado en todas las tablas. Recuerda reactivarlo después de las pruebas.' as status;
