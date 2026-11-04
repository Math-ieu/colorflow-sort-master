// Simple, reliable Web Audio synthesizer for tactile casual game sounds

class SoundPlayer {
  private ctx: any = null;
  private enabled: boolean = true;

  constructor() {
    // AudioContext is lazily initialized on first user interaction
  }

  public setEnabled(val: boolean) {
    this.enabled = val;
  }

  public isEnabled(): boolean {
    return this.enabled;
  }

  private getAudioContext(): any {
    if (typeof window === 'undefined') return null;
    const AudioContextClass =
      (window as any).AudioContext || (window as any).webkitAudioContext;
    if (!AudioContextClass) return null;
    if (!this.ctx) {
      this.ctx = new AudioContextClass();
    }
    if (this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
    return this.ctx;
  }

  /**
   * Realistic sound of liquid pouring into a glass cylinder:
   * Pitch rises smoothly as the tube fills (acoustic Helmholtz resonance)
   * accompanied by soft liquid droplets.
   */
  public playPour(durationMs: number = 420, startFillRatio: number = 0.25, endFillRatio: number = 0.75) {
    if (!this.enabled) return;
    try {
      const ctx = this.getAudioContext();
      if (!ctx) return;

      const dur = Math.max(0.2, durationMs / 1000);
      const now = ctx.currentTime;

      // Primary resonant water stream tone
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      const startFreq = 280 + startFillRatio * 240;
      const endFreq = 340 + endFillRatio * 380;

      osc.type = 'sine';
      osc.frequency.setValueAtTime(startFreq, now);
      osc.frequency.exponentialRampToValueAtTime(endFreq, now + dur);

      gain.gain.setValueAtTime(0.01, now);
      gain.gain.linearRampToValueAtTime(0.16, now + 0.05);
      gain.gain.setValueAtTime(0.16, now + dur - 0.06);
      gain.gain.exponentialRampToValueAtTime(0.005, now + dur);

      osc.connect(gain);
      gain.connect(ctx.destination);

      osc.start(now);
      osc.stop(now + dur);

      // Gentle bubbling harmonics during pour
      const bubbleCount = Math.max(3, Math.floor(dur / 0.09));
      for (let i = 0; i < bubbleCount; i++) {
        const bTime = now + i * (dur / bubbleCount) + 0.02;
        const bOsc = ctx.createOscillator();
        const bGain = ctx.createGain();
        const progress = i / bubbleCount;
        const baseF = startFreq + (endFreq - startFreq) * progress;

        bOsc.type = 'sine';
        bOsc.frequency.setValueAtTime(baseF * 1.35, bTime);
        bOsc.frequency.exponentialRampToValueAtTime(baseF * 1.9, bTime + 0.055);

        bGain.gain.setValueAtTime(0.001, bTime);
        bGain.gain.linearRampToValueAtTime(0.08, bTime + 0.015);
        bGain.gain.exponentialRampToValueAtTime(0.001, bTime + 0.055);

        bOsc.connect(bGain);
        bGain.connect(ctx.destination);

        bOsc.start(bTime);
        bOsc.stop(bTime + 0.06);
      }
    } catch {
      // Ignore if audio is unsupported
    }
  }

  /**
   * Sound of tapping / lifting a test tube
   */
  public playTap() {
    if (!this.enabled) return;
    try {
      const ctx = this.getAudioContext();
      if (!ctx) return;

      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      osc.type = 'triangle';
      osc.frequency.setValueAtTime(520, ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(780, ctx.currentTime + 0.06);

      gain.gain.setValueAtTime(0.14, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.06);

      osc.connect(gain);
      gain.connect(ctx.destination);

      osc.start();
      osc.stop(ctx.currentTime + 0.06);
    } catch {
      // Ignore
    }
  }

  /**
   * Sound when a single tube is completely sorted (4/4 matching colors)
   */
  public playTubeComplete() {
    if (!this.enabled) return;
    try {
      const ctx = this.getAudioContext();
      if (!ctx) return;

      const notes = [659.25, 880, 1174.66]; // E5, A5, D6 crystal chime
      notes.forEach((freq, idx) => {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        const start = ctx.currentTime + idx * 0.065;

        osc.type = 'sine';
        osc.frequency.setValueAtTime(freq, start);

        gain.gain.setValueAtTime(0.001, start);
        gain.gain.linearRampToValueAtTime(0.18, start + 0.015);
        gain.gain.exponentialRampToValueAtTime(0.005, start + 0.28);

        osc.connect(gain);
        gain.connect(ctx.destination);

        osc.start(start);
        osc.stop(start + 0.29);
      });
    } catch {
      // Ignore
    }
  }

  /**
   * Soft tactile error thud when attempting an invalid pour
   */
  public playInvalid() {
    if (!this.enabled) return;
    try {
      const ctx = this.getAudioContext();
      if (!ctx) return;

      const now = ctx.currentTime;
      [0, 0.08].forEach((offset, idx) => {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();

        osc.type = 'triangle';
        osc.frequency.setValueAtTime(idx === 0 ? 190 : 150, now + offset);
        osc.frequency.exponentialRampToValueAtTime(110, now + offset + 0.06);

        gain.gain.setValueAtTime(0.12, now + offset);
        gain.gain.exponentialRampToValueAtTime(0.005, now + offset + 0.06);

        osc.connect(gain);
        gain.connect(ctx.destination);

        osc.start(now + offset);
        osc.stop(now + offset + 0.065);
      });
    } catch {
      // Ignore
    }
  }

  /**
   * Victory sound fanfare
   */
  public playWin() {
    if (!this.enabled) return;
    try {
      const ctx = this.getAudioContext();
      if (!ctx) return;

      const notes = [523.25, 659.25, 783.99, 1046.5]; // C5, E5, G5, C6
      notes.forEach((freq, idx) => {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(freq, ctx.currentTime + idx * 0.1);

        gain.gain.setValueAtTime(0, ctx.currentTime + idx * 0.1);
        gain.gain.linearRampToValueAtTime(0.25, ctx.currentTime + idx * 0.1 + 0.02);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + idx * 0.1 + 0.35);

        osc.connect(gain);
        gain.connect(ctx.destination);

        osc.start(ctx.currentTime + idx * 0.1);
        osc.stop(ctx.currentTime + idx * 0.1 + 0.35);
      });
    } catch {
      // Ignore
    }
  }

  /**
   * Click / tactile press sound
   */
  public playClick() {
    if (!this.enabled) return;
    try {
      const ctx = this.getAudioContext();
      if (!ctx) return;

      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      osc.type = 'square';
      osc.frequency.setValueAtTime(300, ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(150, ctx.currentTime + 0.03);

      gain.gain.setValueAtTime(0.1, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.03);

      osc.connect(gain);
      gain.connect(ctx.destination);

      osc.start();
      osc.stop(ctx.currentTime + 0.03);
    } catch {
      // Ignore
    }
  }
}

export const audioManager = new SoundPlayer();
