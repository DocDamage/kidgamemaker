import wave
import struct
import math
import os

def write_wav(filename, duration, get_freq, get_volume=None):
    sample_rate = 22050
    num_samples = int(duration * sample_rate)
    
    # Ensure directory exists
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    
    with wave.open(filename, 'w') as wav:
        wav.setnchannels(1) # mono
        wav.setsampwidth(2) # 16-bit (2 bytes)
        wav.setframerate(sample_rate)
        
        phase = 0.0
        for i in range(num_samples):
            t = i / sample_rate
            freq = get_freq(t, duration)
            phase += 2 * math.pi * freq / sample_rate
            val = math.sin(phase)
            
            # Custom volume envelope or standard linear decay
            if get_volume:
                vol = get_volume(t, duration)
            else:
                vol = 1.0 - (t / duration) # default decay
                
            val *= vol
            
            sample = int(val * 32767)
            wav.writeframesraw(struct.pack('<h', sample))
    print(f"Generated {filename}")

# 1. Coin Chime: two notes
def coin_freq(t, duration):
    if t < 0.08:
        return 987.77  # B5
    else:
        return 1318.51 # E6

def coin_vol(t, duration):
    if t < 0.08:
        return 0.5
    else:
        return 0.5 * (1.0 - (t - 0.08) / (duration - 0.08))

# 2. Jump Boing: frequency sweeps upwards
def jump_freq(t, duration):
    return 150 + (600 - 150) * (t / duration)

# 3. Hit Retro: rapid downwards frequency sweep
def hit_freq(t, duration):
    return 800 - (800 - 80) * (t / duration)

# 4. Space BGM BGM loop (2 seconds)
def space_bgm_freq(t, duration):
    # Mysterious, low arpeggios (A minor pentatonic)
    notes = [110.0, 130.81, 146.83, 164.81, 196.0, 220.0]
    idx = int((t * 2.5) % len(notes))
    return notes[idx]

def space_bgm_vol(t, duration):
    # Pulsing volume
    return 0.15 + 0.1 * math.sin(2 * math.pi * t * 1.25)

# 5. Candy BGM (2 seconds)
def candy_bgm_freq(t, duration):
    # Sweet, high pitched arpeggios (C major)
    notes = [523.25, 659.25, 783.99, 1046.50]
    idx = int((t * 6.0) % len(notes))
    return notes[idx]

def candy_bgm_vol(t, duration):
    # Sharp rhythmic notes
    note_t = (t * 6.0) % 1.0
    return 0.12 * (1.0 - note_t)

# 6. Jungle BGM (2 seconds)
def jungle_bgm_freq(t, duration):
    # Bouncy jungle beat (tribal melody)
    notes = [146.83, 164.81, 220.0, 220.0, 293.66, 329.63]
    idx = int((t * 4.0) % len(notes))
    return notes[idx]

def jungle_bgm_vol(t, duration):
    # Syncopated rhythm
    note_t = (t * 4.0) % 1.0
    return 0.15 * (1.0 - note_t * 0.8)

# 7. Ice BGM (2.5 seconds)
def ice_bgm_freq(t, duration):
    # Twinkling, high bell-like tones (Pentatonic Major)
    notes = [587.33, 659.25, 880.00, 987.77, 1174.66]
    idx = int((t * 2.0) % len(notes)) # slow
    return notes[idx]

def ice_bgm_vol(t, duration):
    # Long, ringing decay
    note_t = (t * 2.0) % 1.0
    return 0.12 * (1.0 - note_t * 0.9)

# 8. Volcano BGM (2.0 seconds)
def volcano_bgm_freq(t, duration):
    # Fast, tense minor notes (chromatic feel)
    notes = [110.00, 116.54, 130.81, 138.59, 110.00, 146.83]
    idx = int((t * 5.0) % len(notes)) # fast
    return notes[idx]

def volcano_bgm_vol(t, duration):
    # Sharp tribal hits
    note_t = (t * 5.0) % 1.0
    return 0.18 * (1.0 - note_t * 0.95)

if __name__ == "__main__":
    audio_dir = "engine/data/assets/audio"
    write_wav(os.path.join(audio_dir, "coin.wav"), 0.3, coin_freq, coin_vol)
    write_wav(os.path.join(audio_dir, "jump.wav"), 0.25, jump_freq)
    write_wav(os.path.join(audio_dir, "hit.wav"), 0.2, hit_freq)
    write_wav(os.path.join(audio_dir, "space_bgm.wav"), 2.4, space_bgm_freq, space_bgm_vol)
    write_wav(os.path.join(audio_dir, "candy_bgm.wav"), 2.0, candy_bgm_freq, candy_bgm_vol)
    write_wav(os.path.join(audio_dir, "jungle_bgm.wav"), 2.0, jungle_bgm_freq, jungle_bgm_vol)
    write_wav(os.path.join(audio_dir, "ice_bgm.wav"), 2.5, ice_bgm_freq, ice_bgm_vol)
    write_wav(os.path.join(audio_dir, "volcano_bgm.wav"), 2.0, volcano_bgm_freq, volcano_bgm_vol)
