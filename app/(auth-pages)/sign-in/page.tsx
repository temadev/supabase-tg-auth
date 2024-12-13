import { FormMessage, Message } from "@/components/form-message";
import { TelegramButton } from "@/components/telegram-button";

export default async function Login(props: { searchParams: Promise<Message> }) {
  const searchParams = await props.searchParams;
  return (
    <form className="flex-1 flex flex-col min-w-64">
      <h1 className="text-2xl font-medium">Sign in</h1>
      <div className="flex flex-col gap-2 [&>input]:mb-3 mt-8">
        <TelegramButton />
        <FormMessage message={searchParams} />
      </div>
    </form>
  );
}
