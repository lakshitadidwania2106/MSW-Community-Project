'use client';
import { Check } from 'lucide-react';
import { createContext, useCallback, useContext, useState, type ReactNode } from 'react';

type T = { id: number; msg: string; out?: boolean };
const Ctx = createContext<(msg: string) => void>(() => {});

/** Small confirmation messages in the bottom-right corner. */
export function ToastProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<T[]>([]);
  const toast = useCallback((msg: string) => {
    const id = Date.now() + Math.random();
    setItems((x) => [...x, { id, msg }]);
    setTimeout(() => setItems((x) => x.map((t) => (t.id === id ? { ...t, out: true } : t))), 2600);
    setTimeout(() => setItems((x) => x.filter((t) => t.id !== id)), 3000);
  }, []);
  return (
    <Ctx.Provider value={toast}>
      {children}
      <div className="toasts" aria-live="polite">
        {items.map((t) => (
          <div key={t.id} className={`toast${t.out ? ' out' : ''}`}>
            <i>
              <Check size={14} strokeWidth={2.5} />
            </i>
            <span>{t.msg}</span>
          </div>
        ))}
      </div>
    </Ctx.Provider>
  );
}

export const useToast = () => useContext(Ctx);
