// Code de superbase pour backend avec OpenAi



import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");

type Task = "chat" | "image" | "audio";

Deno.serve(async (req) => {
  try {
    if (!OPENAI_API_KEY) {
      return json({ error: "Missing OPENAI_API_KEY" }, 500);
    }

    const body = await req.json();
    const task: Task = body.task ?? "chat";


    if (task === "audio") {
      const model = body.model ?? "gpt-4o-mini-transcribe";
      const prompt = body.prompt ?? null;
      const filename = body.filename ?? "audio.mp3";
      const audioBase64 = body.audioBase64;

      if (!audioBase64) {
        return json({ error: "audioBase64 is required" }, 400);
      }

      const bin = Uint8Array.from(atob(audioBase64), (c) => c.charCodeAt(0));

      const form = new FormData();
      form.append("model", model);
      if (prompt) form.append("prompt", prompt);
      form.append("file", new Blob([bin], { type: "audio/mpeg" }), filename);

      const r = await fetch("https://api.openai.com/v1/audio/transcriptions", {
        method: "POST",
        headers: { Authorization: `Bearer ${OPENAI_API_KEY}` },
        body: form,
      });

      const data = await r.json();
      if (!r.ok) return json(data, r.status);

      return json({ text: data.text ?? "" }, 200);
    }

 
    if (task === "image") {
      // Tant que je ne veux pas payer, on renvoie une "erreur" détectable côté iOS
      return json(
        { error: { code: "insufficient_quota", message: "insufficient_quota" } },
        402
      );
    }

 
    const model = body.model ?? "gpt-4.1";
    const instructions = body.instructions ?? null;
    const input = body.input ?? [];

    const r = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${OPENAI_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model,
        instructions,
        input: input.map((m: any) => ({ role: m.role, content: m.content })),
      }),
    });

    const data = await r.json();
    if (!r.ok) return json(data, r.status);

    const text =
      data.output_text ??
      (Array.isArray(data.output) ? extractText(data.output) : "") ??
      "";

    return json({ text }, 200);
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function extractText(output: any[]): string {
  try {
    for (const item of output) {
      if (item?.content && Array.isArray(item.content)) {
        const t = item.content
          .filter((c: any) => c?.type === "output_text" && typeof c?.text === "string")
          .map((c: any) => c.text)
          .join("\n");
        if (t) return t;
      }
    }
  } catch {}
  return "";
}

