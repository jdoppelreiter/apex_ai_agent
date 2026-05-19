(function () {
  if (customElements.get('c-ticker')) return;

  class CTicker extends HTMLElement {
    static get observedAttributes() {
      return ['interval', 'status', 'event'];
    }

    constructor() {
      super();

      this._shadow = this.attachShadow({ mode: 'closed' });
      
      this._state = {
        timer: null,
        raf: null,
        startTime: 0,
        interval: 3000
      };

      // Use this._shadow instead of this.shadowRoot
      this._shadow.innerHTML = `
        <style>
          :host {
            display: inline-block;
            font-family: inherit;
          }
          :host([status="disabled"]) { display: none; }
          .wrap { font-size: 0.9rem; color: var(--ut-body-text-color, inherit); }
          .progress-wrapper {
            width: 100%;
            min-width: 140px;
            height: 6px;
            background: var(--ut-palette-neutral-20, #eee);
            border-radius: 3px;
            margin-top: 4px;
            overflow: hidden;
          }
          .progress-bar {
            width: 0%;
            height: 100%;
            background: var(--ut-palette-primary-main, #4caf50);
            will-change: width;
          }
        </style>
        <div class="wrap" role="timer" aria-live="polite">
          <div>Next check in: <span class="countdown">0.0</span>s</div>
          <div class="progress-wrapper">
            <div class="progress-bar" role="progressbar" aria-valuemin="0" aria-valuemax="100"></div>
          </div>
        </div>
      `;

      this._countdownEl = this._shadow.querySelector('.countdown');
      this._barEl       = this._shadow.querySelector('.progress-bar');
    }

    // ... rest of the methods (interval, status, eventName, etc.) remain the same
    
    get interval() {
      const v = parseInt(this.getAttribute('interval'), 10);
      return Number.isFinite(v) && v >= 100 ? v : 3000;
    }
    get status()    { return this.getAttribute('status') || 'enabled'; }
    get eventName() { return this.getAttribute('event') || 'checkLastMessage'; }

    connectedCallback() {
      this._sync();
    }

    disconnectedCallback() {
      this._stop();
    }

    attributeChangedCallback(name, oldVal, newVal) {
      if (oldVal !== newVal && this.isConnected) {
        this._sync();
      }
    }

    _sync() {
      this._stop();
      if (this.status === 'enabled') {
        this._state.interval = this.interval;
        this._start();
      }
    }

    _start() {
      this._state.startTime = Date.now();
      
      const tick = () => {
        this._fire();
        this._state.startTime = Date.now();
        this._state.timer = setTimeout(tick, this._state.interval);
      };

      const updateUI = () => {
        const elapsed = Date.now() - this._state.startTime;
        const progress = Math.min(1, elapsed / this._state.interval);
        const remaining = Math.max(0, (this._state.interval - elapsed) / 1000);

        this._barEl.style.width = `${progress * 100}%`;
        this._countdownEl.textContent = remaining.toFixed(1);

        this._state.raf = requestAnimationFrame(updateUI);
      };

      this._state.timer = setTimeout(tick, this._state.interval);
      this._state.raf = requestAnimationFrame(updateUI);
    }

    _stop() {
      clearTimeout(this._state.timer);
      cancelAnimationFrame(this._state.raf);
      if (this._barEl) this._barEl.style.width = '0%';
    }

    _fire() {
      const detail = Object.fromEntries(
        Array.from(this.attributes).map(attr => [attr.name, attr.value])
      );

      this.dispatchEvent(new CustomEvent(this.eventName, {
        detail, bubbles: false, composed: true
      }));
      if (window.apex?.event?.trigger) {
        apex.event.trigger(this, this.eventName, detail);
      }
    }
  }

  customElements.define('c-ticker', CTicker);

})();
