import { Suspense } from 'react';
import LoginForm from '@/components/LoginForm';

export const metadata = { title: 'Log in — MSW Community' };

export default function Login() {
  return (
    <Suspense>
      <LoginForm />
    </Suspense>
  );
}
