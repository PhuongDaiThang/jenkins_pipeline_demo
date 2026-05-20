# Jenkins Spring Boot + React Vite Demo

Project này dùng để học Jenkins Pipeline bằng một app nhỏ nhưng đủ thực tế:

- `backend/`: Spring Boot REST API
- `frontend/`: React + Vite + TypeScript
- `Jenkinsfile`: pipeline CI/CD mẫu cho Jenkins agent Linux/macOS/WSL
- `Jenkinsfile.windows`: pipeline CI/CD mẫu cho Jenkins agent Windows
- `docker-compose.yml`: chạy app local bằng Docker
- `docker-compose.jenkins.yml`: Jenkins deploy local demo khi bật parameter `DEPLOY_LOCAL`

## 1. Kiến trúc project

```text
jenkins-spring-react-demo/
├── backend/
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/
├── frontend/
│   ├── package.json
│   ├── Dockerfile
│   ├── nginx/default.conf
│   └── src/
├── Jenkinsfile
├── Jenkinsfile.docker-agents
├── docker-compose.yml
├── docker-compose.jenkins.yml
├── scripts/
└── docs/
```

## 2. Yêu cầu cài trên máy/Jenkins agent

Bản đơn giản nhất yêu cầu Jenkins agent có sẵn:

- Java 17+
- Maven 3.9+
- Node.js 18+ hoặc 20+
- npm
- Docker + Docker Compose
- Git

Nếu Docker chạy trên Windows, hãy bật Docker Desktop trước khi chạy kịch bản Docker.

## 3. Chạy local không cần Jenkins

### Windows PowerShell

```powershell
./scripts/run-local.ps1
```

Hoặc chạy Docker:

```powershell
./scripts/docker-up.ps1
```

### Linux/macOS/Git Bash

```bash
./scripts/run-local.sh
```

Hoặc chạy Docker:

```bash
./scripts/docker-up.sh
```

Sau khi chạy Docker:

- Frontend: http://localhost:3000
- Backend: http://localhost:8080/api/hello

## 4. Chạy từng phần bằng tay

### Backend

```bash
cd backend
mvn test
mvn spring-boot:run
```

Test API:

```bash
curl http://localhost:8080/api/hello
```

### Frontend

```bash
cd frontend
npm install
npm test -- --run
npm run dev
```

Mở:

```text
http://localhost:5174
```

## 5. Jenkins chạy pipeline này như thế nào?

Pipeline nằm trong file `Jenkinsfile`.

Các stage chính:

```text
Checkout
  -> Verify Tools
  -> Backend: Test
  -> Backend: Package
  -> Frontend: Install Dependencies
  -> Frontend: Test
  -> Frontend: Build
  -> Docker: Build Images, optional
  -> Deploy Local Demo, optional
  -> Smoke Test, optional
```

Ý nghĩa:

| Stage                          | Jenkins làm gì?                                     |
| ------------------------------ | --------------------------------------------------- |
| Checkout                       | Lấy source code từ Git                              |
| Verify Tools                   | In version Java, Maven, Node, npm; kiểm tra Docker khi cần |
| Backend: Test                  | Chạy unit test backend bằng Maven                   |
| Backend: Package               | Đóng gói backend thành file `.jar`                  |
| Frontend: Install Dependencies | Cài dependency frontend                             |
| Frontend: Test                 | Chạy test frontend bằng Vitest                      |
| Frontend: Build                | Build React app ra thư mục `dist`                   |
| Docker: Build Images           | Build Docker image backend + frontend nếu bật `BUILD_DOCKER` hoặc `DEPLOY_LOCAL` |
| Deploy Local Demo              | Chạy app bằng Docker Compose nếu bật `DEPLOY_LOCAL` |
| Smoke Test                     | Gọi thử API/frontend sau deploy                     |

## 6. Cách đưa project vào Git

Sau khi giải nén zip:

```bash
cd jenkins-spring-react-demo
git init
git add .
git commit -m "Initial Jenkins pipeline demo"
```

Có thể push lên GitHub/GitLab/Bitbucket:

```bash
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```

## 7. Tạo Jenkins Pipeline job

### Cách dễ học nhất: Pipeline from SCM

1. Mở Jenkins.
2. Chọn **New Item**.
3. Nhập tên: `jenkins-spring-react-demo`.
4. Chọn **Pipeline**.
5. Ở phần **Pipeline**, chọn:
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: repo của bạn
   - Branch: `*/main`
   - Script Path: `Jenkinsfile` nếu Jenkins agent là Linux/macOS/WSL
   - Script Path: `Jenkinsfile.windows` nếu Jenkins agent chạy native Windows
6. Save.
7. Bấm **Build Now**.

Nếu repo private, cần thêm credential GitHub/GitLab/Bitbucket trong Jenkins.

## 8. Deploy local bằng Jenkins

Mặc định pipeline chỉ build/test/package và archive artifact.

Muốn Jenkins build Docker image nhưng chưa deploy, vào **Build with Parameters** và tick `BUILD_DOCKER = true`.

Muốn Jenkins chạy container thật sau khi build:

1. Vào Jenkins job.
2. Chọn **Build with Parameters**.
3. Tick `DEPLOY_LOCAL = true`.
4. Bấm Build.

Khi bật `BUILD_DOCKER` hoặc `DEPLOY_LOCAL`, Docker Desktop hoặc Docker service phải đang chạy trên Jenkins agent.

Sau khi pass:

- Frontend: http://localhost:3000
- Backend: http://localhost:8080/api/hello

Lưu ý: Jenkins agent phải chạy được Docker command.

## 9. Kịch bản thực hành để hiểu Jenkins

Xem file `docs/scenarios.md` để làm từng kịch bản:

1. Build pass lần đầu.
2. Làm backend test fail.
3. Làm frontend test fail.
4. Fix lỗi rồi chạy lại.
5. Bật deploy local.
6. Xem artifact sau build.
7. Sửa Jenkinsfile để thấy pipeline thay đổi theo code.
8. Thử branch thường và Multibranch Pipeline.

## 10. Lỗi hay gặp

| Lỗi                               | Nguyên nhân                                               | Cách xử lý                                                                   |
| --------------------------------- | --------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `mvn: command not found`          | Jenkins agent chưa có Maven                               | Cài Maven hoặc cấu hình Jenkins tools                                        |
| `node: command not found`         | Jenkins agent chưa có Node.js                             | Cài Node.js 18+/20+                                                          |
| `docker: permission denied`       | User Jenkins chưa có quyền Docker                         | Thêm user Jenkins vào group docker hoặc chạy agent có Docker quyền hợp lệ    |
| `Cannot connect to Docker daemon` | Docker chưa chạy hoặc Jenkins container không thấy Docker | Bật Docker Desktop hoặc mount Docker socket nếu Jenkins chạy trong container |
| Port `8080`/`3000` đang dùng      | App khác chiếm port                                       | Tắt app cũ hoặc đổi port trong compose                                       |
| Frontend gọi API fail khi dev     | Backend chưa chạy                                         | Chạy backend ở port 8080 trước                                               |

## 11. Dọn container demo

```bash
docker compose -f docker-compose.jenkins.yml down
```

Hoặc nếu chạy compose local:

```bash
docker compose down
```
