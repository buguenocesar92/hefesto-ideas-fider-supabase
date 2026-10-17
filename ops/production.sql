DO $$ BEGIN
 IF to_regclass('public.tenants') IS NULL OR to_regclass('public.users') IS NULL THEN
  RAISE EXCEPTION 'Primero completar bootstrap privado';
 END IF;
 IF (SELECT count(*) FROM public.tenants WHERE status=1) <> 1 THEN
  RAISE EXCEPTION 'Se requiere exactamente un portal activo en este kit';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM public.users WHERE role=3 AND status=1) THEN
  RAISE EXCEPTION 'Falta administrador activo';
 END IF;
END $$;
