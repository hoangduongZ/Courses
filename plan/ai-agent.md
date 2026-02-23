# Checklist Học AI Agent — Production-ready, Không Chỉ Demo

---

## 1. Nền tảng LLM cho Agent

- **Prompting thực chiến:** instruction hierarchy, few-shot, tool-use prompts, guardrails
- **Output control:** JSON schema, function calling, constrained decoding (khái niệm)
- **RAG basics:** chunking, embedding, retrieval, re-ranking, citations/grounding
- **Evaluation:** hallucination types, faithfulness, relevance, regression test cho prompts

---

## 2. Agent Architecture

- **Agent vs Workflow:** khi nào cần agent tự quyết, khi nào dùng flow cứng
- **Planner/Executor pattern:** Plan → Act → Observe → Reflect
- **Multi-agent:** Router/Orchestrator + specialist agents (Search, DB, Summarizer, QA)
- **Memory:**
  - Short-term (conversation state)
  - Long-term (user profile, facts)
  - Working memory (scratchpad / intermediate state)
- **State machine:** states, transitions, retries, timeouts

---

## 3. Tooling & Integrations *(xương sống của agent)*

- **Tool interface design:** input/output contract, idempotency, error codes
- **Common tools:**
  - Web search / browser
  - DB query
  - File I/O (PDF, docs, spreadsheet)
  - Email/Calendar (nếu cần)
  - Internal APIs (CRM, ERP)
- **Safety layer cho tool:**
  - Allowlist domains/endpoints
  - Rate limit
  - PII filtering / secrets masking
  - Audit log tool calls

---

## 4. Planning & Decision Making

- **Task decomposition:** chia nhỏ nhiệm vụ, xác định dependencies
- **Routing:** chọn tool nào / agent nào dựa trên intent + confidence
- **Uncertainty handling:** "need more info" vs "best-effort answer"
- **Heuristics quan trọng:**
  - Stop conditions (khi nào dừng)
  - Budget (token/time/money)
  - Fallback strategy (khi tool fail)

---

## 5. Reliability / Production Concerns *(phần tạo khác biệt)*

- **Observability:** structured logs (traceId), tool-call logs, metrics (success rate, tool error rate, latency)
- **Error handling:** retry w/ backoff, circuit breaker, graceful degradation
- **Caching:** results cache, embedding cache, retrieval cache
- **Cost control:**
  - Model routing (cheap → expensive)
  - Summarization for context
  - Tool-first strategy
- **Security:**
  - Prompt injection defense (đặc biệt khi RAG/web)
  - Sandbox tool execution
  - Data access control theo user/role

---

## 6. Data Layer cho Agent

- **Knowledge base:** docs → ingest pipeline → embedding store
- **Vector DB:** indexing, namespaces/tenants, TTL, upsert
- **Data quality:** dedup, versioning, freshness policy
- **Citation/grounding rules:** câu nào phải dẫn nguồn, câu nào suy luận

---

## 7. Testing & Evaluation *(để agent không "hên xui")*

- **Test set theo tình huống:** happy path / edge cases / adversarial (prompt injection)
- **Automatic eval:**
  - Correctness (task success)
  - Faithfulness (đúng nguồn)
  - Tool accuracy (đúng API/query)
- **Replay & regression:** lưu trace, replay lại sau khi sửa prompt/model
- **Human-in-the-loop:** review queue cho case low confidence

---

## 8. UX cho Agent *(nhiều người bỏ qua)*

- **Progress UI:** agent đang làm gì (plan, search, execute)
- **Editable plan:** cho user sửa mục tiêu/constraints
- **Explainability:** vì sao ra quyết định, hiển thị nguồn
- **"Undo"/rollback:** nhất là agent có quyền ghi DB/gửi request

---

## 3 Project Nên Làm để "Cover Hết"

### Project 1 — Research Agent *(web + citations)*

1. Router → Search → Summarize → Cite
2. Có guardrails prompt injection + caching + eval set

### Project 2 — RAG Support Agent *(docs nội bộ)*

1. Ingest PDF/doc → retrieval → trả lời có dẫn nguồn
2. Có freshness/versioning + evaluation faithfulness

### Project 3 — Ops Agent *(tool + workflow)*

1. Nhận yêu cầu → chạy query DB/logs → tạo report → xuất file
2. Có audit log, permission, retries, rollback

---

## Thứ tự Học Tối ưu *(đỡ rối)*

| Giai đoạn | Nội dung | Mục tiêu |
|-----------|----------|-----------|
| **1** | Tool interface + workflow | Agent "dùng được" |
| **2** | RAG + grounding | Giảm hallucination |
| **3** | Planning/routing + memory | Agent "thông minh" hơn |
| **4** | Production: logging/metrics/cost/security/testing | Agent "đáng tin" |

---

> 💡 **Gợi ý tiếp theo:** Nếu bạn cho biết agent bạn muốn xây thuộc loại nào — **(A)** sales/support, **(B)** ops/DevOps, hay **(C)** data/BI — có thể chốt thành lộ trình 4–8 tuần kèm checklist "done" và demo output cụ thể.