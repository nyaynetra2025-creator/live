-- ============================================
-- FIX: Auto-create profile when user signs up
-- ============================================
-- This trigger automatically creates a profile entry
-- whenever a new user is created in auth.users

-- Create the function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    COALESCE(NEW.raw_user_meta_data->>'role', 'client'),
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Success message
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Auto-profile creation enabled!';
  RAISE NOTICE '';
  RAISE NOTICE 'Now when users sign up, they will automatically';
  RAISE NOTICE 'get a profile entry created in the profiles table.';
  RAISE NOTICE '';
  RAISE NOTICE '🔄 For existing users, you need to either:';
  RAISE NOTICE '   1. Re-register them';
  RAISE NOTICE '   2. OR manually insert their profile';
  RAISE NOTICE '';
END $$;
