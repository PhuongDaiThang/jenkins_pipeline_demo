# Kịch bản thực hành Jenkins Pipeline

Mục tiêu: hiểu Jenkins hoạt động qua các tình huống pass, fail, artifact, deploy và branch.

## Kịch bản 1: Build pass lần đầu

### Làm gì?

Chạy Jenkins job với parameter mặc định:

```text
DEPLOY_LOCAL = false
BUILD_DOCKER = false
```

### Bạn nên quan sát gì?

Trong Jenkins UI, pipeline sẽ chạy lần lượt:

```text
Checkout
Verify Tools
Backend: Test
Backend: Package
Frontend: Install Dependencies
Frontend: Test
Frontend: Build
```

### Học được gì?

- Jenkins đọc `Jenkinsfile` từ repo.
- Mỗi `stage` là một bước lớn trong pipeline.
- Nếu stage trước pass thì stage sau mới chạy.
- Backend test và frontend test là phần CI.
- Docker build là bước chuẩn bị deploy và chỉ chạy khi bật `BUILD_DOCKER` hoặc `DEPLOY_LOCAL`.

## Kịch bản 2: Làm backend test fail

### Sửa file

Mở file:

```text
backend/src/test/java/com/example/jenkinsdemo/HelloControllerTest.java
```

Đổi dòng:

```java
.andExpect(jsonPath("$.message", is("Hello from Spring Boot backend")))
```

thành:

```java
.andExpect(jsonPath("$.message", is("Wrong message")))
```

Commit và push:

```bash
git add .
git commit -m "Break backend test for Jenkins demo"
git push
```

### Kết quả mong đợi

Stage `Backend: Test` fail.

Các stage sau như package, frontend build, docker build sẽ không chạy tiếp.

### Học được gì?

- Jenkins chặn lỗi sớm.
- Test fail thì không package/deploy.
- Đây là vai trò chính của CI.

## Kịch bản 3: Fix backend test

Đổi `Wrong message` về:

```java
Hello from Spring Boot backend
```

Commit và push:

```bash
git add .
git commit -m "Fix backend test"
git push
```

### Học được gì?

- Mỗi lần push code, Jenkins có thể chạy lại pipeline.
- Pipeline xanh lại khi lỗi được sửa.

## Kịch bản 4: Làm frontend test fail

### Sửa file

Mở file:

```text
frontend/src/formatGreeting.test.ts
```

Đổi:

```ts
expect(formatGreeting('Hello', 'backend')).toBe('Hello - served by backend')
```

thành:

```ts
expect(formatGreeting('Hello', 'backend')).toBe('Wrong text')
```

Commit và push:

```bash
git add .
git commit -m "Break frontend test for Jenkins demo"
git push
```

### Kết quả mong đợi

Backend stages pass.

Stage `Frontend: Test` fail.

Frontend build và Docker build không chạy.

### Học được gì?

- Jenkins cho biết lỗi nằm ở stage nào.
- Backend pass không có nghĩa toàn pipeline pass.
- CI nên kiểm tra nhiều phần của hệ thống.

## Kịch bản 5: Build và deploy local bằng Jenkins

### Làm gì?

Trong Jenkins:

```text
Build with Parameters
DEPLOY_LOCAL = true
BUILD_DOCKER = false
```

### Kết quả mong đợi

Pipeline chạy thêm:

```text
Docker: Build Images
Deploy Local Demo
Smoke Test
```

Sau đó mở:

```text
http://localhost:5174
http://localhost:8080/api/hello
```

### Học được gì?

- Build/test là CI.
- Deploy local demo là CD.
- Smoke test là kiểm tra nhanh sau deploy.

## Kịch bản 6: Xem artifact sau build

Sau khi build pass, vào Jenkins build detail.

Tìm phần artifact.

Bạn sẽ thấy:

```text
backend/target/*.jar
frontend/dist/**
```

### Học được gì?

- Jenkins có thể lưu output sau build.
- Artifact là sản phẩm build có thể dùng để deploy/release.

## Kịch bản 7: Sửa Jenkinsfile

Thêm stage mới vào trước `Docker: Build Images`:

```groovy
stage('Say Hello From Pipeline') {
    steps {
        echo 'This stage was added by editing Jenkinsfile.'
    }
}
```

Commit và push:

```bash
git add Jenkinsfile
git commit -m "Add demo Jenkins stage"
git push
```

### Học được gì?

- Pipeline cũng là code.
- Jenkinsfile thay đổi thì pipeline thay đổi.
- Đây là ý nghĩa của Pipeline as Code.

## Kịch bản 8: Branch thường vs Multibranch Pipeline

### Pipeline job thường

Nếu job chỉ cấu hình branch `main`, khi bạn push branch `feature/demo`, job thường sẽ không tự build branch đó.

### Multibranch Pipeline

Nếu dùng Multibranch Pipeline, Jenkins scan repo và phát hiện các branch có `Jenkinsfile`.

Thử:

```bash
git checkout -b feature/change-title
```

Sửa title trong:

```text
frontend/src/App.tsx
```

Commit và push:

```bash
git add .
git commit -m "Change title on feature branch"
git push -u origin feature/change-title
```

### Học được gì?

- Job thường thường theo dõi một branch cụ thể.
- Multibranch Pipeline tự tạo job riêng cho từng branch có Jenkinsfile.

## Kịch bản 9: Webhook vs chạy tay

### Chạy tay

Bạn bấm `Build Now`.

### Webhook

GitHub/GitLab gửi tín hiệu cho Jenkins khi có push.

### Học được gì?

- Jenkins không tự biết có code mới nếu không có trigger.
- Trigger thường dùng nhất là webhook từ Git provider.

## Kịch bản 10: Nhìn console log đúng cách

Khi pipeline fail:

1. Bấm vào build fail.
2. Chọn stage bị đỏ.
3. Mở console log của stage đó.
4. Tìm dòng lỗi đầu tiên, không chỉ dòng cuối.

### Học được gì?

Jenkins không chỉ để chạy tự động, mà còn giúp trace lỗi theo từng bước rõ ràng.
