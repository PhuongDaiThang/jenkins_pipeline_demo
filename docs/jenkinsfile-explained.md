# Giải thích Jenkinsfile

## `pipeline {}`

Khai báo toàn bộ pipeline.

```groovy
pipeline {
    agent any
    stages { ... }
}
```

## `agent any`

Cho Jenkins tự chọn agent/node để chạy job.

## `parameters`

Tạo input khi bấm `Build with Parameters`.

Trong project này có:

```groovy
DEPLOY_LOCAL
```

Nếu `false`: chỉ build/test/docker build.

Nếu `true`: Jenkins deploy app bằng Docker Compose và smoke test.

## `environment`

Khai báo biến môi trường dùng trong pipeline:

```groovy
BACKEND_IMAGE
FRONTEND_IMAGE
COMPOSE_PROJECT_NAME
```

## `stage`

Một giai đoạn lớn.

Ví dụ:

```groovy
stage('Backend: Test') {
    steps {
        dir('backend') {
            sh 'mvn -B test'
        }
    }
}
```

## `steps`

Các lệnh cụ thể bên trong stage.

Ví dụ:

```groovy
sh 'mvn -B test'
```

## `dir('backend')`

Chạy lệnh bên trong thư mục `backend`.

Tương đương:

```bash
cd backend
mvn test
```

## `junit`

Đọc kết quả test Maven để Jenkins hiển thị test report.

```groovy
junit allowEmptyResults: true, testResults: 'backend/target/surefire-reports/*.xml'
```

## `archiveArtifacts`

Lưu sản phẩm build trong Jenkins.

```groovy
archiveArtifacts artifacts: 'backend/target/*.jar', fingerprint: true
```

## `when`

Điều kiện để chạy stage.

```groovy
when {
    expression { return params.DEPLOY_LOCAL }
}
```

Nghĩa là stage chỉ chạy khi bạn bật parameter `DEPLOY_LOCAL`.

## `post`

Hành động sau khi pipeline/stage kết thúc.

Ví dụ:

```groovy
post {
    success {
        echo 'Pipeline finished successfully.'
    }
    failure {
        echo 'Pipeline failed.'
    }
}
```
