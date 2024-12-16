"use server";

import { encodedRedirect } from "@/utils/utils";
import { createClient } from "@/utils/supabase/server";
import { AuthDataValidator } from '@telegram-auth/server';
import { objectToAuthDataMap } from '@telegram-auth/server/utils';
import crypto from 'crypto';
import { TelegramAuthData } from "@telegram-auth/react";
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
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
    const { error: signUpError, data } = await supabase.auth.signUp({ email, password });
    if (signUpError) {
      return { error: signUpError.message, redirect: "/sign-in" };
    } else {
      // Create user in Prisma DB
      try {
        await prisma.user.create({
          data: {
            authId: data.user!.id,
            handle: tgUser.username || `user_${tgUser.id}`,
            displayName: tgUser.first_name + (tgUser.last_name ? ` ${tgUser.last_name}` : ''),
            profilePicture: tgUser.photo_url,
            roles: ['user']
          }
        });

        const { error: signInError } = await supabase.auth.signInWithPassword({ email, password });
        if (signInError) {
          return { error: signInError.message, redirect: "/sign-in" };
        }

        return { success: true, redirect: "/protected" };
      } catch (dbError) {
        console.error('Failed to create user in database:', dbError);
        // Clean up Supabase auth user if DB creation fails
        await supabase.auth.signOut();
        return { error: "Failed to create user profile", redirect: "/sign-in" };
      }
    }
  }

  return { success: true, redirect: "/protected" };
}

export const signOutAction = async () => {
  const supabase = await createClient();
  await supabase.auth.signOut();
  return { success: true, redirect: "/sign-in" };
};
