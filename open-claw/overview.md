# OpenClaw cho người mới bắt đầu

## 1) OpenClaw là gì?

OpenClaw là một **AI assistant self-hosted** chạy trên máy của bạn hoặc server của bạn. Hiểu đơn giản, nó đóng vai trò như một **cổng trung gian (Gateway)** để kết nối các ứng dụng chat quen thuộc như WhatsApp, Telegram, Discord, iMessage… với các AI agent và model mà bạn chọn dùng. Theo tài liệu chính thức, bạn có thể cài nhanh qua CLI, cấu hình Gateway, sau đó chat với agent ngay trong dashboard hoặc qua các kênh chat đã kết nối.

Nói ngắn gọn:

- **Chat app** là nơi bạn nhắn tin cho AI
- **OpenClaw Gateway** là bộ não điều phối ở giữa
- **Model AI** là nơi sinh câu trả lời
- **Agent / Skills / Tools** là thứ quyết định AI có thể làm gì ngoài việc trả lời text

---

## 2) Dùng OpenClaw để làm gì?

Với người mới, có thể hình dung OpenClaw theo 3 nhóm use case chính:

### a. Biến AI thành “trợ lý cá nhân”
Ví dụ:
- nhắn Telegram/WhatsApp để hỏi việc trong ngày
- yêu cầu AI tóm tắt nội dung
- gọi AI ngay từ dashboard trên trình duyệt

### b. Biến AI thành “agent làm việc”
Ví dụ:
- agent coding
- agent research
- agent xử lý tài liệu
- agent theo từng vai trò riêng trong cùng hệ thống

### c. Mở rộng bằng plugin
OpenClaw hỗ trợ plugin để thêm:
- channel mới
- model provider mới
- tool mới
- skills mới
- speech / image / web search / document processing

---

## 3) Tư duy đúng về kiến trúc OpenClaw

Người mới thường bị rối vì có quá nhiều khái niệm. Cách hiểu đơn giản nhất là:

```text
Bạn -> Ứng dụng chat / Dashboard -> OpenClaw Gateway -> Model AI
                                      |                  |
                                      |                  └─ sinh câu trả lời
                                      |
                                      ├─ Agent
                                      ├─ Skills
                                      ├─ Tools
                                      └─ Plugins
```

### Thành phần chính

#### Gateway
Đây là thành phần trung tâm. Tài liệu chính thức mô tả Gateway là nơi nhận message từ các kênh chat, điều phối agent, model, tools và plugins. Sau khi onboarding xong, bạn có thể kiểm tra bằng `openclaw gateway status`; tài liệu cho biết Gateway mặc định lắng nghe ở cổng `18789`.

#### Channel
Channel là “đường vào” để bạn nhắn cho AI, ví dụ Telegram, Discord, WhatsApp… OpenClaw có CLI để thêm / xoá / đăng nhập các channel như `openclaw channels add`, `openclaw channels login`.

#### Agent
Agent là “nhân cách làm việc” hoặc “vai trò vận hành”. Một agent có thể được dùng cho coding, một agent khác cho personal assistant, một agent khác cho social/research. Tài liệu multi-agent cho biết mỗi agent có workspace riêng và có thể bind từng channel/account vào agent tương ứng.

#### Workspace
Workspace là “nhà” của agent. Theo docs, đây là thư mục làm việc mặc định cho file tools và context của agent. Nó **khác** với `~/.openclaw/`, nơi lưu config, credentials, session. Với beginner, hãy nhớ đơn giản thế này:
- `~/.openclaw/` = nơi OpenClaw lưu cấu hình hệ thống
- `workspace` = nơi agent đọc/ghi file để làm việc

#### Tools
Tools là các hàm mà agent có thể gọi. Docs mô tả tools như các function có cấu trúc, ví dụ chạy lệnh, duyệt web, tìm kiếm web, gửi message… Model nhìn thấy chúng như “chức năng có thể gọi”.

#### Skills
Skills không phải là tool. Skills là lớp “dạy agent khi nào và cách nào dùng tool”. Hiểu đơn giản:
- **Tool** = agent có cái búa
- **Skill** = agent biết khi nào nên dùng búa và dùng ra sao

Theo docs, skills có thể được nạp từ 3 nơi:
- bundled skills đi kèm bản cài
- `~/.openclaw/skills`
- `<workspace>/skills`

#### Plugin
Plugin là cách mở rộng hệ thống. Plugin có thể thêm channel, model provider, tools, skills, speech, image generation… OpenClaw hỗ trợ cài plugin qua lệnh `openclaw plugins install <package-name>`.

---

## 4) Cách hình dung luồng hoạt động

Ví dụ bạn nhắn trên Telegram:

1. Bạn gửi tin nhắn tới bot / account đã kết nối
2. Channel chuyển message vào OpenClaw Gateway
3. Gateway xác định agent nào sẽ xử lý
4. Agent đọc context + skills + workspace
5. Nếu cần, agent gọi tool
6. Gateway gọi model AI để sinh hoặc hoàn thiện câu trả lời
7. Kết quả được gửi ngược lại về Telegram

Đây là lý do OpenClaw khác việc “chat trực tiếp với 1 model”:
- nó có lớp điều phối
- có thể nhiều agent
- có thể nhiều channel
- có thể dùng tools/plugins
- có thể tự host để kiểm soát hơn

---

## 5) Người mới cần nhớ 7 khái niệm trước tiên

### 1. OpenClaw không đồng nghĩa với model
OpenClaw **không phải** bản thân GPT/Claude/Gemini. Nó là lớp orchestration/gateway giúp bạn dùng model theo cách có tổ chức hơn.

### 2. OpenClaw không chỉ để coding
Dù nhiều người dùng cho coding agent, docs chính thức mô tả nó như một personal AI assistant đa kênh.

### 3. Cấu hình chính nằm ở đâu?
Tài liệu configuration cho biết file cấu hình nằm ở:

```bash
~/.openclaw/openclaw.json
```

Config format là **JSON5**, nên có thể dùng comment và trailing comma.

### 4. Workspace không phải sandbox tuyệt đối
Docs agent workspace nói rõ: workspace là thư mục mặc định, **không tự động là hard sandbox**. Relative path sẽ bám theo workspace, nhưng absolute path vẫn có thể chạm tới nơi khác trên host nếu bạn chưa bật sandboxing. Đây là điểm người mới rất dễ bỏ qua.

### 5. Dashboard là nơi test nhanh nhất
Docs onboarding nói cách nhanh nhất để chat lần đầu là mở dashboard:

```bash
openclaw dashboard
```

Bạn có thể test trước trên dashboard rồi mới cấu hình Telegram/Discord/WhatsApp.

### 6. Windows nên ưu tiên WSL2
Docs onboarding CLI ghi rõ Windows được khuyến nghị dùng **WSL2**. Nếu bạn ở Windows mà cài trực tiếp rồi gặp lỗi môi trường, đó là chuyện khá dễ xảy ra.

### 7. Multi-agent là tính năng thật, không phải tự nghĩ thêm
Docs multi-agent cho thấy OpenClaw hỗ trợ tạo nhiều agent, mỗi agent có workspace riêng, và có thể bind inbound traffic từ channel cụ thể vào từng agent.

---

## 6) Cài đặt cho beginner: nên đi theo đường nào?

### Lộ trình dễ nhất
Tài liệu install ghi cách cài khuyến nghị là script cài đặt chính thức. Sau đó dùng onboarding CLI:

```bash
openclaw onboard
```

Onboarding sẽ hướng dẫn chọn model provider, nhập API key, cấu hình Gateway, channels, skills và workspace mặc định.

### Sau khi cài xong, kiểm tra tối thiểu

```bash
openclaw gateway status
openclaw dashboard
```

Nếu dashboard mở được thì bạn đã có thể thử chat mà **chưa cần** cấu hình channel ngoài.

### Khi nào mới cấu hình channel?
Sau khi dashboard chạy ổn. Lúc đó mới thêm Telegram/Discord/WhatsApp bằng nhóm lệnh `openclaw channels ...`.

---

## 7) Các lệnh beginner nên biết

> Lưu ý: tên lệnh có thể thay đổi theo version, nhưng các lệnh dưới đây đều đang xuất hiện trong docs chính thức hiện tại.

```bash
openclaw onboard
openclaw configure
openclaw gateway status
openclaw gateway restart
openclaw dashboard
openclaw channels add
openclaw channels login
openclaw agents add <name>
openclaw agents list
openclaw agents bind --agent <name> --bind <channel>
openclaw plugins list
openclaw plugins install <package-name>
openclaw health
```

Cách nhớ nhanh:
- `onboard` = cài lần đầu
- `configure` = chỉnh lại cấu hình
- `gateway ...` = kiểm tra / restart trung tâm điều phối
- `dashboard` = giao diện web để test
- `channels ...` = kết nối app chat
- `agents ...` = tạo và route agent
- `plugins ...` = mở rộng khả năng

---

## 8) Khi nào nên dùng OpenClaw, khi nào không?

### Nên dùng khi
- bạn muốn AI chạy qua app chat quen thuộc
- bạn muốn nhiều agent theo nhiều vai trò
- bạn muốn tự host để kiểm soát hơn
- bạn muốn mở rộng bằng plugin, skills, tools
- bạn muốn tách “kênh giao tiếp” với “model backend”

### Chưa cần dùng khi
- bạn chỉ muốn chat đơn giản với 1 model trong web UI
- bạn chưa cần tool/plugin/channel nào
- bạn chưa sẵn sàng xử lý config, API key, môi trường chạy

Nói thật với beginner: nếu bạn chỉ cần “một chatbot để hỏi đáp”, OpenClaw có thể hơi thừa. Nó đáng giá khi bạn bắt đầu cần **agent hóa** và **orchestration**.

---

## 9) Ưu điểm và hạn chế

### Ưu điểm
- chạy self-hosted trên máy/server của bạn
- hỗ trợ nhiều kênh chat
- có dashboard để test nhanh
- hỗ trợ multi-agent
- kiến trúc plugin mở rộng khá mạnh
- tách bạch agent / tools / skills / channels rõ ràng

### Hạn chế
- nhiều khái niệm, mới vào khá dễ rối
- cần hiểu config, model provider, API key
- nếu dùng Windows native có thể gặp friction hơn WSL2
- workspace không phải sandbox tuyệt đối nếu không cấu hình thêm bảo mật
- càng mở rộng nhiều plugin/channel thì vận hành càng phức tạp

---

## 10) Những hiểu lầm beginner hay gặp

### Hiểu lầm 1: “OpenClaw là một model AI”
Sai. Nó là lớp điều phối để dùng model.

### Hiểu lầm 2: “Có OpenClaw là không cần model/API key”
Sai. Bạn vẫn cần model provider hoặc backend model phù hợp trong quá trình onboarding/cấu hình.

### Hiểu lầm 3: “Agent = Tool”
Sai.
- agent = thực thể làm việc
- tool = chức năng agent gọi
- skill = cách dạy agent dùng tool

### Hiểu lầm 4: “Workspace là vùng cách ly tuyệt đối”
Sai. Docs đã cảnh báo đây là default cwd/context, không mặc định là hard sandbox.

### Hiểu lầm 5: “Phải nối channel trước mới test được”
Không nhất thiết. Docs nói bạn có thể mở dashboard để chat trước.

---

## 11) Lộ trình học OpenClaw cho người mới

### Giai đoạn 1: hiểu khái niệm
Bạn chỉ cần nắm chắc:
- Gateway
- Channel
- Agent
- Workspace
- Tool
- Skill
- Plugin

### Giai đoạn 2: chạy local tối thiểu
Mục tiêu:
- cài OpenClaw
- chạy `openclaw onboard`
- mở dashboard
- chat thử 1 lần

### Giai đoạn 3: tạo 2 agent khác nhau
Ví dụ:
- `personal`
- `coding`

Sau đó bind 2 kênh hoặc 2 account khác nhau vào 2 agent.

### Giai đoạn 4: thêm plugin/skill
Bắt đầu mở rộng dần:
- web search
- document processing
- voice
- image
- custom skills

### Giai đoạn 5: siết bảo mật và vận hành
Đọc thêm về:
- security
- config tách môi trường
- plugin trust boundary
- sandboxing / host access

---

## 12) Một cấu hình tối thiểu cần hiểu

Docs configuration examples có ví dụ “absolute minimum” như sau:

```json5
{
  agent: { workspace: "~/.openclaw/workspace" },
  channels: { whatsapp: { allowFrom: ["+15555550123"] } },
}
```

Ý nghĩa beginner-level:
- chỉ định workspace cho agent
- bật 1 channel
- giới hạn ai được phép nhắn tới bot

Bạn chưa cần nhớ từng field ngay. Chỉ cần hiểu config của OpenClaw xoay quanh các nhóm chính:
- `agent`
- `channels`
- `skills`
- `plugins`
- model/provider tương ứng

---

## 13) Cách học ít đau đầu nhất

Thứ tự tôi khuyên:

1. **Đừng đọc hết docs ngay từ đầu**
2. Chạy `openclaw onboard`
3. Mở dashboard và chat thử
4. Tạo 1 agent duy nhất trước
5. Chỉ khi nào chạy ổn mới thêm channel
6. Chỉ khi nào thật cần mới thêm plugin/skill
7. Sau cùng mới học multi-agent và security sâu hơn

Nếu đi ngược lại, ví dụ vừa mới cài đã cố multi-agent + plugin + nhiều channel, gần như chắc chắn bạn sẽ rối.

---

## 14) Kết luận ngắn gọn

Nếu giải thích OpenClaw cho beginner bằng 1 câu:

> OpenClaw là một nền tảng self-hosted giúp bạn biến các model AI thành trợ lý/agent có thể làm việc qua nhiều ứng dụng chat, có khả năng mở rộng bằng tools, skills, plugins và hỗ trợ nhiều agent riêng biệt.

Còn nếu giải thích bằng 3 ý:
- nó là **gateway/orchestrator**, không phải model
- nó giúp AI làm việc qua **nhiều channel** và **nhiều agent**
- sức mạnh thật của nó nằm ở **tools + skills + plugins**

---

## 15) Nguồn tham khảo chính thức

- OpenClaw Docs: https://docs.openclaw.ai/
- GitHub repository: https://github.com/openclaw/openclaw
- Getting Started: https://docs.openclaw.ai/start/getting-started
- Onboarding (CLI): https://docs.openclaw.ai/start/wizard
- Install: https://docs.openclaw.ai/install
- Configuration: https://docs.openclaw.ai/gateway/configuration
- Configuration Reference: https://docs.openclaw.ai/gateway/configuration-reference
- Configuration Examples: https://docs.openclaw.ai/gateway/configuration-examples
- Agent Workspace: https://docs.openclaw.ai/concepts/agent-workspace
- Agent Runtime: https://docs.openclaw.ai/concepts/agent
- Multi-Agent Routing: https://docs.openclaw.ai/concepts/multi-agent
- Chat Channels: https://docs.openclaw.ai/channels
- CLI / channels: https://docs.openclaw.ai/cli/channels
- CLI / agents: https://docs.openclaw.ai/cli/agents
- Tools and Plugins: https://docs.openclaw.ai/tools
- Skills: https://docs.openclaw.ai/tools/skills
- Skills Config: https://docs.openclaw.ai/tools/skills-config
- Plugins: https://docs.openclaw.ai/tools/plugin
- Building Plugins: https://docs.openclaw.ai/plugins/building-plugins
- Security: https://docs.openclaw.ai/gateway/security
