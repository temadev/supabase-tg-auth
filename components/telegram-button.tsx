'use client';

import { LoginButton } from "@telegram-auth/react";
import { telegramSignInAction } from "../app/actions";

const TelegramButton = () => (
  <LoginButton
    botUsername={process.env.NEXT_PUBLIC_AUTH_TG_USERNAME!}
    onAuthCallback={telegramSignInAction}
    cornerRadius={8}
  />
);

export { TelegramButton };
