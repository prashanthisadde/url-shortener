# URL Shortener on AWS (Terraform + Go Lambda)

This project implements a serverless URL shortener using **AWS Lambda (Go)**, **API Gateway**, **DynamoDB**, and **WAF**, all provisioned and managed via **Terraform**. It includes CI/CD support, multi-environment deployment, and built-in rate limiting.

## Table of Contents

* [Features](#features)
* [Architecture](#architecture)
* [Prerequisites](#prerequisites)
* [CI/CD Deployment (GitHub Actions)](#cicd-deployment-github-actions)
  * [How it works](#how-it-works)
  * [Required GitHub Secrets](#required-github-secrets)
  * [Multi-Environment Support](#multi-environment-support)
* [Setup](#setup)
* [Testing](#testing)
  * [API Gateway via AWS Console](#1-api-gateway-via-aws-console)
  * [Lambda Console](#2-lambda-console)
  * [WAF Rate Limit Test](#3-waf-rate-limit-test)
* [Clean Up](#clean-up)
* [License](#license)

---

## Features

* **Shorten URLs**: POST a URL to receive a short code.
* **Redirect**: GET a short code to be redirected to the original URL.
* **Serverless & Scalable**: Powered by AWS Lambda and DynamoDB (on-demand) for persistence.
* **Secure**: Protected with AWS WAF rate limiting per IP.
* **IaC**: Entire stack managed via Terraform.
* **CI/CD**: Automated deployment on push to `dev`, `staging`, and `prod`.
* **Monitoring**: Alarms, Logs, metrics, and error tracking.

---

## Architecture

* **API Gateway**: RESTful public interface for shorten and redirect.
* **Lambda**: Go-based handler for short URL generation and redirection.
* **DynamoDB**: Stores URL-to-code mappings (pay-per-request).
* **WAF**: Rate limits requests per IP (e.g., 10 requests per 5 minutes).
* **CloudWatch**: Logs, metrics, and error tracking.

---

## Prerequisites

* [Go 1.24+](https://golang.org/)
* [Terraform 1.12+](https://www.terraform.io/)
* AWS credentials with access to Lambda, API Gateway, DynamoDB, WAF, CloudWatch.

---

## CI/CD Deployment (GitHub Actions)

This project uses **GitHub Actions** to deploy infrastructure automatically when changes are pushed to specific branches:

| Git Branch | Environment | Terraform Path                    |
| ---------- | ----------- | --------------------------------- |
| `dev`      | Development | `terraform/environments/dev/`     |
| `staging`  | Staging     | `terraform/environments/staging/` |
| `prod`     | Production  | `terraform/environments/prod/`    |

### How it works

When code is pushed to one of the environment branches:

* The Lambda function is compiled from `terraform/modules/url-shortener/main.go`
* Terraform is initialized in the appropriate environment folder
* Terraform apply is executed with `-auto-approve`

### Required GitHub Secrets

In your GitHub repo settings, configure these secrets under **Settings > Secrets and variables > Actions**:

| Secret Name             | Description                     |
| ----------------------- | ------------------------------- |
| `AWS_ACCESS_KEY_ID`     | IAM access key for deployment   |
| `AWS_SECRET_ACCESS_KEY` | Corresponding secret access key |


### Multi-Environment Support

This project supports isolated deployments for `dev`, `staging`, and `prod` environments using a folder-based structure:

```
terraform/
  environments/
    dev/
      providers.tf
      variables.tf
      ...
    staging/
      ...
    prod/
      ...
  modules/
    url-shortener/
      main.go
      ...
```

---

## Setup

1. **Clone the repo**

   ```bash
   git clone <repo-url>
   cd bb-test
   ```
2. **Build & Deploy (CI/CDl)** 
    * Automated deployment on push to `dev`, `staging`, and `prod`.

3. **Build & Deploy (Manual)**

   ```bash
   ./build.sh
   ```

   This script:

   * Compiles the Go Lambda binary for Linux.
   * Deploys the infrastructure using Terraform.

4. Manual Terraform and Apply.
    ```bash
      cd terraform/environments/dev/ # or staging/prod
      terraform init
      terraform apply
    ```

5. **Retrieve API URL**
    ```bash
    cd terraform/environments/dev/  # or staging/prod
    terraform output rest_api_url
    ```

---

## Testing

### 1. API Gateway via AWS Console

* POST `/v1/shorten`
  Body:

  ```json
  { "url": "https://google.com" }
  ```

* GET `/v1/{shortcode}`
  * Use the shortcode from POST method above to test redirection.

---

### 2. Lambda Console

* Use `test_events_lambda/post.json` and `get.json` to simulate real requests in the Lambda Console.

---

### 3. WAF Rate Limit Test

Test rate limiting from a single IP:

```bash
for i in {1..1000}; do
  curl -s -o /dev/null -w "[$i] %{http_code}\n" -X POST "<api-url>/v1/shorten" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"https://parallel${i}.com\"}" &
done
wait
```

Look for `403` responses and verify blocked requests in the WAF console.

---

## Clean Up

To remove all resources:

```bash
cd terraform/environments/dev/ # or staging/prod
terraform destroy
```

---

## License

MIT
