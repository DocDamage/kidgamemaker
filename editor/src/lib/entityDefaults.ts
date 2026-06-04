import type { EntityModifierValue, PlacedEntity } from './canvasState';

function setDefault(modifiers: PlacedEntity['modifiers'], key: string, value: EntityModifierValue) {
  if (modifiers[key] === undefined) {
    modifiers[key] = value;
  }
}

export function ensurePlacedEntityDefaults(item: PlacedEntity): void {
  if (!item.modifiers) {
    item.modifiers = { variant: 'default', scale_multiplier: 1.0 };
  }

  const { modifiers } = item;

  if (item.type === 'player' || item.category === 'heroes') {
    setDefault(modifiers, 'physics_preset', 'kidfriendly');
    setDefault(modifiers, 'costume_id', 'default');
    setDefault(modifiers, 'hero_class', 'warrior');
  }


  if (item.type === 'jelly') {
    setDefault(modifiers, 'bounce_force', 500);
  } else if (item.type === 'speed_pad') {
    setDefault(modifiers, 'boost_direction', 1);
    setDefault(modifiers, 'boost_force', 550);
  } else if (item.type === 'speech_sign') {
    setDefault(modifiers, 'speech_text', 'Hello adventurer! 🧙‍♂️');
  } else if (item.type === 'water_block') {
    setDefault(modifiers, 'water_flavor', 'normal');
    setDefault(modifiers, 'water_buoyancy', 0.5);
  } else if (item.type === 'pet') {
    setDefault(modifiers, 'pet_power', 'magnet');
  } else if (item.type === 'crumbling_cloud') {
    setDefault(modifiers, 'crumble_delay', 0.5);
    setDefault(modifiers, 'respawn_time', 3.0);
  } else if (item.type === 'hazard') {
    setDefault(modifiers, 'damage_value', 15);
  } else if (item.type === 'key_collectible' || item.type === 'locked_door') {
    setDefault(modifiers, 'key_color', 'gold');
  } else if (item.type === 'wind_zone') {
    setDefault(modifiers, 'wind_direction', 'right');
    setDefault(modifiers, 'wind_force', 300.0);
  } else if (item.type === 'zonai_fan') {
    setDefault(modifiers, 'zonai_direction', 'right');
    setDefault(modifiers, 'wind_force', 400.0);
    setDefault(modifiers, 'battery_drain', 10.0);
  } else if (item.type === 'zonai_rocket') {
    setDefault(modifiers, 'zonai_direction', 'up');
    setDefault(modifiers, 'thrust_force', 800.0);
    setDefault(modifiers, 'duration', 2.5);
  } else if (item.type === 'zonai_balloon') {
    setDefault(modifiers, 'lift_force', 250.0);
  } else if (item.type === 'zonai_spring') {
    setDefault(modifiers, 'spring_force', 600.0);
  } else if (item.type === 'zonai_beam') {
    setDefault(modifiers, 'zonai_direction', 'right');
    setDefault(modifiers, 'damage', 15.0);
    setDefault(modifiers, 'beam_range', 300.0);
  } else if (item.type === 'zonai_battery') {
    setDefault(modifiers, 'battery_capacity', 100.0);
  } else if (item.type === 'companion_pikmin') {
    setDefault(modifiers, 'pikmin_color', 'red');
  } else if (item.type === 'companion_ghost') {
    setDefault(modifiers, 'drain_rate', 10.0);
  } else if (item.type === 'companion_palico') {
    setDefault(modifiers, 'palico_color', 'calico');
  } else if (item.type === 'companion_rush') {
    setDefault(modifiers, 'rush_color', 'red');
  } else if (item.type === 'shopkeeper') {
    setDefault(modifiers, 'shop_item_1', 'alchemy_potion_speed');
    setDefault(modifiers, 'shop_price_1', 10);
    setDefault(modifiers, 'shop_item_2', 'tool_hammer');
    setDefault(modifiers, 'shop_price_2', 15);
  } else if (item.type === 'bbq_spit') {
    setDefault(modifiers, 'cook_difficulty', 'medium');
  } else if (item.type === 'grapple_ring') {
    setDefault(modifiers, 'grapple_range', 180.0);
  } else if (item.type === 'wall_run_surface' || item.type === 'ceiling_run_surface') {
    setDefault(modifiers, 'magnet_duration', 3.0);
  }

  if (item.asset_id === 'weapon_boomerang') {
    setDefault(modifiers, 'boomerang_speed', 'medium');
    setDefault(modifiers, 'damage', 15.0);
  } else if (item.asset_id === 'weapon_bomb') {
    setDefault(modifiers, 'blast_radius', 80.0);
    setDefault(modifiers, 'fuse_time', 2.0);
  } else if (item.asset_id === 'focus_amulet') {
    setDefault(modifiers, 'time_slow_factor', 0.2);
  } else if (item.asset_id === 'charge_spring') {
    setDefault(modifiers, 'powerup_type', 'charge_jump');
    setDefault(modifiers, 'charge_jump_speed', 'normal');
  }
}
