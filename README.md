## cicd-tf-gh-action

설명:
GitHub Actions를 활용하여 Terraform 인프라를 자동 프로비저닝하는 CI/CD 파이프라인 예제.
Terraform init, plan, apply 단계를 자동화하고, AWS 환경에서 실행되도록 구성.

기능:
- GitHub Actions를 이용한 Terraform CI/CD 자동화
- AWS S3를 사용한 Terraform 상태 관리
- terraform plan을 PR에서 검증 후, main 브랜치 병합 시 자동 적용
- GitHub Secrets를 활용한 AWS 자격 증명 관리

사용 기술:
- Terraform
- GitHub Actions
- AWS (S3, IAM 등)

사용 방법:
- .github/workflows/terraform.yml을 설정.
- AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY를 GitHub Secrets에 추가.
- git push 시 자동으로 Terraform 실행.
