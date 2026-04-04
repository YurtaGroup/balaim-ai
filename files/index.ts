// balam.ai Design System Constants

export const Colors = {
  // Primary brand palette
  terra: '#C1714A',       // Warm terracotta — primary CTA, accents
  terraLight: '#F5EAE3',  // Light terracotta — backgrounds, chips
  terraDark: '#8A4E33',   // Dark terracotta — pressed states

  // Secondary palette
  sage: '#6B8F71',        // Sage green — success, safe indicators
  sageLight: '#EAF0EB',
  sageDark: '#4A6B50',

  // Neutrals
  cream: '#FBF8F4',       // App background
  warmWhite: '#FFFFFF',
  warmGray50: '#F4F1EE',
  warmGray100: '#E8E3DD',
  warmGray300: '#C4BDB5',
  warmGray500: '#8A7B74',
  warmGray700: '#4A3D38',
  warmDark: '#2C1F17',    // Primary text

  // Semantic
  success: '#4CAF50',
  warning: '#FF9800',
  danger: '#F44336',
  info: '#2196F3',

  // Urgency levels (for medical posts)
  urgencyLow: '#EAF0EB',
  urgencyMedium: '#FFF3E0',
  urgencyHigh: '#FFEBEE',
  urgencyEmergency: '#F44336',

  // Expert badge colors
  doctorBadge: '#E3F2FD',
  doctorBadgeText: '#1565C0',
  psychBadge: '#F3E5F5',
  psychBadgeText: '#6A1B9A',
  gynoBadge: '#FCE4EC',
  gynoBadgeText: '#880E4F',
} as const;

export const Typography = {
  // Font sizes
  xs: 11,
  sm: 13,
  base: 15,
  md: 17,
  lg: 20,
  xl: 24,
  xxl: 30,
  display: 36,

  // Line heights
  tight: 1.3,
  normal: 1.5,
  relaxed: 1.7,

  // Font weights
  regular: '400' as const,
  medium: '500' as const,
  semibold: '600' as const,
  bold: '700' as const,
} as const;

export const Spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  base: 16,
  lg: 20,
  xl: 24,
  xxl: 32,
  section: 48,
} as const;

export const BorderRadius = {
  sm: 6,
  md: 10,
  lg: 16,
  xl: 24,
  full: 999,
} as const;

export const Config = {
  supabaseUrl: process.env.EXPO_PUBLIC_SUPABASE_URL ?? '',
  supabaseAnonKey: process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? '',
  claudeApiUrl: 'https://api.anthropic.com/v1/messages',
  // Note: Claude API key must be called from backend, never from client
  
  // Business rules
  freeAiMessagesPerDay: 5,
  maxPhotosPerPost: 3,
  maxPhotoSizeMB: 10,
  expertResponseSLAHours: 24,
  emergencyKeywords: [
    'не дышит', 'синеет', 'судорога', 'не реагирует', 'высокая температура',
    'not breathing', 'turning blue', 'seizure', 'unresponsive',
    'дем албайт', 'кичинекей дем', // Kyrgyz emergency keywords
  ],
  ppdKeywords: [
    'не хочу быть мамой', 'больше не могу', 'хочу уйти', 'зря родила',
    'жалею что родила', 'мысли о вреде',
  ],
} as const;

export const BabyAgeGroups = [
  { label: '0–1 месяц', minDays: 0, maxDays: 30 },
  { label: '1–3 месяца', minDays: 31, maxDays: 90 },
  { label: '3–6 месяцев', minDays: 91, maxDays: 180 },
  { label: '6–9 месяцев', minDays: 181, maxDays: 270 },
  { label: '9–12 месяцев', minDays: 271, maxDays: 365 },
  { label: '1–1.5 года', minDays: 366, maxDays: 548 },
  { label: '1.5–2 года', minDays: 549, maxDays: 730 },
] as const;

export const CommunityCategories = [
  { id: 'baby_health', label: 'Здоровье малыша', icon: '👶', expertTag: 'pediatrician' },
  { id: 'feeding', label: 'Питание и кормление', icon: '🍼', expertTag: 'pediatrician' },
  { id: 'sleep', label: 'Сон и плач', icon: '😴', expertTag: 'psychologist' },
  { id: 'development', label: 'Развитие и поведение', icon: '🧠', expertTag: 'psychologist' },
  { id: 'mom_health', label: 'Здоровье мамы', icon: '💚', expertTag: 'gynecologist' },
  { id: 'recommendations', label: 'Рекомендации', icon: '⭐', expertTag: null },
  { id: 'celebrations', label: 'Праздники и торты', icon: '🎂', expertTag: null },
] as const;
