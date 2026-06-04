import type { RoomRule } from './canvasState';

export const DEFAULT_ROOM_RULE: RoomRule = {
  trigger_type: 'button_step',
  trigger_id: '',
  action_type: 'toggle_gate',
  action_id: ''
};

const ENTITY_TRIGGER_ASSETS: Record<string, string> = {
  button_step: 'trigger_button',
  lever_flip: 'trigger_lever',
  target_hit: 'target_practice',
  pressure_plate_on: 'trigger_pressure_plate',
  pressure_plate_off: 'trigger_pressure_plate'
};

const LOGIC_GATE_TRIGGERS = new Set(['logic_gate_on', 'logic_gate_off']);
const LOGIC_GATE_ACTIONS = new Set([
  'set_logic_input_1_on',
  'set_logic_input_1_off',
  'set_logic_input_2_on',
  'set_logic_input_2_off'
]);

export function createDefaultRoomRule(): RoomRule {
  return { ...DEFAULT_ROOM_RULE };
}

export function addRoomRule(rules: RoomRule[] | undefined): RoomRule[] {
  return [...(rules ?? []), createDefaultRoomRule()];
}

export function deleteRoomRule(rules: RoomRule[] | undefined, index: number): RoomRule[] {
  return (rules ?? []).filter((_, ruleIndex) => ruleIndex !== index);
}

export function triggerAssetForRule(rule: RoomRule): string | null {
  return ENTITY_TRIGGER_ASSETS[rule.trigger_type] ?? null;
}

export function usesLogicGateTrigger(rule: RoomRule): boolean {
  return LOGIC_GATE_TRIGGERS.has(rule.trigger_type);
}

export function usesLogicGateAction(rule: RoomRule): boolean {
  return LOGIC_GATE_ACTIONS.has(rule.action_type);
}
