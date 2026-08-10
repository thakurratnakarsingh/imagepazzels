export interface AdminProfile {
  id: number;
  name: string;
  email: string;
  role: string;
}

export interface ActressItem {
  id: number;
  name: string;
  country?: string | null;
  biography?: string | null;
  thumbnail_image?: string | null;
}

export interface ActressImageItem {
  id: number;
  image_url: string;
  thumbnail_url: string;
  created_at: string;
}

export interface ActressLevelItem {
  level_number: number;
  difficulty: string;
  image?: ActressImageItem | null;
}

export interface SplashItem {
  id: number;
  title: string;
  subtitle?: string | null;
  image_url: string;
  display_duration: number;
  is_active: boolean;
}

export interface LoginForm {
  email: string;
  password: string;
}
