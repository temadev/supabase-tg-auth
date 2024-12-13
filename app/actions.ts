"use server";

import { encodedRedirect } from "@/utils/utils";
import { createClient } from "@/utils/supabase/server";
import { redirect } from "next/navigation";
import { AuthDataValidator } from '@telegram-auth/server';
import { objectToAuthDataMap } from '@telegram-auth/server/utils';
import crypto from 'crypto';
import { TelegramAuthData } from "@telegram-auth/react";

const SERVER_SALT = process.env.AUTH_SALT;

function generateSecurePassword(userId: number): string {
  // Combine userId with server salt
  const dataToHash = `${userId}${SERVER_SALT}`;

  // Create SHA-256 hash
  const hash = crypto
    .createHash('sha256')
    .update(dataToHash)
    .digest('hex');

  // Take first 16 characters of hash to create a reasonable length password
  return hash.slice(0, 16);
}

export const telegramSignInAction = async (data: TelegramAuthData) => {
  const supabase = await createClient();
  const validator = new AuthDataValidator({ botToken: process.env.AUTH_TG_BOT_TOKEN });

  const tgUser = await validator.validate(objectToAuthDataMap(data as unknown as Record<string, string | number>));
  const generatedPassword = generateSecurePassword(tgUser.id);

  const email = `${tgUser.id}@t.me`;
  const password = generatedPassword;

  const { error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) {
    const { error } = await supabase.auth.signUp({ email, password });
    if (error) {
      return encodedRedirect("error", "/sign-in", error.message);
    } else {
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) return encodedRedirect("error", "/sign-in", error.message);

      return redirect("/protected");
    }
  }

  return redirect("/protected");
}

export const signOutAction = async () => {
  const supabase = await createClient();
  await supabase.auth.signOut();
  return redirect("/sign-in");
};
