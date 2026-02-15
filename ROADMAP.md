# Tibo Aquaculture-AI Roadmap

## Phase 1: Foundation (Current Status: Production Candidate 1.0)
- [x] **Core Monitoring:** Real-time telemetry for Temperature, pH, Dissolved Oxygen, Solar Power, and Borehole Flow.
- [x] **Executive Dashboard:** Financial overview (Revenue, OPEX, Net Profit).
- [x] **AI Core:** Autopilot toggle, sector-specific automation status, and neural logs.
- [x] **Unit Management:** Detailed inventory per tank (Sensors, Pumps, Feeders).
- [x] **High-Tech UI:** "Neon Green & Metallic Black" aesthetic with glassmorphism and data visualization.

## Phase 2: Visual AI & Smart Feeding (The "Money" Maker)
**Goal:** Maximize Feed Conversion Ratio (FCR) and minimize waste.
- [ ] **Visual Appetite Analysis:** Integrate camera feeds (Raspberry Pi/SiMa.ai) to analyze surface activity during feeding.
    - *Action:* AI dispenses feed only when "frenzied" activity is detected; stops immediately when activity slows.
- [ ] **FCR Modeling:** Correlate weekly sample weights with feed dispensed and temperature.
    - *Output:* actionable advice like "Drop temp by 0.5°C to improve FCR to 1.2."

## Phase 3: Predictive Analytics (Preventing Kills)
**Goal:** Predict critical events before they happen.
- [ ] **Oxygen Dip Predictor:** Analyze algae bloom trends to predict nighttime oxygen crashes.
    - *Action:* Pre-emptively activate aeration at optimal times (e.g., 2 AM) to save power and preventing suffocation.
- [ ] **Biomass Estimation:** Use stereo vision cameras to estimate fish size and total biomass volume.
    - *Output:* Precise harvest date predictions and valuation (e.g., "Projected Harvest: Nov 14th, $15,400").

## Phase 4: Health & Disease Early Warning
**Goal:** Detect anomalies before mass mortality.
- [ ] **Acoustic Monitoring:** Hydrophones to detect changes in feeding sounds or stress behaviors.
- [ ] **Visual Anomaly Detection:** Edge AI detection of "flashing" (rubbing), white spots, or lethargic swimming.
    - *Alert:* "Tank 02: Potential Parasitic Activity. Recommend salt bath."

## Phase 5: Market-Driven Optimization
**Goal:** Maximize profit, not just yield.
- [ ] **Dynamic Harvest Timing:** Connect to real-time market price APIs.
    - *Suggestion:* "Hold harvest for 4 days. Projected revenue increase: $1,200 vs. feed cost: $150."
