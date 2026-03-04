# AGENTS.md — Forex Signal Agent Workspace

## Project Overview
This is a live forex trading system running on Railway, connected to OANDA (live environment, real money).

## Architecture
- **Dashboard:** https://web-production-e56b0.up.railway.app/
- **API Endpoints:**
  - `GET /api/all-pairs` — All 8 pair analyses with scores
  - `GET /api/auto-trade` — Auto-trade status (on/off)
  - `POST /api/auto-trade/stop` — Emergency stop
  - `POST /api/auto-trade/toggle` — Toggle auto-trade
  - `GET /api/debug` — System health check
  - `GET /api/performance` — Historical performance data

## Key Files
- `signal_engine.py` — Core signal generation, PAIR_CONFIG, correlation filter
- `sentiment_analysis.py` — News + commodity sentiment scoring
- `app.py` — Dashboard, scheduler, auto-trade execution
- `data_fetcher.py` — OANDA + yfinance data pipeline
- `trade_executor.py` — Trade tracking + OANDA broker
- `technical_analysis.py` — RSI, BB, MACD, ADX, EMA indicators

## Monitoring Checklist
1. Check `/api/all-pairs` for stale or anomalous scores
2. Check `/api/debug` for OANDA connection health
3. Review open trades vs. current signal direction
4. Verify sentiment sources are returning fresh data
5. Check Railway deploy status and logs for errors
