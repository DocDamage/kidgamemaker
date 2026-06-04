export type CostumeOption = {
  id: string;
  name: string;
  color: string;
  tint: string;
};

export type HeroJobOption = {
  id: string;
  name: string;
  desc: string;
  color: string;
};

export const HERO_COSTUMES: CostumeOption[] = [
  { id: 'default', name: 'Default 🛡️', color: '#ffffff', tint: '' },
  { id: 'fire', name: 'Fire 🔥', color: '#ef4444', tint: '#ff5555' },
  { id: 'storm', name: 'Storm ⚡', color: '#eab308', tint: '#ffe040' },
  { id: 'forest', name: 'Forest 🌱', color: '#22c55e', tint: '#55ff55' },
  { id: 'void', name: 'Void 🔮', color: '#a855f7', tint: '#dd88ff' },
  { id: 'frost', name: 'Frost ❄️', color: '#3b82f6', tint: '#66bbff' }
];

export const HERO_JOBS: HeroJobOption[] = [
  { id: 'warrior', name: 'Warrior ⚔️', desc: 'Stronger melee & block', color: '#f87171' },
  { id: 'mage', name: 'Mage 🔮', desc: 'Magic wands & fast mana', color: '#c084fc' },
  { id: 'rogue', name: 'Rogue 💨', desc: 'Fast run & double dash', color: '#60a5fa' },
  { id: 'archer', name: 'Archer 🏹', desc: 'Instant rapid fire arrows', color: '#4ade80' }
];

export const BOSS_PHASE_OPTIONS = [1, 2, 3] as const;
