/**
 * balam.ai AI Service
 * All Claude API calls go through the backend — never from the client directly.
 * This module defines the server-side AI service.
 */

import Anthropic from '@anthropic-ai/sdk';
import type { BabyProfile, AIChatMessage, CommunityPost, UrgencyLevel } from '../constants/types';

const client = new Anthropic(); // reads ANTHROPIC_API_KEY from env

const SYSTEM_PROMPT_BASE = `
Ты — balam.ai (Балам), тёплый и знающий ИИ-помощник для молодых мам в Кыргызстане.
Ты говоришь на русском языке (при необходимости — на кыргызском).
Ты как умная, добрая подруга, которая много знает о развитии детей и здоровье мам.

ВАЖНЫЕ ПРАВИЛА:
1. Ты НИКОГДА не ставишь диагнозы. Ты делишься информацией, не заменяешь врача.
2. При любых медицинских вопросах в конце добавляй: "Для точного ответа лучше проконсультироваться с педиатром."
3. Тон: тёплый, уверенный, без осуждения, без занудства. Как лучшая подруга, которая много знает.
4. Учитывай культурный контекст Кыргызстана: местные традиции, местная еда, местные реалии.
5. Не пугай маму. Если что-то серьёзное — скажи спокойно, но чётко.
6. Ответы короткие и чёткие. Мамы устали. Не пиши простыни текста.

ЭКСТРЕННЫЕ ПРИЗНАКИ (если мама описывает это — сразу направь к врачу/103):
- Не дышит / синеет
- Судороги
- Не реагирует
- Температура выше 38.5°C у ребёнка до 3 месяцев
- Сильная аллергическая реакция
`;

// ─── DAILY CARD GENERATION ────────────────────────────────────────────────────

export async function generateDailyCard(baby: BabyProfile): Promise<string> {
  const ageInDays = Math.floor(
    (Date.now() - new Date(baby.date_of_birth).getTime()) / (1000 * 60 * 60 * 24)
  );
  const ageWeeks = Math.floor(ageInDays / 7);
  const ageMonths = Math.floor(ageInDays / 30);

  const prompt = `
Создай персональную дневную карточку для мамы.

Информация о ребёнке:
- Имя: ${baby.name}
- Возраст: ${ageInDays} дней (${ageWeeks} недель, ${ageMonths} месяцев)
- Пол: ${baby.sex === 'male' ? 'мальчик' : 'девочка'}
- Питание: ${baby.feeding_method === 'breast' ? 'грудное вскармливание' : baby.feeding_method === 'formula' ? 'смесь' : 'смешанное'}

Создай карточку в формате JSON:
{
  "baby_age_display": "X недель и Y дней",
  "milestone_title": "короткий заголовок (до 6 слов)",
  "milestone_body": "2-3 предложения о том, что развивается у ребёнка в этом возрасте",
  "activity_title": "название активности (до 5 слов)",
  "activity_body": "конкретная активность на 5-10 минут, которую мама может сделать прямо сейчас",
  "watch_for": "1 предложение о признаке, который стоит отметить для педиатра",
  "mom_tip": "1 совет для мамы о её теле/психологии на этой неделе после родов",
  "affirmation": "1 тёплое, искреннее подбадривание для мамы (не банальное)"
}

Отвечай ТОЛЬКО валидным JSON, без markdown, без пояснений.
`;

  const response = await client.messages.create({
    model: 'claude-sonnet-4-6',
    max_tokens: 800,
    system: SYSTEM_PROMPT_BASE,
    messages: [{ role: 'user', content: prompt }],
  });

  const text = response.content[0].type === 'text' ? response.content[0].text : '';
  return text;
}

// ─── AI CHAT (ASK BALAM) ─────────────────────────────────────────────────────

export async function askbalam.ai(
  question: string,
  history: AIChatMessage[],
  baby: BabyProfile
): Promise<{ reply: string; urgency: UrgencyLevel }> {
  const ageInDays = Math.floor(
    (Date.now() - new Date(baby.date_of_birth).getTime()) / (1000 * 60 * 60 * 24)
  );

  const systemWithContext = `
${SYSTEM_PROMPT_BASE}

Контекст ребёнка мамы:
- Имя: ${baby.name}, ${ageInDays} дней (${Math.floor(ageInDays / 30)} месяцев)
- Пол: ${baby.sex === 'male' ? 'мальчик' : 'девочка'}
- Питание: ${baby.feeding_method}

В конце ответа добавь JSON-блок на новой строке:
{"urgency": "low"|"medium"|"high"|"emergency"}

Уровни срочности:
- low: обычный вопрос, всё в порядке
- medium: стоит обратить внимание, желательно показать врачу в ближайшие дни
- high: нужна консультация врача сегодня-завтра
- emergency: немедленно звонить 103 или ехать в скорую
`;

  const messages = [
    ...history.map((m) => ({
      role: m.role as 'user' | 'assistant',
      content: m.content,
    })),
    { role: 'user' as const, content: question },
  ];

  const response = await client.messages.create({
    model: 'claude-sonnet-4-6',
    max_tokens: 600,
    system: systemWithContext,
    messages,
  });

  const fullText = response.content[0].type === 'text' ? response.content[0].text : '';

  // Extract urgency JSON from end of response
  const jsonMatch = fullText.match(/\{"urgency":\s*"(low|medium|high|emergency)"\}/);
  const urgency: UrgencyLevel = (jsonMatch?.[1] as UrgencyLevel) ?? 'low';
  const reply = fullText.replace(/\s*\{"urgency":[^}]+\}/, '').trim();

  return { reply, urgency };
}

// ─── PHOTO POST TRIAGE ────────────────────────────────────────────────────────

export async function triagePhotoPost(
  postText: string,
  category: string,
  babyAgeMonths: number
): Promise<{
  urgency: UrgencyLevel;
  ai_response: string;
  expert_tag: string | null;
  suggested_tags: string[];
}> {
  const prompt = `
Мама написала в сообщество:
Категория: ${category}
Возраст ребёнка: ${babyAgeMonths} месяцев
Текст: "${postText}"

Твоя задача:
1. Оцени срочность (low/medium/high/emergency)
2. Напиши короткий первый ответ (2-4 предложения) — не диагноз, а что это могло бы быть и на что обратить внимание
3. Определи, к какому специалисту направить: pediatrician/psychologist/gynecologist/null

Ответь в JSON:
{
  "urgency": "low|medium|high|emergency",
  "ai_response": "текст первого ответа для мамы",
  "expert_tag": "pediatrician|psychologist|gynecologist|null",
  "suggested_tags": ["тег1", "тег2"]
}

ТОЛЬКО JSON, без markdown.
`;

  const response = await client.messages.create({
    model: 'claude-sonnet-4-6',
    max_tokens: 400,
    system: SYSTEM_PROMPT_BASE,
    messages: [{ role: 'user', content: prompt }],
  });

  const text = response.content[0].type === 'text' ? response.content[0].text : '{}';

  try {
    return JSON.parse(text.replace(/```json|```/g, '').trim());
  } catch {
    return {
      urgency: 'low',
      ai_response: 'Спасибо за ваш вопрос. Другие мамы и наш педиатр скоро ответят.',
      expert_tag: null,
      suggested_tags: [],
    };
  }
}

// ─── PPD SCREENING ────────────────────────────────────────────────────────────

export async function checkForPPD(text: string): Promise<boolean> {
  const ppdKeywords = [
    'не хочу быть мамой', 'больше не могу', 'хочу уйти', 'зря родила',
    'жалею что родила', 'мысли о вреде', 'не люблю ребёнка', 'хочу умереть',
  ];

  const lowerText = text.toLowerCase();
  return ppdKeywords.some((kw) => lowerText.includes(kw));
}

export async function getPPDResponse(): Promise<string> {
  return `Дорогая мама, то, что ты чувствуешь — это настоящее, и это важно. 
Послеродовая депрессия встречается гораздо чаще, чем принято говорить, и это не слабость.
Наш психолог готов поговорить с тобой — конфиденциально, без осуждения.
Ты не одна. 💚`;
}
