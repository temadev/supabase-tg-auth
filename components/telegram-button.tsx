'use client';

import { LoginButton } from "@telegram-auth/react";
import { telegramSignInAction } from "../app/actions";
import { useRouter } from "next/navigation";
import { useState } from "react";

const TelegramButton = () => {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);

  const handleAuth = async (data: any) => {
    const result = await telegramSignInAction(data);

    if (result.error) {
      setError(result.error);
      return;
    }

    if (result.success) {
      router.push(result.redirect);
    }
  };

  return (
    <>
      <LoginButton
        botUsername={process.env.NEXT_PUBLIC_AUTH_TG_USERNAME!}
        onAuthCallback={handleAuth}
        cornerRadius={8}
      />
      {error && (
        <div className="text-red-500 text-sm mt-2">
          {error}
        </div>
      )}
    </>
  );
};

export { TelegramButton };
