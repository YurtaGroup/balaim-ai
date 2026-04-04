// balam.ai — Core Type Definitions

// ─── USER & BABY ─────────────────────────────────────────────────────────────

export interface User {
  id: string;
  phone: string;
  name: string;
  avatar_url?: string;
  city: City;
  language: 'ru' | 'ky' | 'en';
  is_pro: boolean;
  created_at: string;
}

export interface BabyProfile {
  id: string;
  user_id: string;
  name: string;
  date_of_birth: string; // ISO date
  birth_weight_grams?: number;
  birth_height_cm?: number;
  sex: 'male' | 'female';
  feeding_method: 'breast' | 'formula' | 'mixed';
  notes?: string;
}

export type City =
  | 'bishkek'
  | 'osh'
  | 'jalal_abad'
  | 'karakol'
  | 'naryn'
  | 'talas'
  | 'other';

// ─── COMMUNITY POST ───────────────────────────────────────────────────────────

export type PostCategory =
  | 'baby_health'
  | 'feeding'
  | 'sleep'
  | 'development'
  | 'mom_health'
  | 'recommendations'
  | 'celebrations';

export type UrgencyLevel = 'low' | 'medium' | 'high' | 'emergency';

export interface CommunityPost {
  id: string;
  author_id: string;
  author: Pick<User, 'id' | 'name' | 'avatar_url' | 'city'>;
  baby_age_days: number; // snapshot at time of posting
  category: PostCategory;
  title?: string;
  body: string;
  photo_urls: string[]; // max 3 photos
  is_anonymous: boolean;
  urgency_level: UrgencyLevel; // set by AI triage
  ai_first_response?: string; // AI's initial triage response
  is_resolved: boolean;
  resolved_reply_id?: string;
  expert_responded: boolean;
  view_count: number;
  reply_count: number;
  helpful_count: number; // "I've been there" reactions
  created_at: string;
  updated_at: string;
}

export interface PostReply {
  id: string;
  post_id: string;
  author_id: string;
  author: Pick<User, 'id' | 'name' | 'avatar_url'>;
  expert_info?: ExpertBadge; // populated if author is an expert
  body: string;
  photo_urls: string[]; // mom can attach comparison photo
  upvotes: number;
  is_expert_response: boolean;
  is_marked_wrong: boolean; // expert can flag dangerous advice
  wrong_correction?: string;
  created_at: string;
}

export interface ExpertBadge {
  expert_id: string;
  role: ExpertRole;
  display_name: string; // e.g., "Д-р Айгерим, педиатр"
}

// ─── EXPERTS ─────────────────────────────────────────────────────────────────

export type ExpertRole = 'pediatrician' | 'psychologist' | 'gynecologist';

export interface Expert {
  id: string;
  user_id: string;
  role: ExpertRole;
  display_name: string;
  full_name: string;
  license_number: string;
  clinic?: string;
  years_experience: number;
  photo_url: string;
  bio_short: string; // 2 sentences, warm tone
  bio_long: string;
  consultation_price_video: number; // in KGS
  consultation_price_text: number; // in KGS
  rating: number; // 0–5
  review_count: number;
  community_response_count: number;
  is_active: boolean;
  accepts_consultations: boolean;
}

export interface ConsultationRequest {
  id: string;
  mom_id: string;
  expert_id: string;
  type: 'video' | 'text';
  concern_text: string;
  concern_photo_urls: string[];
  linked_post_id?: string; // link to community post for context
  status: 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
  scheduled_at?: string;
  price_kgs: number;
  payment_status: 'unpaid' | 'paid' | 'refunded';
  summary?: string; // post-consult written summary by expert
  rating?: number;
  created_at: string;
}

// ─── AI GUIDE & DEVELOPMENT ───────────────────────────────────────────────────

export interface DailyCard {
  date: string;
  baby_age_days: number;
  baby_age_display: string; // "6 недель и 3 дня"
  milestone_title: string;
  milestone_body: string;
  activity_title: string;
  activity_body: string;
  watch_for: string;
  mom_tip: string;
  affirmation: string;
}

export interface MonthlyReport {
  month_number: number; // 1–24
  title: string;
  physical_milestones: string[];
  cognitive_milestones: string[];
  social_milestones: string[];
  sleep_guide: string;
  feeding_guide: string;
  local_food_intro?: string; // month-appropriate local foods
  vaccination_due?: VaccinationItem[];
  watch_for: string[];
}

export interface VaccinationItem {
  name: string;
  name_ru: string;
  due_age_weeks: number;
  notes?: string;
}

export interface AIChatMessage {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  urgency_flag?: UrgencyLevel;
  created_at: string;
}

// ─── MARKETPLACE ─────────────────────────────────────────────────────────────

export interface Product {
  id: string;
  seller_id: string;
  name: string;
  name_ru: string;
  description: string;
  category: ProductCategory;
  price_kgs: number;
  photos: string[];
  is_eco_certified: boolean;
  eco_badge: 'none' | 'bronze' | 'silver' | 'gold';
  suitable_age_min_months: number;
  suitable_age_max_months?: number;
  doctor_recommended: boolean;
  doctor_id?: string;
  in_stock: boolean;
  rating: number;
  review_count: number;
}

export type ProductCategory =
  | 'diapers'
  | 'clothing'
  | 'toys'
  | 'feeding'
  | 'bedding'
  | 'hygiene'
  | 'nutrition_mom'
  | 'other';

// ─── CAKES & LOCAL SERVICES ───────────────────────────────────────────────────

export interface CakeBaker {
  id: string;
  user_id: string;
  business_name: string;
  city: City;
  bio: string;
  portfolio_photos: string[];
  min_price_kgs: number;
  max_price_kgs: number;
  delivery_available: boolean;
  flavors: string[];
  styles: CakeStyle[];
  rating: number;
  review_count: number;
  whatsapp_number: string; // MVP: orders via WhatsApp
  is_verified: boolean;
}

export type CakeStyle =
  | 'birthday_1year'    // Торт на 1 год / туйлоо
  | 'photo_print'       // С фотопечатью
  | 'themed'            // Тематический
  | 'minimalist'
  | 'floral'
  | 'custom';

export interface CakeReview {
  id: string;
  baker_id: string;
  mom_id: string;
  rating: number; // 1–5
  text: string;
  cake_photo_url: string; // photo-verified
  created_at: string;
}
