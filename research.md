# DIDGO 리서치

업데이트: 2026-05-07

## 1. 레포 구성

- 현재 저장소는 로컬 통합 실행용 `infra` 레포다.
- 함께 동작하는 형제 레포:
  - `../api-gateway`
  - `../user-service`
  - `../training-service`

## 2. 요청 흐름

```text
Client
  -> edge-proxy (Nginx)
  -> api-gateway
  -> user-service / training-service
```

현재 `api-gateway` 라우팅:

- `/api/auth/**`, `/api/users/**` -> `user-service`
- `/api/trainings/**` -> `training-service`

## 3. 실행 구조

`docker-compose.yml` 기준으로 아래 컨테이너를 실행한다.

- `edge-proxy`
- `api-gateway`
- `user-service`
- `training-service`
- `mysql`
- `redis`

호스트에 공개되는 포트:

- `80` -> Nginx
- `3307` -> MySQL
- `6380` -> Redis
- `8082` -> training-service

애플리케이션 컨테이너는 내부 네트워크에서 `8080`을 사용하고, `training-service`만 필요 시 호스트 `8082`로 직접 확인할 수 있다.

## 4. 데이터베이스 구조

MySQL 컨테이너는 하나다.

```text
mysql container
  |- user_db
  \- training_db
```

즉, 데이터베이스 서버는 하나지만 논리 데이터베이스는 분리되어 있다.

- `user-service` -> `user_db`
- `training-service` -> `training_db`

## 5. 스키마 관리 방식

### user-service

- JPA를 사용해 엔티티 매핑과 데이터 접근을 처리한다.
- Flyway를 사용해 `user_db` 스키마를 관리한다.
- JPA 설정은 `ddl-auto=validate` 이다.
- 스키마 정본은 `../user-service/src/main/resources/db/migration` 이다.

현재 핵심 테이블:

- `users`
- `user_disabilities`

### training-service

- 서비스 코드와 JDBC 기반 로직으로 데이터 접근을 처리한다.
- Flyway를 사용해 `training_db` 스키마를 관리한다.
- 스키마 정본은 `../training-service/src/main/resources/db/migration` 이다.
- 패키지 기준은 `com.didgo.trainingservice` 로 통일되어 있다.

정리하면:

- 이 저장소는 `user_db`, `training_db` 데이터베이스와 네트워크만 준비한다.
- 실제 테이블 생성과 변경은 각 서비스의 Flyway가 담당한다.

## 6. 버전

Spring Boot 버전은 모두 `3.5.13` 으로 통일되어 있다.

- `api-gateway`
- `user-service`
- `training-service`

## 7. 검증 상태

확인된 테스트 상태:

- `../api-gateway`: `.\mvnw.cmd test` 통과
- `../user-service`: `.\mvnw.cmd test` 통과
- `../training-service`: `.\mvnw.cmd test` 통과

## 8. 남은 이슈

1. 내부 서비스 간 신뢰 모델이 단순하다.
2. 게이트웨이 Swagger 노출 전략은 추가 정리가 필요하다.

## 9. 요약

- 외부 요청은 `Nginx -> api-gateway -> services` 흐름을 따른다.
- 논리 데이터베이스는 `user_db`, `training_db` 로 분리된다.
- `user-service`, `training-service` 모두 Flyway로 스키마를 관리한다.
- 이 저장소는 서비스 실행과 통합 테스트를 위한 인프라 진입점이다.
